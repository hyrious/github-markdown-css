require 'open-uri'
require 'tmpdir'
require 'date'

def get url
  puts "↓ #{url}"
  URI.open url, &:read
end

def cached_get url
  filename = File.basename url
  tmpfile  = File.join Dir.tmpdir, filename
  cached   = File.exist?(tmpfile) and (Date.today - File.mtime(tmpfile).to_date).to_i < 7
  return File.read tmpfile if cached
  content  = get url
  File.write tmpfile, content
  return content
end

def each_rule css
  # remove comments
  css.gsub! /\/\*.+?\*\//m, ''
  # scan based on { and }
  i = j = k = 0
  loop do
    j = css.index ?{, i
    k = css.index ?}, i
    break unless j and k
    selector = css[i...j].strip
    if selector.start_with? '@'
      k = j + 1
      t = 0
      while t >= 0
        case css[(k += 1) - 1]
        when ?{ then t += 1
        when ?} then t -= 1
        end
      end
      i = k
      # skip @media @keyframes
      next
    end
    body = css[j + 1...k]
    yield selector, body
    i = k + 1
  end
end

# https://github.com/gjtorikian/html-pipeline/blob/main/lib/html/pipeline/sanitization_filter.rb
ALLOWLIST = %w(
  h1 h2 h3 h4 h5 h6 h7 h8 br b i strong em a pre code img tt
  div ins del sup sub p ol ul table thead tbody tfoot blockquote
  dl dt dd kbd q samp var hr ruby rt rp li tr td th s strike summary
  details caption figure figcaption
  abbr bdo cite dfn mark small span time wbr
  body html g-emoji
)

ALLOWCLASS = %w(
  .g-emoji
  .radio-label-theme-discs
)

def scan_markdown css
  ret = []
  each_rule css do |selector, body|
    # always include .markdown-body and syntax highlights
    if selector.start_with? '.markdown-body' or body.include? 'prettylights'
      next if selector.include? '.zeroclipboard-container'
      ret << "#{selector}{#{body}}"
    elsif selector.start_with? /[:\[\w]/
      # top level rules applied to :root, a, ...
      # ignore unknown tag|class names
      if (tag = selector[/^\w[-\w]*/])
        next unless ALLOWLIST.include? tag
      end
      if (klass = selector[/\.[-\w]+/])
        next unless ALLOWCLASS.include? klass
      end
      # manually ignore this rule
      next if selector == '[hidden][hidden]'
      ret << "#{selector}{#{body}}"
    end
  end
  ret
end

html = cached_get 'https://github.com'
urls = html.scan(/href="(.+?\.css)/).flatten.uniq
colors = []
markdown_body = []
urls.each { |url|
  css = cached_get url
  if (m = url.match /((?:light|dark)\w*)/)
    colors << [m[1], css.scan(/(--[-\w]+):([^;}]+)[;}]/)]
  else
    markdown_body.push *scan_markdown(css)
  end
}
# remove duplicates, but keep order
markdown_body = markdown_body.reverse.uniq.reverse
# remove unused variables
variables = markdown_body.flat_map { |s| s.scan(/var\((.+?)\)/).flatten }
markdown_body.each { |s|
  next if s.include? 'prettylights'
  s.gsub!(/(--[-\w]+):([^;}]+)([;}])/) { |t|
    m = t.match /(--[-\w]+):([^;}]+)([;}])/
    variables.include?(m[1]) ? t : m[3] == '}' ? '}' : ''
  }
}
# remove empty rules
markdown_body.reject! { |s| s.end_with? '{}' }
# merge root rules
theme, root = [], []
markdown_body = markdown_body.flat_map { |s|
  if s.include? 'color-scheme:'
    theme << s
    next []
  end
  selectors = s[...s.index('{')].split(?,).map { |t|
    next '.markdown-body' if %w( :root html body ).include? t
    t.start_with?('.markdown-body') ? t : ".markdown-body #{t}"
  }
  if selectors.size == 1 and selectors[0] == '.markdown-body'
    root << s[s.index('{') + 1..-2]
    next []
  else
    [selectors.join(?,) + s[s.index('{')..]]
  end
}

require 'stringio'
io = StringIO.new
# io.puts theme
io.puts '.markdown-body{' + root.join(';') + '}'
io.puts File.read 'prefix.css'
io.puts markdown_body
raw = io.string

Dir.mkdir 'dist' unless Dir.exist? 'dist'
test_html = cached_get 'https://sindresorhus.com/github-markdown-css/'
test_html[/<head>/] = '<head><meta name="color-scheme" content="dark">'
test_html[/<body>/] = '<body class="markdown-body">'
test_html[/<a class="github-fork-ribbon".+/] = ''
File.write 'dist/index.html', test_html

light = colors[0][1].reverse
dark = colors.find { |(name, _)| name == 'dark' }[1].reverse
light = dark + light
lighted = raw.gsub(/var\((.+?)\)/) { |t|
  m = t.match /var\((.+?)\)/
  var = m[1]
  _, value = light.find { |(name, _)| name == var }
  next value
}
File.write 'dist/github-markdown.css', lighted

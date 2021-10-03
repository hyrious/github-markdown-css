require 'open-uri'
require 'tmpdir'
require 'date'

def get url
  puts "↓ #{url}"
  URI.open url, proxy: 'http://localhost:10809', &:read
end

def cached_get url
  filename = File.basename url
  tmpfile  = File.join Dir.tmpdir, filename
  cached   = (Date.today - File.mtime(tmpfile).to_date).to_i < 7
  return File.read tmpfile if File.exist? tmpfile and cached
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
    elsif selector.start_with? /[:\w]/
      # top level rules applied to :root, a, ...
      # ignore unknown tag|class names
      if (tag = selector[/^\w[-\w]*/])
        next unless ALLOWLIST.include? tag
      end
      if (klass = selector[/\.[-\w]+/])
        next unless ALLOWCLASS.include? klass
      end
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
puts markdown_body

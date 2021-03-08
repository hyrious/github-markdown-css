HINT = 'https://github.com/sindresorhus/github-markdown-css/files/5792145/result.css.txt'
SRC = 'https://cdn.jsdelivr.net/npm/github-markdown-css@4.0.0/github-markdown.css'

require 'open-uri'

def get url
  puts "Downloading #{url}"
  URI.open(url) { _1.read }
end

require 'tmpdir'

def cached_get url
  filename = File.basename url
  path = File.join Dir.tmpdir, filename
  if File.exist? path
    puts "Cached #{path}"
    return File.read path
  end
  content = get url
  File.write path, content
  return content
end

hint = cached_get HINT
src  = cached_get SRC

# dirty hack: add 'background-color' in '.markdown-body'
if (i = src.index /.markdown-body\s*{/)
  j = src.index ' color: #', i
  k = src.index "\n", j
  src = src[0..k] + "  background-color: #ffffff;\n" + src[k + 1..]
end

src.sub! '}.markdown-body', "}\n.markdown-body"

# I don't want to parse CSS, let's do string manipulations.

def string_each_index s, pattern
  offset = 0
  while (i = s.index pattern, offset)
    yield i, s
    offset = i + 1
  end
end

result = {}
dark = hint[hint.index(/prefers-color-scheme:\s*dark/)..]
string_each_index hint, /var\(--/ do |i|
  j = hint.rindex(?\n, i) + 1
  attrib = hint[j...hint.index(";", j)]
  k = hint.rindex(?{, j)
  l = hint.rindex(?}, k) || -1
  klass = hint[l + 1...k].strip
  a, b = attrib.split(?:, 2).map(&:strip)
  string_each_index src, /#{Regexp.escape klass}\s*{/ do |q|
    if (r = src.index ?}, q) and (t = (s = src[q..r]).index a + ?:)
      var = b.match(/var\((--[^)]*)/)[1]
      if (m = dark.match(/#{var}:\s*([^;\n]+)/))
        val = m[1]
        (result[klass] ||= {})[a] = b.sub("var(#{var})", val)
      end
    end
  end
end

require 'stringio'

io = StringIO.new
io.puts src
io.puts
io.puts "@media (prefers-color-scheme: dark) {"
result.each { |klass, kv|
  io.puts "  #{klass.split("\n").join("\n  ")} {"
  kv.each { |k, v|
    io.puts "    #{k}: #{v};"
  }
  io.puts "  }"
}
io.puts "}"
File.write 'github-markdown.css', io.string

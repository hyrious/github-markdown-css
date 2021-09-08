SRC = 'https://cdn.jsdelivr.net/npm/github-markdown-css@4.0.0/github-markdown.css'

require 'open-uri'
require 'tmpdir'
require 'json'

def log *args
  $stderr.puts *args
end

def get url
  log "fetching #{url}"
  URI.open url, &:read
end

def cached_get url
  filename = File.basename url
  path = File.join Dir.tmpdir, filename
  if File.exist? path
    log "cache hit #{filename}"
    return File.read path
  end
  content = get url
  File.write path, content
  return content
end

src = cached_get SRC
github_index = cached_get 'https://github.com'
github_css = github_index.scan /(?<=href=")\S+\.css/

# add 'background-color' in '.markdown-body'
if (i = src.index /.markdown-body\s*{/)
  j = src.index ' color: #', i
  k = src.index "\n", j
  src = src[0..k] + "  background-color: #ffffff;\n" + src[k + 1..]
end
# ensure new line between css selectors
src.sub! '}.markdown-body', "}\n.markdown-body"

# make temp.html
css = github_css.map { |e| cached_get e }.join("\n")
File.write 'temp.html', <<~HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
  <style>#{css}</style>
</head>
<body>
  <script src="./make.js"></script>
</body>
</html>
HTML
log "\nnow, open temp.html, click `Run` and `Save`"
log "\nwaiting for POST localhost:3000/submit ..."
system "open temp.html"

# wait for user submit
require 'socket'
server = TCPServer.new 'localhost', 3000
response_send = -> session, code, body {
  session.print "HTTP/1.1 #{code}\r\nContent-Type: text/plain\r\nAccess-Control-Allow-Origin: *\r\n\r\n#{body}\r\n"
  session.close
}
info = nil

while (session = server.accept)
  request = session.readpartial 2048
  method, path, version = request.lines[0].split
  headers = {}
  nlines = 1
  request.lines[1..].each do |line|
    break if line == "\r\n"
    key, value = line.split /: ?/, 2
    headers[key] = value.chomp
    nlines += 1
  end
  body = request.lines[nlines + 1..].join
  len = headers["Content-Length"].to_i
  if body.size > len
    body += session.readpartial body.size - len
  end

  if method == 'POST' && path == '/submit'
    info = JSON.parse body
    response_send[session, 200, "ok"]
    break
  else
    response_send[session, 404, "Not Found"]
    next
  end
end

# TODO: do something with info

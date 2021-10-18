a = `npx github-markdown-css --list`.split

u = 'https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/dist'

puts "|" + ' <!-- --> |' * a.size
puts '|' + ' - |' * a.size
puts '| Dark\Light |' + a.map { |e| " **#{e}** |" }.join
a.each_with_index { |e, i|
  print "| **#{e}** |"
  dark = e
  a.each { |f|
    light = f
    if light == dark
      print " [#{light}.css](#{u}/#{light}.css) |"
    else
      print " [#{light}-#{dark}.css](#{u}/#{light}-#{dark}.css) |"
    end
  }
  puts
}

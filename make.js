import fs from 'fs'
import githubMarkdownCss from 'generate-github-markdown-css'

fs.mkdirSync('dist', { recursive: true })

const themes = (await githubMarkdownCss({ list: true })).split(/\s+/)

const tasks = []

for (const light of themes) {
  for (const dark of themes) {
    console.log("working on", { light, dark })
    tasks.push(githubMarkdownCss({ light, dark }).then(contents => {
      const file = light === dark ? `dist/${light}.css` : `dist/${light}-${dark}.css`
      return fs.promises.writeFile(file, contents)
    }))
  }
}

await Promise.all(tasks)

fs.copyFileSync('dist/light-dark.css', 'github-markdown.css')

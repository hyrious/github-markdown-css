import githubMarkdownCss from 'generate-github-markdown-css'
import esbuild from 'esbuild'
import fs from 'fs'

fs.mkdirSync('dist', { recursive: true })

const themes = (await githubMarkdownCss({ list: true })).split(/\s+/)

const tasks = []

for (const light of themes) {
  for (const dark of themes) {
    tasks.push(githubMarkdownCss({ light, dark }).then(contents => esbuild.build({
      stdin: {
        contents,
        loader: 'css',
      },
      minify: true,
      outfile: light === dark ? `dist/${light}.css` : `dist/${light}-${dark}.css`,
    })))
  }
}

await Promise.all(tasks)

fs.copyFileSync('dist/light-dark.css', 'github-markdown.css')

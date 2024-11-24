import fs from 'fs'
import githubMarkdownCss from 'generate-github-markdown-css'

fs.mkdirSync('dist', { recursive: true })

const themes = (await githubMarkdownCss({ list: true })).split(/\s+/)

const tasks = []

for (const light of themes) {
  for (const dark of themes) {
    console.log("working on", { light, dark })
    tasks.push(githubMarkdownCss({ light, dark, useFixture: false }).then(contents => {
      const file = light === dark ? `dist/${light}.css` : `dist/${light}-${dark}.css`
      return fs.promises.writeFile(file, patch(contents))
    }))
  }
}

await Promise.all(tasks)

fs.copyFileSync('dist/light-dark.css', 'github-markdown.css')

// Definitely will fix it in upstream.
function patch(css) {
  css = removeRule(css, 'body:has(:modal)')
  css = removeRule(css, '.zeroclipboard-container')
  return css
}

function removeRule(css, selector) {
  let index = css.indexOf(selector)
  if (index >= 0) {
    let start = css.lastIndexOf('}', index)
    let end = css.indexOf('}', index)
    if (end >= 0) {
      return css.slice(0, start) + css.slice(end)
    }
  }
  return css
}

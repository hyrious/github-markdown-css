# github-markdown-css

> [sindresorhus/github-markdown-css][1], with dark theme support

Related issue: [sindresorhus/github-markdown-css#76](https://github.com/sindresorhus/github-markdown-css/issues/76).

## Usage

CDN links: (_auto_ means it uses `@media (prefers-color-scheme: dark)`)

- only light &rarr; [original repo][1]
- [**auto light/dark**][2]: _you probably want this_
- [auto light/dark_dimmed][3]
- [auto light/dark_high_contrast][4]
- [only dark][5]
- [only dark_dimmed][6]
- [only dark_high_contrast][7]
- [full control][8]\
  you can control the theme with the same attributes as GitHub uses, like `[data-color-mode]`,
  below is a simple script to help you toggle themes.

```js
/**
 * @example
 * setTheme({ mode: 'auto' })
 * setTheme({ mode: 'auto', dark: 'dark_dimmed' })
 * setTheme({ mode: 'light', light: 'dark' }) // haha, which is dark theme!
 */
function setTheme({
  // this element should be outside of .markdown-body
  el = document.documentElement,
  // 'auto' | 'light' | 'dark'
  mode = 'auto',
  // 'light' | 'dark' | 'dark_dimmed' | 'dark_high_contrast'
  light = 'light',
  // 'light' | 'dark' | 'dark_dimmed' | 'dark_high_contrast'
  dark = 'dark',
}) {
  el.dataset.colorMode = mode
  el.dataset.lightTheme = light
  el.dataset.darkTheme = dark
}
```

## How it works

This script downloads Sindre's original [github-markdown.css](https://cdn.jsdelivr.net/npm/github-markdown-css@4.0.0/github-markdown.css) and all GitHub's css. Then:

1. scan GitHub's css to prepare all colors.
2. look for the same prop both in the Sindre's and in GitHub,\
   which has `[prop]: ...var(...` in the right.
3. construct the `@media (prefers-color-scheme)` part, append it to Sindre's.
4. for the `-only` files, replace them in the Sindre's.
5. for the `-full` file, replace them with GitHub's css and prepend the colors.

### Developer Tips

```bash
npm install
npm test
```

## Todo

All future works (like get rid of depending on the original css) go to\
[hyrious/generate-github-markdown-css](https://github.com/hyrious/generate-github-markdown-css).

## License

MIT @ [hyrious](https://github.com/hyrious)

[1]: https://github.com/sindresorhus/github-markdown-css
[2]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown.css
[3]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown--dimmed.css
[4]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown--high_contrast.css
[5]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown--dark-only.css
[6]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown--dimmed-only.css
[7]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown--high_contrast-only.css
[8]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown--full.css

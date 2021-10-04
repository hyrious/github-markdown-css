# github-markdown-css

> [sindresorhus/github-markdown-css][1], with dark theme support

Related issue: [sindresorhus/github-markdown-css#76](https://github.com/sindresorhus/github-markdown-css/issues/76).

Checkout latest works &rarr; https://hyrious.me/github-markdown-css/

## Usage

- https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown.css \
  Based on Sindre's original css, with dark theme in `@media (prefers-color-scheme: dark)`.
- Checkout `gh-pages` branch.

## How it works

1. Fetch https://github.com, scan css files.
2. Scan css variables in color themes.
3. Scan `.markdown-body` rules in other files.
   Also scan [allowed tags](https://gist.github.com/seanh/13a93686bf4c2cb16e658b3cf96807f2).

## License

MIT @ [hyrious](https://github.com/hyrious)

[1]: https://github.com/sindresorhus/github-markdown-css

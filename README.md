# github-markdown-css

> [sindresorhus/github-markdown-css][1], with dark theme support

Related issue: [sindresorhus/github-markdown-css#76](https://github.com/sindresorhus/github-markdown-css/issues/76).

## Usage

CDN links: (_auto_ means it uses `@media (prefers-color-scheme: dark)`)

- only light &rarr; [original repo][1]
- [**auto light/dark**][2]: _you probably want this_

## How it works

1. Fetch https://github.com, scan css files.
2. Scan css variables in color themes.
3. Scan `.markdown-body` rules in other files.
   Also scan [allowed tags](https://gist.github.com/seanh/13a93686bf4c2cb16e658b3cf96807f2).

## Todo

All future works (like get rid of depending on the original css) go to\
[hyrious/generate-github-markdown-css](https://github.com/hyrious/generate-github-markdown-css).

## License

MIT @ [hyrious](https://github.com/hyrious)

[1]: https://github.com/sindresorhus/github-markdown-css
[2]: https://cdn.jsdelivr.net/gh/hyrious/github-markdown-css@main/github-markdown.css

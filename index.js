// this file run in node
import { tmpdir } from "os"
import { existsSync, readFileSync, writeFileSync } from "fs"
import { basename, join } from "path"
import { get } from "https"
import createSocksProxyAgent from 'socks-proxy-agent'
import esbuild from "esbuild"

const log = console.log
const agent = createSocksProxyAgent('socks://localhost:7890')

const cachedGet = (url) => {
  const filename = basename(url)
  const path = join(tmpdir(), filename)
  if (existsSync(path)) {
    log('cache hit', filename)
    return readFileSync(path, "utf8")
  }
  log('fetching', url)
  return new Promise((resolve, rej) => {
    get(url, { agent }, (res) => {
      let c = []
      res.on('data', d => c.push(d))
      res.on('end', () => {
        const data = Buffer.concat(c).toString()
        writeFileSync(path, data)
        resolve(data)
      })
      res.on("error", rej)
    }).on("error", rej)
  })
}

const getCSS = (async () => {
  const body = await cachedGet('https://github.com')
  const css = body.match(/(?<=href=")\S+\.css/g)
  const all = await Promise.all(css.map(cachedGet)).then(all => all.join('\n'))
  writeFileSync('dist/all.css', all)
})();

const getOri = (async () => {
  const body = await cachedGet('https://cdn.jsdelivr.net/npm/github-markdown-css@4.0.0/github-markdown.css')
  writeFileSync('dist/ori.css', body)
})();

const buildJSX = esbuild.build({
  entryPoints: ["main.jsx"],
  bundle: true,
  outdir: 'dist',
  sourcemap: 'inline',
  charset: 'utf8',
  minifySyntax: true
})

await getCSS
await getOri
await buildJSX

console.log("\ngenerated dist")
console.log("now start a local http server and click `run`")
console.log("for example: npx sirv-cli -D")

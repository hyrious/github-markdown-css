// this file run in node
import esbuild from "esbuild"

esbuild.build({
  entryPoints: ["main.jsx"],
  bundle: true,
  outdir: 'dist',
})

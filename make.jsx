import parser from "postcss-selector-parser"
import { createElement, patch } from "million"

const loading = <div><p id="info" class="pt-4 px-4">Loading...</p></div>
let el = createElement(loading)
document.body.append(el)

let allRules = document.styleSheets[0].cssRules
let index = 0

const render = () => <div>
    <div style={{
        height: '2px',
        background: 'currentColor',
        width: (100 * index / allRules.length) + '%'
    }} />
    <p id="info" class="pt-4 px-4">{index}/{allRules.length}</p>
</div>

let raf = 0;
function update() {
    if (index < allRules.length) {
        rule = allRules[index]
        handle(rule)
    }

    index = Math.min(index + 1, allRules.length)
    if (index === allRules.length) {
        patch(el, render())
        cancelAnimationFrame(raf)
        return;
    }

    if (index % 123 === 0) {
        raf = requestAnimationFrame(update)
        patch(el, render())
    } else {
        update()
    }
}
raf = requestAnimationFrame(update)

let a = new Set()
let processor = parser(selectors => {
    selectors.walkPseudos(selector => {
        a.add(selector.value)
    });
})
function handle(rule) {
    if (rule instanceof CSSStyleRule) {
        const selector = processor.processSync(rule.selectorText)
    }
}
window.f = () => a;

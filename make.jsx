import { createElement, schedule, patch } from 'million'

const loading = <p id="info" class="pt-4 px-4">Loading...</p>
const ready = <p id="info" class="pt-4 px-4">Ready.</p>

let el = createElement(loading)
document.body.append(el)

schedule(() => {
    patch(el, ready)
})

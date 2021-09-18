// this file run in browser
import React, { useState, useCallback, useEffect } from "react"
import ReactDOM from "react-dom"

const ori_p = fetch('./dist/ori.css').then(r => r.text())

function renderValue(value) {
    let result = ''
    for (let x of value.values()) {
        if (typeof x === 'string') {
            result += x
        } else if (x instanceof CSSVariableReferenceValue) {
            if (x.fallback) {
                result += `var(${x.variable}, ${x.fallback})`
            } else {
                result += `var(${x.variable})`
            }
        }
    }
    return result
}

function using(sel, map) {
    let parts = sel.split(' ');
    let { length } = parts
    for (let i = 0; i < length; ++i) {
        let k = parts.slice(length - i - 1).join(' ');
        if (k in map) return true;
    }
}

const core = {
    log: console.log,
    done() {},

    used: {},
    variables: {},
    ori_raw: '',
    async run() {
        this.used = {};
        this.variables = {};
        const rules = document.styleSheets[0].cssRules;
        const { length } = rules;
        this.ori_raw = await ori_p;

        for (let i = 0; i < length; ++i) {
            const rule = rules[i];
            if (rule instanceof CSSStyleRule) {
                for (const [k, v] of rule.styleMap.entries()) {
                    if (k.startsWith('--')) {
                        (this.variables[rule.selectorText] ||= new Map()).set(k, renderValue(v[0]))
                    } else if (v[0].length === 1) {
                        const value = renderValue(v[0])
                        if (value.includes('var(')) {
                            (this.used[rule.selectorText] ||= new Map()).set(k, value)
                        }
                    }
                }
            }
        }

        const ori_sels = this.ori_raw.match(/\.markdown-body[^{]*(?=\{)/g)
                             .flatMap(e => e.trimEnd().split(/,\s*/))
                             .filter(e => using(e, this.used));

        this.ori_sels = ori_sels;

        this.log('ok')
    },
    save() {

    }
}

window.a = core

function App() {
    const [phase, setPhase] = useState('idle')
    const [logText, setLogText] = useState('')

    const log = useCallback((text) => {
        setLogText(logText + text + '\n')
    }, [logText])

    const run = useCallback(() => {
        setPhase('working')
        core.run()
    }, [])

    const save = useCallback(() => {
        core.save()
        log('ok.')
    }, [log])

    useEffect(() => {
        core.log = log
        core.done = () => setPhase('done')
    }, [log])

    return <div>
        <p className="px-3 pt-4">
            <button className="btn btn-primary" disabled={phase !== 'idle'} onClick={run}>RUN</button>
            <button className="btn ml-2" disabled={phase !== 'done'} onClick={save}>SAVE</button>
            <span className="pl-3 color-text-secondary text-small">{phase}</span>
        </p>
        <pre>
            <code className="blob-code-inner">{logText}</code>
        </pre>
    </div>
}

ReactDOM.render(<App />, document.querySelector('#app'))

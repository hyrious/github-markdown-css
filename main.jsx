// this file run in browser
import React, { useState, useCallback, useEffect } from "react"
import ReactDOM from "react-dom"

const core = {
    log: console.log,
    done() {},
    run() {
        const rules = document.styleSheets[0].cssRules;
    },
    save() {

    }
}

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

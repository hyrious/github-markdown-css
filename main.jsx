// this file run in browser
import React from "react"
import ReactDOM from "react-dom"

function App() {
    return <p className="px-4 pt-4">Hello, world!</p>
}

ReactDOM.render(<App />, document.querySelector('#app'))

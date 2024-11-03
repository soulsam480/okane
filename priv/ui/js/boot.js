import { hydrate } from "./hydrate.js";
import { Component, html, render } from "htm";
import { Router } from "./router.js";

hydrate();

class App extends Component {
  render() {
    return html`<div class="p-2">
      <${Router} />
    </div>`;
  }
}

render(html`<${App} />`, document.querySelector("#app"));

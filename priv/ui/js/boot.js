import { hydrate } from "./hydrate.js";
import { Component, html, render } from "htm";
import login_form from "./pages/login_form.js";
import home from "./pages/home.js";
import { $authState } from "./store.js";

hydrate();

class App extends Component {
  render() {
    return html`<div class="p-2">
      ${$authState.value.user === null
        ? html`<${login_form}></${login_form}>`
        : html`<${home} />`}
    </div>`;
  }
}

render(html`<${App} />`, document.querySelector("#app"));

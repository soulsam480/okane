import { html } from 'htm'
import { $auth_state } from "../store.js";

export function nav_bar() {
	return html`
    <div
      class="pb-2 flex justify-between gap-2 items-center border-b border-secondary"
    >
      <div>Okane</div>

      <div>${$auth_state.value.name}</div>
    </div>
`
}

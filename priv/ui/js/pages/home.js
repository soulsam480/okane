import { html } from "htm";
import { GroupsList } from "../components/groups_list.js";
import { nav_bar } from '../components/nav_bar.js'

export function home() {
	return html`<div class="flex flex-col gap-4">
    <${nav_bar} />
    <${GroupsList} />
  </div>`;
}

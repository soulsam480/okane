import { $auth_state } from "../store.js";
import { html } from "htm";

export function home() {
  return html`<div>Hello ${$auth_state.value.name}! Welcome to Okane.</div>`;
}

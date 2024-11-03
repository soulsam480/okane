import { $authState } from "../store.js";
import { html } from "htm";

export default function () {
  return html`
    <div>Hello ${$authState.value.user.name}! Welcome to Okane.</div>
  `;
}

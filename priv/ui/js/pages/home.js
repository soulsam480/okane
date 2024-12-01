import { $auth_state } from "../store.js";
import { html } from "htm";
import { GroupsList } from "../components/groups_list.js";
import { GroupCreateForm } from "../components/group_create_form.js";

export function home() {
  return html`<div class="flex flex-col gap-4">
    <div
      class="pb-2 flex justify-between gap-2 items-center border-b border-secondary"
    >
      <div>Okane</div>

      <div>${$auth_state.value.name}</div>
    </div>

    <${GroupsList} />
    <${GroupCreateForm} />
  </div>`;
}

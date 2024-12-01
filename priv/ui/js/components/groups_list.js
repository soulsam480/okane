import { html } from "htm";
import { $fetch } from "../client.js";
import { $groups, set_partial } from "../store.js";
import tinydate from "tinydate";

async function load_groups() {
  set_partial($groups, { state: "loading" });

  const resp = await $fetch("/auth/groups");

  if (resp.status === 200) {
    const body = await resp.json();

    $groups.value = {
      state: "idle",
      data: body.data,
    };
  }
}

load_groups();

export function GroupsList() {
  return html`
    ${$groups.value.state === "loading"
      ? html`<span>Loading groups</span>`
      : html`<div class="flex flex-col gap-3">
          <div>Groups you're part of</div>
          <ul class="flex flex-col gap-2">
            ${$groups.value.data.map((group) => {
              return html`<li
                key=${group.id}
                class="rounded flex flex-col gap-0.5 px-1.5 py-1 shadow-sm bg-base-200"
              >
                <div class="text-sm">${group.id}: ${group.name}</div>
                <div class="text-xs">
                  created:
                  ${tinydate("{MMMM} {DD} {YYYY}", {
                    MMMM: (d) => d.toLocaleString("default", { month: "long" }),
                  })(new Date(group.created_at))}
                </div>
              </li>`;
            })}
          </ul>
        </div>`}
  `;
}

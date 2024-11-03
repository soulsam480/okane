import { $auth_state } from "./store.js";

export function hydrate() {
  const hydrate_el = document.querySelector("#APP_DATA");

  if (hydrate_el === null) {
    throw new Error("[UI]: hydration failure.");
  }

  const parsed = JSON.parse(hydrate_el.textContent);

  $auth_state.value = parsed.user;

  hydrate_el.remove();
}

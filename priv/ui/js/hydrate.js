import { $authState } from "./store.js";

export function hydrate() {
  const hydrate_el = document.querySelector("#APP_DATA");

  $authState.value.user = JSON.parse(
    hydrate_el.textContent ?? '{"user": null}',
  ).user;

  hydrate_el.remove();
}

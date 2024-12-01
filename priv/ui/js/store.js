import { signal, effect } from "htm";

function get_route_from_loc() {
  const hash = window.location.hash.replace(/^#/, "");

  if (hash.length === 0) {
    return null;
  }

  return hash;
}

/**
 *  @type {import('htm').Signal<string|null>}
 */
export const $current_route = signal(get_route_from_loc());

window.addEventListener("hashchange", () => {
  if (!$auth_state.peek()) {
    $current_route.value = "login";
    return;
  }

  $current_route.value = get_route_from_loc();
});

export function goto(path) {
  window.location.hash = path;
}

/**
 *  @type {import('htm').Signal<import('types/models.d.ts').User>}
 */
export const $auth_state = signal(null);

/**
 *  @type {import('htm').Signal<import('types/store.d.ts').IResourceState<Array<import('types/models.d.ts').Group>>>}
 */
export const $groups = signal({
  state: "idle",
  data: [],
});

effect(() => {
  if ($auth_state.value) {
    goto("home");
  } else {
    goto("login");
  }
});

/**
 * @param {import('htm').Signal<any>} signal
 * @param {any} value
 */
export function set_partial(signal, value) {
  const old_val = signal.peek();

  signal.value = {
    ...old_val,
    ...value,
  };
}

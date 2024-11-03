import { signal, effect } from "htm";

/**
 *  @type {import('htm').Signal<string|null>}
 */
export const $current_route = signal(null);

window.addEventListener("hashchange", () => {
  const hash = window.location.hash.replace(/^#/, "");

  if (!$auth_state.peek()) {
    $current_route.value = "login";
    return;
  }

  if (hash.length === 0) {
    $current_route.value = null;
  } else {
    $current_route.value = hash;
  }
});

export function goto(path) {
  window.location.hash = path;
}

/**
 *  @type {import('htm').Signal<import('types/models.d.ts').User>}
 */
export const $auth_state = signal(null);

effect(() => {
  if ($auth_state.value) {
    goto("home");
  } else {
    goto("login");
  }
});

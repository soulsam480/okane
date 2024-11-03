import { signal } from "htm";

export const $hashState = signal(null);

window.addEventListener("hashchange", () => {
  let hash = window.location.hash.replace(/^#/, "");

  if (hash.length === 0) {
    $hashState.value = null;
  } else {
    $hashState.value = hash;
  }
});

export function goto(path) {
  window.location.hash = path;
}

export const $authState = signal({
  user: null,
});

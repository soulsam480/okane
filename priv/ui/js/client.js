/**
 *
 * @param {string|URL|globalThis.Request} url
 * @param {RequestInit} init
 */
export async function $fetch(url, { headers = {}, ...rest } = {}) {
  return fetch(url, {
    ...rest,
    headers: {
      "Content-Type": "application/json",
      ...headers,
    },
  });
}

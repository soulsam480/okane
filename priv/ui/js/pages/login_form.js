import { html } from "htm";
import toastify from "toastify-js";

export function login_form() {
  /**
   * @param {SubmitEvent} event
   */
  async function handleLogin(event) {
    event.preventDefault();

    const formData = new FormData(event.target);

    // TODO: handle errors as toasts
    const response = await fetch("/sessions/login", {
      method: "POST",
      body: formData,
    });

    if (response.ok) {
      window.location.reload();
    } else {
      toastify({
        text: "Something went wrong!",
        gravity: "top",
        className: "app-toast app-toast--error",
      }).showToast();
    }
  }

  return html`<form
    class="p-4 flex flex-col gap-2 justify-center items-center"
    onSubmit=${handleLogin}
  >
    <div class="text-lg font-semibold">Welcome to Okane!</div>
    <label class="form-control w-full max-w-xs">
      <div class="label">
        <span class="label-text">What is your email?</span>
      </div>
      <input
        required
        type="email"
        name="email"
        placeholder="Enter email"
        class="input input-sm input-bordered w-full max-w-xs"
      />
    </label>

    <label class="form-control w-full max-w-xs">
      <div class="label">
        <span class="label-text">What is your password?</span>
      </div>
      <input
        required
        type="password"
        name="password"
        placeholder="Secret!!!"
        class="input input-sm input-bordered w-full max-w-xs"
      />
    </label>
    <button class="btn max-w-xs btn-sm w-full btn-primary mt-2" type="submit">
      Login
    </button>
  </form>`;
}

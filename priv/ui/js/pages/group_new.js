import { html } from "htm";
import { nav_bar } from "../components/nav_bar.js";

export function group_new_page() {
	return html`<div class="flex flex-col gap-4">
	<${nav_bar}/>
	<form
	    class="p-4 flex flex-col gap-2 justify-center items-center"
	  >
	    <div class="text-lg font-semibold">Welcome to Okane!</div>

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
	  </form>			
	</div>
`;
}

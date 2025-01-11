import { effect, html, signal } from "htm";
import { $current_route } from "./store.js";

/**
 * @type {import('types/router.d.ts').RouteRecord}
 */
const PATH_TO_ROUTE = {
	login: async () => {
		const mod = await import("./pages/login_form.js");
		return mod.login_form;
	},
	home: async () => {
		const mod = await import("./pages/home.js");
		return mod.home;
	},
	group_create: async () => {
		const mod = await import('./pages/group_new.js')
		return mod.group_new_page
	}
};

/**
 * @type Map<string, import('types/router.d.ts').TPage>
 */
const ROUTE_CACHE = new Map();

const current_component = signal(null);

effect(() => {
	const curr_route = $current_route.value;

	if (curr_route === null) {
		current_component.value = null;
		return;
	}

	const from_cache = ROUTE_CACHE.get(curr_route);

	if (from_cache) {
		current_component.value = from_cache;
		return;
	}

	const component_loader = PATH_TO_ROUTE[curr_route];

	if (!component_loader) {
		throw new Error(`${curr_route} doesn't have a route record`);
	}

	component_loader().then((func) => {
		current_component.value = func;
		ROUTE_CACHE.set(curr_route, func);
	});
});

/**
 * 60 loc router with lazy loading of pages
 */
export function Router() {
	return html`
    ${current_component.value === null
			? null
			: html`<${current_component.value}></${current_component.value}>`}
  `;
}

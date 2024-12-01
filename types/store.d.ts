export interface IResourceState<T> {
	state: "loading" | "idle";
	data: T;
}

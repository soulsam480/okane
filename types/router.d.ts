/**
 *  render function of a page
 */
export type TPage = () => any;

export type RouteRecord = Record<string, () => Promise<TPage>>;

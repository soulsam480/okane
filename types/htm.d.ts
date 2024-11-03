import type { Signal, ReadonlySignal } from "@preact/signals-core";

declare module "htm" {
  export * from "@preact/signals-core";

  export function html(
    strings: TemplateStringsArray,
    ...values: Array<string | number | Signal<any> | ReadonlySignal<any>>
  ): any;
}

# okane

> money

## Goals
- simple to develop and maintain
- try as many new tech as possible with speed and simplicity in mind

## How it works ?
### server side
- app is written in gleam (:heart:)
- wisp is the http routing layer
  - it follows a loose rails structure
  - so requests flow in the following order
  - hooks <- can early terminate requests
  - router <- resource specific modules which export a controller method
  - serializer <- serialize DB records to json
  - response
- for DB, sqlight is used, queries via cake
- DB records are represented as gleam records, with builder pattern for ops like insert, select etc.
- radiate for hot reloading during development

### client side
- app is served from priv/ui on /
- only session is hydrated on page load
- components and re-render via preact + htm + signals
- styles are tailwind + daisy UI

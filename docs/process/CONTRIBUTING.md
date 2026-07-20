# Contributing to Atlas

## Adding a New Resolver
- Add the resolver under the appropriate layer namespace.
- Keep resolver logic focused on collecting context only.
- Do not embed decision logic inside the resolver.

## Writing an ADR
- Create a new file under docs/adr.
- Use the short ADR format: Status, Context, Decision, Consequences.
- Add the ADR when a design decision materially affects future development.

## Preserving Architecture Rules
- Keep RuntimeContext immutable.
- Keep the dependency direction consistent: Registry -> Resolver -> Context -> Decision -> Execution -> Interface.
- Add or update architecture tests when layer boundaries change.

## Testing Expectations
- Add unit tests for new behavior.
- Add or update architecture tests when structure changes.

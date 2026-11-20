# BirdWalk Agent Instructions

BirdWalk is a small bird-identification game built and maintained by a solo
developer.

Read `PRODUCT.md` before beginning work. It defines the product requirements and
scope.

Our goal is to build a simple, understandable application that is enjoyable to
maintain.

## Technology

- Ruby on Rails for the backend, API, and content administration.
- PostgreSQL for persistent data.
- React with TypeScript and Vite for the public-facing game.
- Prefer a single repository and deployment.
- Use conventional Rails and React patterns.

Do not introduce additional frameworks, services, or major dependencies without
discussing them first.

## Working Together

- Work on one small, clearly defined task at a time.
- Before making changes, briefly explain what you intend to do.
- Ask for approval before making architectural decisions or introducing
  dependencies.
- Ask questions rather than guessing when requirements are ambiguous.
- Do not implement features beyond the requested scope.
- Do not make unrelated changes.
- Do not commit code unless explicitly asked.

For routine implementation details, make reasonable decisions without asking
permission for every step.

## Simplicity

- Prefer straightforward, conventional solutions.
- Avoid unnecessary abstractions, configuration, and indirection.
- Do not build infrastructure for hypothetical future requirements.
- Do not introduce authentication, player tracking, analytics, background jobs,
  or additional services unless explicitly requested.
- Favor code that a solo developer can understand and modify without an agent.

Administrative access must be protected, but players do not need accounts.

## Database and Content

- Use Rails migrations and Active Record to manage the database.
- PostgreSQL is the source of truth for application content.
- Content must be manageable through the Rails admin interface.
- Do not introduce separate JSON content stores, custom seeding pipelines, or
  content-generation scripts without approval.
- Treat photograph licensing and attribution as essential data, not optional
  metadata.

## Testing and Verification

- Write focused tests for important application behavior.
- Run relevant tests after making changes.
- Do not claim something works unless it has been tested.
- Explain how I can verify new functionality in the browser.
- Never modify production data or run production migrations without explicit
  approval.

## Completing a Task

At the end of each task, briefly report:

- What changed.
- What tests were run and their results.
- How I can verify the change.
- Any decisions or issues that remain.

Stop after completing the requested task. Wait for further instructions before
starting another feature.

# BirdWalk

A daily bird-identification game. See `PRODUCT.md` for requirements.

Rails serves the JSON API and admin; React (TypeScript, built with Vite via
`vite_rails`) powers the public game in `app/frontend`.

## Requirements

- Ruby (see `.ruby-version`)
- Node.js and npm
- PostgreSQL

## Setup

```sh
bin/setup
```

This installs gems and npm packages, prepares the database, and starts the app.

## Development

```sh
bin/dev
```

Runs the Rails server and the Vite dev server together. Visit
http://localhost:3000.

## Checks

```sh
bin/rails test
npm run typecheck
bin/rubocop
```

## Deployment

The `Dockerfile` builds a single production image. Vite assets are compiled
during `assets:precompile`. The app needs a PostgreSQL database
(`DATABASE_URL`) and `RAILS_MASTER_KEY`.

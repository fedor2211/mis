# AGENTS.md

## Repo Shape
- Rails 8.1 API-only app (`config.api_only = true`); controllers should inherit from `ActionController::API`, not full Rails controllers unless middleware/views are intentionally added.
- Ruby version is pinned to `ruby-4.0.1` in `.ruby-version` and mirrored by the production `Dockerfile`.
- PostgreSQL is the only configured database. Development/test use `mis_development` and `mis_test`; production splits primary/cache/queue/cable databases.
- There is no JavaScript package manifest or asset pipeline setup in this repo; do not assume npm/yarn commands exist.

## Commands
- Install/update dependencies and prepare the dev DB without starting the server: `bin/setup --skip-server`.
- Start the app: `bin/dev` (it execs `bin/rails server`; no Procfile or JS watcher is involved).
- Full local verification source of truth: `bin/ci`.
- CI-equivalent focused checks: `bin/rubocop`, `bin/bundler-audit`, `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`, `bin/rspec`, and `env RAILS_ENV=test bin/rails db:seed:replant`.
- GitHub Actions test job uses PostgreSQL on localhost and runs `RAILS_ENV=test DATABASE_URL=postgres://postgres:postgres@localhost:5432 bin/rails db:test:prepare spec`.
- Run one RSpec file with `bin/rspec spec/path/to/file_spec.rb`; add `:line` for a single example.
- Generate OpenAPI schemas from request specs with `OPENAPI=1 bin/rspec spec/requests`; generated files belong under `swagger/`.

## Database And Services
- Devcontainer sets `DB_HOST=postgres` and runs `bin/setup` after create; outside it, `config/database.yml` uses the local Unix socket unless `DB_HOST` is set.
- Tests require a reachable PostgreSQL server; no Redis service is configured. Rails uses Solid Cache, Solid Queue, and Solid Cable instead.
- Production job processing is configured through Solid Queue. `bin/jobs` starts the Solid Queue CLI, while `config/deploy.yml` currently sets `SOLID_QUEUE_IN_PUMA=true` for single-server web deployments.

## Style And Security
- Use repo binstubs instead of raw gem commands; `bin/rubocop` forces `.rubocop.yml`, `bin/brakeman` adds `--ensure-latest`, and `bin/bundler-audit` uses `config/bundler-audit.yml` by default.
- RuboCop inherits `rubocop-rails-omakase`; avoid adding local style rules unless the repo needs a real exception.
- `config/ci.rb` is stricter than the GitHub workflow for Brakeman and also verifies seeds; prefer `bin/ci` before handing off broad changes.

## Application Structure
- Keep models focused on persistence concerns and lightweight declarations such as associations and enums; do not put business validation flows in models.
- Keep controllers thin: parameter extraction, service delegation, and JSON rendering only. Move business logic, filtering, persistence orchestration, and branching workflows to service objects.
- Service objects should inherit from `ApplicationService` and expose `.call(*)`, with instance `#call` raising `NotImplementedError` in the base class.
- Put request/input validation in dry contracts using `dry-validation` and `dry-schema`, typically under `app/contracts/<domain>/`. Prefer contracts over Active Record validations for API request validation.
- Serializers should inherit from `ApplicationSerializer`, which inherits from `ActiveModel::Serializer` and centralizes ISO 8601 formatting for `Time`, `ActiveSupport::TimeWithZone`, and `Date` attributes.

## Testing Notes
- Test framework is RSpec Rails (`spec/rails_helper.rb`) with FactoryBot available through `factory_bot_rails`.
- Add focused RSpec coverage when introducing behavior, including contract specs for dry-validation contracts and request specs for API behavior.
- Use FactoryBot factories for persisted test records instead of direct `Model.create!` calls in specs.
- Prefer `let`, `let!`, and `subject` for RSpec setup and actions; avoid defining custom helper methods inside specs unless there is a strong reuse need.

## Deployment Notes
- `Dockerfile` is production-oriented; it runs `bin/rails db:prepare` on server startup through `bin/docker-entrypoint`.
- Kamal config is present in `config/deploy.yml`, but placeholder hosts/registry remain; do not treat deployment targets as real without user confirmation.

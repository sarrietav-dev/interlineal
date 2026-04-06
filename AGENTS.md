# Interlineal - Agent Instructions

Rails 8.0 interlinear Bible application. Spanish Reina Valera 1960 with Greek/Hebrew interlinear translations and Strong's concordance.

## Quick Commands

| Task | Command |
|------|---------|
| Dev server | `bin/dev` (runs Rails + Tailwind watch) |
| Run tests | `bin/rails test` |
| Run single test | `bin/rails test test/path/to_test.rb:line` |
| Run system tests | `bin/rails test:system` |
| Lint | `bin/rubocop` or `bin/rubocop -a` (auto-fix) |
| Security scan | `bin/brakeman --no-pager` |
| JS audit | `bin/importmap audit` |
| Setup DB | `bin/rails db:setup` (uses seeds + pre-populated data) |
| Reset DB | `bin/rails db:drop db:setup` |

## Architecture

### Entry Points
- **Main controller**: `app/controllers/bible_controller.rb` - serves all Bible views (books, chapters, verses, slideshow, search)
- **Routes**: `config/routes.rb` - RESTful-ish paths like `/books/:book_id/chapters/:chapter_number/verses/:verse_number`
- **Root**: Redirects to first verse (Génesis 1:1)

### Models (ActiveRecord)
- `Book` - Bible books (name, abbreviation, testament)
- `Chapter` - belongs to book, has chapter_number
- `Verse` - Spanish RV1960 text, belongs to chapter
- `Word` - Greek/Hebrew words with Strong's numbers, belongs to verse
- `Strong` - Strong's concordance definitions

### Frontend
- **Hotwire stack**: Turbo + Stimulus (no React/Vue)
- **CSS**: Tailwind CSS via `tailwindcss-rails`
- **JS**: Importmap (no webpack/esbuild), see `config/importmap.rb`
- **Views**: ERB in `app/views/bible/`
- **Controllers**: `BibleController`, `NavigationController`, `SettingsController`

## Database

### Multi-database Setup (SQLite3)
```yaml
primary:    storage/development.sqlite3      # Books, chapters, verses, words
cache:      storage/development_cache.sqlite3  # Solid Cache
```

Production adds:
- `queue`: Solid Queue for background jobs
- `cable`: Solid Cable for Action Cable

### Data Pre-populated
The Bible data is pre-populated in `interlineal.db` at repo root. `db/seeds.rb` exists but the actual data comes from a pre-built database file.

### Migrations
- Main migrations: `db/migrate/`
- Cache migrations: `db/cache_migrate/`
- Queue migrations: `db/queue_migrate/`
- Cable migrations: `db/cable_migrate/`

## Testing (Minitest)

### Framework
- **Test runner**: `bin/rails test` (Minitest, Rails default)
- **System tests**: Capybara + Selenium WebDriver
- **Fixtures**: YAML fixtures in `test/fixtures/`
- **Config**: `test/test_helper.rb`

### Test Types
- **Model tests**: `test/models/`
- **Controller tests**: `test/controllers/`
- **Integration tests**: `test/integration/`
- **System tests**: `test/system/` (browser-based end-to-end)

### CI Test Command
```bash
bin/rails db:test:prepare test test:system
```

## Caching Strategy

Aggressive multi-layer caching throughout:
- `Rails.cache.fetch` for DB queries (6-hour TTL)
- HTTP caching with `stale?`/`expires_in` in controllers
- Fragment caching in views
- Solid Cache (SQLite-backed) instead of Redis

Cache keys follow pattern: `"chapter_verses_#{chapter_id}"`, `"all_books_with_chapters"`

## Code Style

- **Linter**: Rubocop with `rubocop-rails-omakase` rules
- **Config**: `.rubocop.yml` (just inherits from gem)
- **Enforcement**: CI fails on lint errors
- **Auto-fix**: `bin/rubocop -a`

## Development Notes

### No API
This is a traditional server-rendered Rails app using Hotwire. No JSON API endpoints - all interactivity uses Turbo Frames/Streams and Stimulus.

### Routes to Know
```
GET  /                                          → bible#index (redirects to Génesis 1:1)
GET  /books/:book_id                            → bible#show_book
GET  /books/:book_id/chapters/:chapter_number   → bible#show_chapter
GET  /books/:book_id/chapters/:chapter_number/verses/:verse_number → bible#show_verse
GET  /slideshow/:book_id/:chapter_number/:verse_number → bible#slideshow (presentation mode)
GET  /search                                    → bible#search
GET  /strongs/:strong_number                    → bible#strong_definition
```

### Settings/Navigation
- Settings managed via `SettingsController` with session storage
- Navigation via `NavigationController` using Turbo Frames

## Deployment

- **Containerized**: Dockerfile present
- **Deployment**: Kamal configured (`config/deploy.yml`)
- **Production DB**: SQLite3 in `storage/` (persistent volume)

## File Locations

| What | Where |
|------|-------|
| Main controller | `app/controllers/bible_controller.rb` |
| Models | `app/models/` (book.rb, chapter.rb, verse.rb, word.rb, strong.rb) |
| Views | `app/views/bible/` |
| Stimulus controllers | `app/javascript/controllers/` |
| Tests | `test/` |
| Fixtures | `test/fixtures/` (words.yml, verses.yml, books.yml, chapters.yml, strongs.yml) |
| Pre-built DB | `interlineal.db` |

## Important Constraints

1. **Use Minitest, not RSpec**: This project uses Minitest (Rails default)
2. **Database is pre-populated**: Don't expect to create Bible data via migrations
3. **Multi-database**: Cache uses separate SQLite file (Solid Cache)
4. **No Redis**: Uses Solid Cache/Solid Queue (SQLite-based) instead
5. **Hotwire, not API**: All interactions go through Turbo/Stimulus
6. **Spanish content**: Bible text is Spanish RV1960

# Solid Cache Setup Notes

## Current Status

Solid Cache is properly configured and working in this application!

- ✅ Production: Uses Solid Cache (database-backed, persistent)
- ✅ Development: Uses memory_store (fast, simple)
- ✅ Test: Uses memory_store
- ✅ Cache database configured and migrated
- ✅ Fragment caching implemented throughout views
- ✅ Controller-level caching optimized

## Configuration

### Database Configuration (`config/database.yml`)

The cache database is configured for all environments:

```yaml
development:
  primary:
    database: storage/development.sqlite3
  cache:
    database: storage/development_cache.sqlite3
    migrations_paths: db/cache_migrate

test:
  primary:
    database: storage/test.sqlite3
  cache:
    database: storage/test_cache.sqlite3
    migrations_paths: db/cache_migrate

production:
  primary:
    database: storage/production.sqlite3
  cache:
    database: storage/production_cache.sqlite3
    migrations_paths: db/cache_migrate
```

### Cache Store Configuration

**Production** (`config/environments/production.rb`):
```ruby
config.cache_store = :solid_cache_store
```

**Development** (`config/environments/development.rb`):
```ruby
config.cache_store = :memory_store
```

Can be changed to `:solid_cache_store` if you want to test production-like caching behavior in development.

### Cache Configuration (`config/cache.yml`)

```yaml
default: &default
  store_options:
    max_size: <%= 256.megabytes %>
    namespace: <%= Rails.env %>

development:
  database: cache
  <<: *default

test:
  database: cache
  <<: *default

production:
  database: cache
  <<: *default
```

## Initial Setup Steps (Already Done)

1. ✅ `rails solid_cache:install` - Installed Solid Cache
2. ✅ Configured `config/database.yml` with cache databases
3. ✅ Created `db/cache_migrate/` directory
4. ✅ Migrated cache database schema
5. ✅ Configured environment-specific cache stores

## Testing Solid Cache

To verify Solid Cache is working:

```bash
# Test basic functionality
rails runner "Rails.cache.write('test', 'value'); puts Rails.cache.read('test')"

# Test with Solid Cache explicitly (even in dev)
RAILS_ENV=development rails runner "
  Rails.cache = ActiveSupport::Cache.lookup_store(:solid_cache_store)
  Rails.cache.write('solid_test', 'Hello!')
  puts Rails.cache.read('solid_test')
"

# Check cache database
sqlite3 storage/development_cache.sqlite3 "SELECT COUNT(*) FROM solid_cache_entries;"
```

## Using Solid Cache in Development

If you want to use Solid Cache in development (to test production-like behavior):

1. Edit `config/environments/development.rb`:
   ```ruby
   config.cache_store = :solid_cache_store
   ```

2. Restart the Rails server

3. Cache will now persist across server restarts

## Production Deployment

When deploying to production:

1. Ensure `storage/` directory exists and is writable
2. Run `rails db:prepare` to create and migrate all databases including cache
3. Solid Cache will automatically use the production cache database

## Cache Management

Use the provided rake tasks:

```bash
# Clear all cache
rails cache:clear

# View cache stats
rails cache:stats

# Warm up cache
rails cache:warmup

# Clear specific caches
rails cache:clear_verses
rails cache:clear_search
```

## Troubleshooting

### "No unique index found for key_hash"

This error occurred during initial setup due to schema version mismatch. **Already fixed** by:
1. Creating proper migration in `db/cache_migrate/`
2. Marking migration as run in schema_migrations
3. Ensuring unique index on `key_hash` column exists

### Cache not persisting

If cache doesn't persist in production:
- Check that `cache_store` is set to `:solid_cache_store`
- Verify cache database exists: `ls -la storage/*_cache.sqlite3`
- Check database permissions
- Review logs for Solid Cache errors

### "table already exists" error

If you get this error when migrating:
```bash
# Check if table exists
sqlite3 storage/production_cache.sqlite3 ".tables"

# Mark migration as run
sqlite3 storage/production_cache.sqlite3 \
  "INSERT INTO schema_migrations (version) VALUES ('20241121000001');"
```

## Performance Tuning

Adjust cache size limits in `config/cache.yml`:

```yaml
store_options:
  max_size: <%= 512.megabytes %>  # Increase if you have space
  max_age: <%= 7.days.to_i %>      # How long to keep entries
```

## Monitoring

In production, monitor:
- Cache database size: `du -h storage/production_cache.sqlite3`
- Cache hit rates: Check Rails logs
- Cache entry count: Use `rails cache:stats`

## Why Memory Store in Development?

We use `:memory_store` in development because:
1. **Faster** - No disk I/O, instant cache operations
2. **Simpler** - No database to manage or migrate
3. **Auto-cleanup** - Cache clears on server restart
4. **Sufficient** - Development doesn't need persistent cache

Production uses Solid Cache because:
1. **Persistent** - Survives server restarts and deployments
2. **Larger** - Can cache much more data than RAM allows
3. **Shared** - Multiple processes can share cache
4. **Reliable** - Database-backed durability

## References

- [Solid Cache GitHub](https://github.com/rails/solid_cache)
- [Rails Caching Guide](https://guides.rubyonrails.org/caching_with_rails.html)
- [CACHING.md](./CACHING.md) - Our caching strategy documentation

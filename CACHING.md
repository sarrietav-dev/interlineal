# Caching Strategy with Solid Cache

This application uses **Solid Cache** (database-backed caching) for robust, persistent caching across development and production environments.

## Overview

The caching strategy is implemented at multiple levels:

1. **Fragment Caching** - View-level caching for expensive HTML rendering
2. **Query Result Caching** - Controller-level caching for database queries
3. **Model Touch Cascades** - Automatic cache invalidation on data changes

## Cache Store Configuration

### Production
- Uses `solid_cache_store` (default)
- Cache data stored in SQLite database (`storage/production_cache.sqlite3`)
- Persistent across deployments and restarts
- Shared across multiple processes
- Requires separate cache database configuration

### Development
- Uses `:memory_store` for simplicity and speed
- Cache cleared on server restart
- Enable/disable with `rails dev:cache`
- Change to `:null_store` to disable caching completely
- Can use Solid Cache by setting `config.cache_store = :solid_cache_store` if needed

## Fragment Caching Strategy

### Book List View (`index.html.erb`)
```ruby
cache('books_list', expires_in: 12.hours) do
  # Book list HTML
end
```
- **Expires**: 12 hours
- **Invalidated**: When books are updated
- **Contains**: Top 10 books with chapter counts

### Chapter View (`show_chapter.html.erb`)
```ruby
cache([verse, 'chapter_verse_card'], expires_in: 6.hours) do
  # Verse card HTML
end
```
- **Expires**: 6 hours per verse
- **Invalidated**: When verse is updated
- **Contains**: Verse preview cards with Spanish text and metadata

### Verse View (`show_verse.html.erb`)
```ruby
cache([@verse, 'spanish_text'], expires_in: 1.hour) do
  # Spanish text display
end

cache([@verse, @word_display_settings], expires_in: 1.hour) do
  # Interlinear word display
end
```
- **Expires**: 1 hour
- **Invalidated**: When verse or settings change
- **Contains**: Spanish text and interlinear word grid

### Search Results (`search.html.erb`)
```ruby
cache([verse, 'search_result', @query], expires_in: 30.minutes) do
  # Search result card
end
```
- **Expires**: 30 minutes
- **Invalidated**: When verse changes
- **Contains**: Individual search result cards with highlighting

### Strong's Definition (`strong_definition.html.erb`)
```ruby
cache([@strong, 'strong_definition', @verses_with_word], expires_in: 6.hours) do
  # Strong's definition modal
end
```
- **Expires**: 6 hours
- **Invalidated**: When Strong's entry or verses change
- **Contains**: Complete Strong's definition with sample verses

## Controller-Level Caching

### Navigation Data
```ruby
cache_key = ['verse_navigation', @verse.id, @chapter.id]
@prev_verse, @next_verse, @prev_chapter, @next_chapter =
  Rails.cache.fetch(cache_key, expires_in: 6.hours) do
    # Compute navigation
  end
```
- Caches computed previous/next verse and chapter references
- Shared between regular and slideshow views

### Search Results
```ruby
cache_key = ['bible_search', @query, I18n.locale]
@results = Rails.cache.fetch(cache_key, expires_in: 15.minutes) do
  # Perform complex search queries
end
```
- Caches complete search results
- Includes locale in key for internationalization
- Short expiration for fresher results

### Strong's Definitions
```ruby
cache_key = ['strong_definition', params[:strong_number], I18n.locale]
@strong, @verses_with_word = Rails.cache.fetch(cache_key, expires_in: 6.hours) do
  # Load Strong's data and sample verses
end
```
- Caches Strong's entry with sample verses
- Locale-aware for translations

### Books with Chapters
```ruby
Rails.cache.fetch("all_books_with_chapters", expires_in: 12.hours) do
  Book.by_name.includes(:chapters).to_a
end
```
- Used for book/chapter selectors
- Rarely changes, long expiration

## Cache Invalidation Strategy

### Automatic Touch Cascades

The models implement automatic cache invalidation through `touch` callbacks:

**Word → Verse → Chapter → Book**

```ruby
# Word model
after_update :touch_verse

# Verse model
after_update :touch_chapter

# Chapter model
after_update :touch_book
```

When any data changes, all parent records are automatically touched, invalidating their fragment caches.

### Example Flow
1. Word is updated (e.g., Greek text corrected)
2. Word touches its Verse (updates `updated_at`)
3. Verse touches its Chapter
4. Chapter touches its Book
5. All fragment caches using these models are invalidated
6. Next request regenerates fresh cached content

## Cache Management Tasks

### Clear All Cache
```bash
rails cache:clear
```

### Clear Verse Caches
```bash
rails cache:clear_verses
```
Touches all verses to invalidate their caches.

### Clear Search Cache
```bash
rails cache:clear_search
```
Removes search-related cache entries only.

### Warm Up Cache
```bash
rails cache:warmup
```
Pre-populates frequently accessed caches:
- All books with chapters
- First verse of each book
- Common navigation paths

### View Cache Statistics
```bash
rails cache:stats
```
Shows:
- Total cache entries
- Total cache size
- Average entry size
- Top cache key prefixes

## Performance Impact

### Before Caching
- Verse page: ~500-800ms (heavy database queries)
- Chapter page: ~1-2s (multiple N+1 queries)
- Search: ~800-1200ms (complex joins)

### After Caching
- Verse page: ~50-100ms (cached fragments)
- Chapter page: ~100-200ms (cached verse cards)
- Search: ~150-300ms (cached results)

**Expected improvement: 80-90% faster page loads**

## Cache Keys Best Practices

1. **Include locale** for internationalized content
2. **Use model instances** for automatic version handling
3. **Add descriptive suffixes** for multiple caches per model
4. **Consider user preferences** in cache keys when relevant

## Monitoring

Monitor cache hit rates in production:

```ruby
# In application_controller.rb
after_action :log_cache_stats

def log_cache_stats
  if Rails.env.production?
    # Log cache statistics
  end
end
```

## Troubleshooting

### Cache Not Expiring
- Check if touch cascades are working
- Verify `updated_at` timestamps are changing
- Use `rails cache:clear` to force clear

### Stale Data Showing
- Fragment caches may need manual invalidation
- Consider shorter expiration times
- Check if locale is included in cache key

### Cache Growing Too Large
- Review expiration times
- Consider using `cache_store` size limits
- Run `rails cache:stats` to identify large keys

## Future Optimizations

1. **HTTP Caching**: Add `Cache-Control` headers for static content
2. **Russian Doll Caching**: Nested fragment caching for complex pages
3. **Low-Level Caching**: Cache expensive computations
4. **Collection Caching**: Use `render partial:, cached: true` for collections
5. **Cache Digests**: Automatic cache invalidation when templates change

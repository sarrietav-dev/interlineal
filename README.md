# Interlineal - Interlinear Bible App

A Rails-based interlinear Bible application providing Spanish Reina Valera 1960 text with Greek interlinear translations, Strong's concordance definitions, slideshow presentation mode, and comprehensive Bible study features.

## Overview

**Interlineal** is an interactive Bible study application that displays Spanish text alongside Greek interlinear translations on a word-by-word basis. Built with Ruby on Rails 8.0, it features a responsive design optimized for both desktop study and presentation modes.

### Key Features

- **Interlinear Display**: Spanish Reina Valera 1960 with Greek word-by-word translations
- **Strong's Concordance**: Integrated Strong's numbers and definitions
- **Presentation Mode**: Full-screen slideshow mode for teaching and presentations
- **Search Functionality**: Search across Spanish text, Greek/Hebrew words, and Strong's definitions
- **Navigation**: Intuitive verse-by-verse, chapter, and book navigation
- **Responsive Design**: Mobile-friendly interface with Tailwind CSS
- **Caching**: Redis-backed caching for optimal performance
- **Testing**: Comprehensive RSpec test suite with system tests

## Tech Stack

- **Backend**: Ruby 3.3.x, Rails 8.0.2
- **Database**: SQLite3 with optimized schema
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **State Management**: Rails session-based settings
- **Testing**: RSpec, Capybara, FactoryBot, Selenium WebDriver
- **Performance**: Solid Cache for caching
- **Development**: Debug gem, Rubocop Rails Omakase

## Database Schema

The application uses a normalized database structure:

- **Books**: Bible books with testament classification
- **Chapters**: Chapter organization within books
- **Verses**: Individual verses with Spanish text
- **Words**: Greek/Hebrew words with Strong's numbers and translations
- **Strongs**: Strong's concordance definitions and linguistic data

## Setup

### Prerequisites

- Ruby 3.3.x
- Rails 8.0.2
- SQLite3

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd interlineal
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   bin/rails db:setup
   ```

4. **Start the development server**
   ```bash
   bin/dev
   ```

The application will be available at `http://localhost:3000`.

## Testing

### Run the test suite

```bash
bundle exec rspec
```

### Test Coverage

The application includes comprehensive tests:
- **Unit Tests**: Model validations, associations, and business logic
- **Controller Tests**: HTTP responses and routing
- **System Tests**: End-to-end user interactions with Capybara
- **Request Tests**: API-like functionality testing

## Development

### Code Quality

- **Linting**: Uses Rubocop Rails Omakase for consistent code style
- **Security**: Brakeman for security vulnerability scanning
- **CI/CD**: GitHub Actions workflow for automated testing

### Key Directories

- `app/controllers/bible_controller.rb` - Main Bible interface controller
- `app/models/` - ActiveRecord models for Bible data
- `app/views/bible/` - ERB templates for Bible display
- `app/javascript/controllers/` - Stimulus controllers for interactivity
- `spec/` - RSpec test suite
- `db/` - Database schema and migrations

## API Routes

The application provides a RESTful interface:

```
GET  /                                                    # Homepage (redirects to first verse)
GET  /books/:book_id                                      # Book overview
GET  /books/:book_id/chapters/:chapter_number             # Chapter view
GET  /books/:book_id/chapters/:chapter_number/verses/:verse_number  # Verse view
GET  /slideshow/:book_id/:chapter_number/:verse_number    # Presentation mode
GET  /search                                              # Search functionality
GET  /strongs/:strong_number                              # Strong's definitions
```

## Performance

- **Caching**: Aggressive caching of Bible data, navigation, and expensive queries
- **Database Optimization**: Indexed columns and efficient associations
- **Fragment Caching**: View-level caching for frequently accessed content
- **Lazy Loading**: Optimized database queries with includes

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for your changes
5. Run the test suite (`bundle exec rspec`)
6. Commit your changes (`git commit -am 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Deployment

The application can be deployed using:
- **Docker**: Dockerfile included for containerization
- **Kamal**: Configured for deployment with Kamal
- **Traditional hosting**: Compatible with standard Rails hosting

## CI/CD

Continuous Integration runs on GitHub Actions and includes:
- RSpec test suite execution
- Code quality checks with Rubocop
- Security scanning with Brakeman
- Multi-environment testing

## License

This project is available for educational and non-commercial use. See project documentation for detailed licensing information.

---

For detailed development tasks and roadmap, see [TASKS.md](TASKS.md).

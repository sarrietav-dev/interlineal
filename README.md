# README

Setup

- Ruby: 3.3.x
- Rails: 8.0.2

Install dependencies:

```
bundle install
bin/rails db:setup
bin/dev
```

Tests (RSpec):

```
bundle exec rspec
```

CI runs on GitHub Actions (see `.github/workflows/ci.yml`).

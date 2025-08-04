# Interlinear Bible App - Task List

## Project Overview

Building a interlinear bible app in Spanish using Reina Valera 1960 with Greek interlinear word-by-word translation. The app will support slideshow projection, pronunciation, Strong's codes, audio playback, and flexible language/translation switching.

## Phase 1: Project Setup and Core Infrastructure

### 1.1 Project Initialization

- [x] Initialize Rails
- [ ] Set up project structure for bible app
- [ ] Configure TypeScript for strict typing
- [ ] Set up ESLint and Prettier for code quality
- [ ] Create component library structure

### 1.2 Data Structure Design

- [ ] Design interfaces for:
  - [ ] Bible verse structure
  - [ ] Interlinear word data
  - [ ] Strong's code mapping
  - [ ] Audio pronunciation data (Can be made for later).
  - [ ] Translation metadata
- [ ] Create mock data structure for Gospel of John
- [ ] Design JSON schema for bible data

The data has to be saved in an sqlite database.

### 1.3 UI/UX Foundation

- [ ] Set up CSS framework (Tailwind CSS)
- [ ] Create responsive layout system
- [ ] Design slideshow/presentation mode layout
- [ ] Create navigation component
- [ ] Design verse display component

### 1.4 Data Scraping and Import

- [ ] Create web scraping script for [Bibliatodo.com](https://www.bibliatodo.com/biblia-interlineal/juan-1)
- [ ] Extract Greek interlinear text with word-by-word alignment
- [ ] Scrape Strong's codes for each Greek word
- [ ] Extract Reina Valera 1960 Spanish translation
- [ ] Parse verse structure and chapter organization
- [ ] Create data transformation pipeline to SQLite format
- [ ] Implement error handling for missing or malformed data
- [ ] Add data validation for scraped content
- [ ] Create backup/restore functionality for scraped data
- [ ] Document scraping process and data sources

## Phase 2: Core Bible Functionality

### 2.1 Bible Data Implementation

- [ ] Create Gospel of John data structure
- [ ] Implement Reina Valera 1960 Spanish text
- [ ] Add Greek interlinear text (word-by-word)
- [ ] Map Strong's codes to Greek words
- [ ] Create pronunciation data for Greek words
- [ ] Add audio file references for pronunciation (later)

### 2.2 Verse Display System

- [ ] Create verse rendering component
- [ ] Implement interlinear word alignment
- [ ] Add Strong's code display
- [ ] Create pronunciation toggle system
- [ ] Implement audio playback functionality
- [ ] Add word highlighting on hover/click

### 2.3 Navigation System

- [ ] Create chapter navigation
- [ ] Implement verse-by-verse navigation
- [ ] Add bookmark functionality
- [ ] Create search functionality
- [ ] Add verse reference display

## Phase 3: Presentation/Slideshow Mode

### 3.1 Slideshow Interface

- [ ] Design full-screen presentation layout
- [ ] Create slideshow controls
- [ ] Implement auto-advance functionality
- [ ] Add manual navigation controls
- [ ] Create presentation timer

### 3.2 Multi-Screen Support

- [ ] Implement Tauri multi-window support
- [ ] Create presentation window
- [ ] Add window synchronization
- [ ] Implement presenter view
- [ ] Add screen detection and selection

### 3.3 Presentation Features

****- [ ] Add zoom functionality
- [ ] Implement text size adjustment
- [ ] Create theme switching (light/dark)
- [ ] Add transition effects
- [ ] Implement presenter notes

## Phase 4: Advanced Features

### 4.1 Audio Integration

- [ ] Implement audio file loading
- [ ] Create audio playback controls
- [ ] Add volume control
- [ ] Implement audio synchronization
- [ ] Add audio download functionality

### 4.2 Translation System

- [ ] Design translation switching interface
- [ ] Implement translation loading system
- [ ] Add translation comparison view
- [ ] Create translation metadata management
- [ ] Add custom translation import

### 4.3 Hebrew Support Preparation

- [ ] Design Hebrew text rendering system
- [ ] Create Hebrew font support
- [ ] Implement right-to-left text layout
- [ ] Add Hebrew pronunciation data structure
- [ ] Create Hebrew Strong's code mapping

## Phase 5: Data Management

### 5.1 Local Data Storage

- [ ] Implement local file system for bible data
- [ ] Create data caching system
- [ ] Add offline functionality
- [ ] Implement data validation
- [ ] Create backup/restore functionality

### 5.2 Settings and Preferences

- [ ] Create settings management system
- [ ] Add user preferences storage
- [ ] Implement theme customization
- [ ] Add language preference settings
- [ ] Create presentation preferences

## Phase 6: Polish and Optimization

### 6.1 Performance Optimization

- [ ] Optimize verse rendering
- [ ] Implement virtual scrolling for large texts
- [ ] Add lazy loading for audio files
- [ ] Optimize memory usage
- [ ] Add performance monitoring

### 6.2 User Experience

- [ ] Add keyboard shortcuts
- [ ] Implement gesture controls
- [ ] Create help/tutorial system
- [ ] Add accessibility features
- [ ] Implement error handling

### 6.3 Testing and Quality Assurance

- [ ] Write unit tests for core components
- [ ] Add integration tests
- [ ] Perform cross-platform testing
- [ ] Conduct user testing
- [ ] Add error logging

## Phase 7: Deployment and Distribution

### 7.1 Build and Packaging

- [ ] Configure Tauri build settings
- [ ] Create installer packages
- [ ] Add auto-update functionality
- [ ] Implement code signing
- [ ] Create distribution scripts

### 7.2 Documentation

- [ ] Write user manual
- [ ] Create developer documentation
- [ ] Add inline code comments
- [ ] Create setup instructions
- [ ] Write troubleshooting guide

## Technical Requirements

### Dependencies to Add

- [ ] `@tauri-apps/plugin-fs` - File system operations
- [ ] `@tauri-apps/plugin-window` - Multi-window support
- [ ] `@tauri-apps/plugin-shell` - External audio playback
- [ ] `@pinia/nuxt` - Pinia state management for Nuxt
- [ ] `@nuxtjs/tailwindcss` - Tailwind CSS for Nuxt
- [ ] `@nuxtjs/color-mode` - Dark/light mode support
- [ ] `@vueuse/nuxt` - Vue composition utilities
- [ ] `lucide-vue-next` - Icons
- [ ] `@vueuse/motion` - Animations
- [ ] `@nuxt/test-utils` - Testing utilities

### Data Sources

- [ ] Reina Valera 1960 Spanish text
- [ ] Greek interlinear text (SBLGNT or similar)
- [ ] Strong's Concordance data
- [ ] Greek pronunciation audio files
- [ ] Hebrew text and pronunciation (future)

## Priority Order

1. **Phase 1** - Foundation (Critical)
2. **Phase 2** - Core functionality (Critical)
3. **Phase 3** - Presentation mode (High priority)
4. **Phase 4** - Advanced features (Medium priority)
5. **Phase 5** - Data management (Medium priority)
6. **Phase 6** - Polish (Low priority)
7. **Phase 7** - Deployment (Low priority)

## Notes

- Start with Gospel of John as MVP
- Focus on Spanish + Greek interlinear first
- Prepare architecture for Hebrew support
- Prioritize presentation/slideshow functionality
- Ensure offline functionality from the start
- Use Nuxt 4's built-in features for routing, SSR, and development
- Leverage Vue 3 Composition API for better code organization
- Utilize Pinia for state management instead of Vuex
- Take advantage of Nuxt's auto-imports for better developer experience

# Project Overview

[cite\_start]This is a Ruby on Rails 8 application for the **Sustainable Software Manifesto**, deployed as `sustainablemanifesto.org`[cite: 336]. The application serves as a content-focused platform for a software development manifesto.

When editing code, follow The Rails Way. Favor conventions over abstractions. Use ERB partials for UI elements, Turbo + Stimulus for interactivity, and Tailwind for styling. Do not add React or other frontend frameworks. Avoid introducing new gems unless explicitly instructed. [cite\_start]Javascript libraries are imported using `importmap`[cite: 3, 419].

# Core Domain Model

The application is currently a static content site and does not have a complex domain model. [cite\_start]The primary structure consists of static pages defined as actions in the `ApplicationController` and rendered via corresponding view templates in `app/views/application/`[cite: 1, 9, 30, 55, 83, 101, 119, 245, 272]. [cite\_start]There are no user-related models at this time[cite: 470].

## Architecture Patterns

When refactoring, if Separation of Concerns is not established in a file, create a dedicated commit to establish SoC first (tests included), before implementing further changes.

## Controller Structure

  - Controllers are intended to be thin. [cite\_start]The `ApplicationController` currently handles all static page routes[cite: 1].

## Services

  - The project currently has no Service objects, as the logic is simple enough to be handled within controllers and views.

## Frontend

  - [cite\_start]Uses Hotwire (Turbo + Stimulus) for interactivity[cite: 3].
  - [cite\_start]Import maps for JavaScript (no bundler by default)[cite: 419].
  - [cite\_start]Tailwind CSS for styling[cite: 312].
  - Reusable UI elements should be implemented as ERB partials.

# Common Development Commands

## Testing

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/application_system_test_case.rb

# Run specific test
bin/rails test test/controllers/application_controller_test.rb:4
```

## Rails Console

```bash
bin/rails console
```

## Code Quality

```bash
# Run Rubocop
rubocop

# Auto-fix Rubocop issues
rubocop -a

# Security audit
bundle exec brakeman
bundle exec bundler-audit
```

## Asset Management

```bash
# Update JavaScript imports
bin/importmap pin <package>

# Watch Tailwind CSS (auto-runs with bin/dev)
bin/rails tailwindcss:watch

# Build Tailwind CSS for production
bin/rails tailwindcss:build
```

# Testing Notes

  - [cite\_start]Uses Minitest with minitest-rails[cite: 475].
  - Mocha for stubbing/mocking.
  - [cite\_start]Capybara + Selenium for system tests[cite: 475].
  - Test fixtures are located in `test/fixtures/`.

# Project-Specific Guidelines

## Rails Conventions for This Codebase

  - Follow The Rails Way - favor conventions over abstractions.
  - Controllers: Keep them thin.
  - UI: Use ERB partials for reusable view logic. Use Hotwire (Turbo + Stimulus) for interactivity.

## Code Quality

  - Always end tasks by running and resolving rubocop issues.
  - Use `rubocop -a` for auto-fixes.

## Commit Workflow

  - Never commit without being explicitly prompted.
  - Commit message format:
      - `feat(scope): concise description` for new features
      - `refactor(scope): concise description` for refactors
      - `fix(scope): concise description` for bug fixes
      - `chore(scope): concise description` for maintenance

## Development Process

  - Follow superpowers skills for TDD, debugging, planning, and collaboration workflows.
  - Brainstorming applies to: new features and complex refactors (not simple bug fixes).
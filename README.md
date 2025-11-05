# Sustainable software manifesto

A Ruby on Rails 8 application for the sustainable software manifesto, deployed as `sustainablemanifesto.org`.

## Tech Stack

- **Ruby on Rails 8.0.1**
- **Ruby 3.3.6**
- **SQLite** (production database)
- **Hotwire** (Turbo + Stimulus)
- **Tailwind CSS 4.0**
- **Kamal** (deployment)
- **Postmark** (transactional emails)

## Development

### Prerequisites

- Ruby 3.3.6
- Bundler

### Setup

```bash
# Clone the repository
git clone https://github.com/jeppeliisberg/sustainablemanifesto.org.git
cd sustainablemanifesto.org

# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start the development server
bin/dev
```

### Running Tests

```bash
# Run all tests
bin/rails test

# Run system tests
bin/rails test:system
```

### Code Quality

```bash
# Run Rubocop
rubocop

# Auto-fix Rubocop issues
rubocop -a

# Security audit
bundle exec brakeman
```

## Database

This application uses **SQLite** in production with the following databases:

- `storage/production.sqlite3` - Main application database
- `storage/production_cache.sqlite3` - Solid Cache
- `storage/production_queue.sqlite3` - Solid Queue (background jobs)
- `storage/production_cable.sqlite3` - Solid Cable (WebSockets)

### Encryption

For sensitive data encryption, Rails Active Record Encryption is available:

```ruby
class Model < ApplicationRecord
  encrypts :sensitive_field
  encrypts :searchable_field, deterministic: true  # allows WHERE queries
end
```

Setup encryption keys:
```bash
bin/rails db:encryption:init
```

## Email Configuration

The application uses **Postmark** for sending transactional emails.

### Setup Postmark

1. Get your Server API Token from Postmark
2. Add it to Rails credentials:

```bash
bin/rails credentials:edit --environment production
```

Add the following:

```yaml
postmark:
  api_token: your-postmark-server-api-token-here
```

## Deployment

This application is deployed to a Hetzner server using **Kamal**.

### Initial Setup

Ensure you have the following environment variables set:

```bash
export KAMAL_REGISTRY_PASSWORD="your-docker-hub-token"
export RAILS_MASTER_KEY="your-rails-master-key"
```

The `RAILS_MASTER_KEY` is found in `config/credentials/production.key`.

### Deploy

```bash
# Deploy the application
kamal deploy

# Other useful commands
kamal app logs -f        # Tail application logs
kamal app exec "bash"    # SSH into the container
kamal console            # Open Rails console
```

### Automated Deployment

Deployments are automated via GitHub Actions:
- Push to `main` branch triggers CI tests
- After CI passes, automatic deployment to production

### Database Backups

**Automatic Backups:** The application automatically backs up the database before each deployment.

- **Location:** `/root/db_backups/` on the Hetzner server
- **Retention:** Last 10 backups are kept
- **Format:** `.tar.gz` compressed archives
- **Triggered:** Automatically via `.kamal/hooks/pre-deploy`

#### Restore a Backup

SSH to the server and run:

```bash
ssh root@159.69.159.73

# List available backups
ls -lh /root/db_backups/

# Restore a specific backup (replace timestamp)
docker run --rm \
  -v sustainable_manifesto_storage:/data \
  -v /root/db_backups:/backup \
  alpine tar xzf /backup/db_backup_20251013_143022.tar.gz -C /data
```

#### Download a Backup

From your local machine:

```bash
# Download latest backup
ssh root@159.69.159.73 "ls -t /root/db_backups/db_backup_*.tar.gz | head -1" | \
  xargs -I {} scp root@159.69.159.73:{} ./
```

#### Manual Backup

To create a manual backup:

```bash
ssh root@159.69.159.73
docker run --rm \
  -v sustainable_manifesto_storage:/data \
  -v /root/db_backups:/backup \
  alpine tar czf /backup/manual_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

## Server Details

- **Host:** 159.69.159.73 (Hetzner)
- **SSL:** Automatic via Let's Encrypt
- **Domain:** sustainablemanifesto.org
- **Docker Volume:** `sustainable_manifesto_storage`

## Architecture

The application follows standard Rails conventions:

- **Controllers:** Thin, located in `app/controllers/`
- **Views:** ERB templates in `app/views/`
- **Assets:** Managed via Propshaft and Tailwind CSS
- **JavaScript:** Import maps (no bundler)
- **Background Jobs:** Solid Queue (in-process with Puma)
- **Caching:** Solid Cache (SQLite-backed)
- **WebSockets:** Solid Cable (SQLite-backed)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linters
5. Submit a pull request

## License

[Add your license here]

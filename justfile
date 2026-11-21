default:
    @just --list

# Start the local dev server at http://localhost:4000
serve:
    docker compose up -d

# Stop the local dev server
stop:
    docker compose down

# Follow the dev server logs
logs:
    docker compose logs -f jekyll

# Build the site into _site
build:
    docker compose run --rm jekyll bundle exec jekyll build

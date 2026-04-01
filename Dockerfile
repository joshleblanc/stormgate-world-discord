# syntax = docker/dockerfile:1

# Build arguments
ARG RUBY_VERSION=3.3

# Base stage
FROM ruby:${RUBY_VERSION}-slim AS base

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libffi-dev \
    libmagickwand-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Bundle install stage
FROM base AS bundle

# Copy Gemfiles
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install --jobs 4 --retry 3

# Builder stage
FROM base AS builder

WORKDIR /app

# Copy gems from bundle stage
COPY --from=bundle /app/vendor/bundle /app/vendor/bundle

# Copy application
COPY . .

# Generate bundle
RUN bundle config set --local path 'vendor/bundle' && \
    bundle install --jobs 4 --retry 3

# Final stage
FROM base AS final

WORKDIR /app

# Copy gems from builder stage
COPY --from=builder /app/vendor/bundle /app/vendor/bundle
COPY --from=builder /app /app

# Create non-root user
RUN useradd -m -s /bin/bash app && \
    mkdir -p /app/data && \
    chown -R app:app /app

USER app

# Environment
ENV RAILS_ENV=production
ENV BUNDLE_DEPLOYMENT=1
ENV BUNDLE_PATH="/app/vendor/bundle"
ENV BUNDLE_WITHOUT="development:test"

# Health check
EXPOSE 3000

# Health check endpoint (simple HTTP server for Kamal)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start command - include a simple health server alongside the bot
CMD bundle exec ruby -e "
  require 'webrick'
  server = WEBrick::HTTPServer.new({
    Port: 3000,
    Logger: WEBrick::Log.new('/dev/null'),
    AccessLog: [[File.open('/dev/null', 'w'), WEBrick::AccessLog::COMMON_LOG_FORMAT]]
  })
  server.mount_proc '/health' do |req, res|
    res['Content-Type'] = 'application/json'
    res.status = 200
    res.body = '{\"status\": \"ok\"}'
  end
  server.mount_proc '/' do |req, res|
    res['Content-Type'] = 'text/plain'
    res.body = 'Stormgate Discord Bot is running'
  end
  Thread.new { server.start }
  trap('INT') { server.shutdown }
  trap('TERM') { server.shutdown }
  exec('bundle exec ruby main.rb')
"

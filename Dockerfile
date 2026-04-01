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
    nodejs \
    npm \
    && npm install -g yarn \
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

# Install JS dependencies
RUN yarn install --non-interactive

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

# Start command
CMD bundle exec ruby main.rb
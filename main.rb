require 'discordrb'
require 'dotenv/load'
require 'faraday'
require 'active_support/inflector'
require 'active_support/deprecator'
require 'active_support/deprecation'
require 'active_support/duration'
require_relative 'utilities/helpers'
require_relative 'commands/last_command'
require_relative 'commands/search_command'
require_relative 'commands/leaderboard_command'
require_relative 'commands/around_command'

include Utilities::Helpers

INF_URL = "https://stormgateworld.com/_astro/infernals-small-glow.jbWP777a.png"
VG_URL = "https://stormgateworld.com/_astro/vanguard-small-glow.NsCUjSZx.png"
URL = "https://api.stormgateworld.com/v0"

BOT = Discordrb::Commands::CommandBot.new token: ENV.fetch("TOKEN"), client_id: ENV.fetch("CLIENT_ID"), prefix: ENV.fetch("PREFIX"), intents: [:server_messages]
puts "This bot's invite URL is #{BOT.invite_url}"
puts 'Click on it to invite it to your server.'


BOT.include! Commands::LastCommand
BOT.include! Commands::SearchCommand
BOT.include! Commands::LeaderboardCommand
BOT.include! Commands::AroundCommand

BOT.run
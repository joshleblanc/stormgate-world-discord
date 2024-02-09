require 'discordrb'
require 'dotenv/load'
require 'faraday'
require 'active_support'
require 'active_support/inflector'
require 'active_support/deprecator'
require 'active_support/deprecation'
require 'active_support/duration'
require 'active_support/number_helper'
require 'stormgate_world'

require_relative 'utilities/api'
require_relative 'utilities/helpers'
require_relative 'utilities/pagination_container'
require_relative 'commands/last_command'
require_relative 'commands/search_command'
require_relative 'commands/leaderboard_command'
require_relative 'commands/around_command'
require_relative 'commands/stats_command'
require_relative 'commands/activity_command'
require_relative 'commands/ongoing_command'

include Utilities::Helpers

INF_URL = "https://stormgateworld.com/_astro/infernals-small-glow.jbWP777a.png"
VG_URL = "https://stormgateworld.com/_astro/vanguard-small-glow.NsCUjSZx.png"
URL = "https://api.stormgateworld.com/v0"

BOT = Discordrb::Commands::CommandBot.new token: ENV.fetch("TOKEN"), client_id: ENV.fetch("CLIENT_ID"), prefix: ENV.fetch("PREFIX"), intents: [:server_messages, :server_message_reactions]
puts "This bot's invite URL is #{BOT.invite_url}"
puts 'Click on it to invite it to your server.'

Commands.constants.each do |c|
    BOT.include! Commands.const_get(c)
end

api = Utilities::Api.new

status_updates = [
    -> { "#{api.ongoing} matches being played" },
    -> { "#{api.infernal_players} infernal players" },
    -> { "#{api.vanguard_players} vanguard players"}
]

BOT.ready do 
    loop do 
        BOT.watching = status_updates.sample.call
        sleep 60 * 5
    end
end

BOT.run
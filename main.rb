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

include Utilities::Helpers

INF_URL = "https://stormgateworld.com/_astro/infernals-small-glow.jbWP777a.png"
VG_URL = "https://stormgateworld.com/_astro/vanguard-small-glow.NsCUjSZx.png"
URL = "https://api.stormgateworld.com/v0"

BOT = Discordrb::Commands::CommandBot.new token: ENV.fetch("TOKEN"), client_id: ENV.fetch("CLIENT_ID"), prefix: ENV.fetch("PREFIX"), intents: [:server_messages]
puts "This bot's invite URL is #{BOT.invite_url}"
puts 'Click on it to invite it to your server.'


BOT.include! Commands::LastCommand
BOT.include! Commands::SearchCommand

BOT.command :leaderboard, description: "Returns the top 10 players on the 1v1 ranked ladder (by mmr)" do |event|
    json = get_leaderboard(count: 10, page: 1, order: :mmr)

    leaderboard_response(json)
end

def build_player_embed(name, match)
    fields = []
    fields << EmbedField.new(name: "Rank", value: match["rank"].to_s, inline: true)
    fields << EmbedField.new(name: "MMR", value: match["mmr"].floor.to_s, inline: true)
    fields << EmbedField.new(name: "Points", value: match["points"].to_i.floor.to_s, inline: true)
    fields << EmbedField.new(name: "Wins", value: match["wins"].to_s, inline: true)
    fields << EmbedField.new(name: "Losses", value: match["losses"].to_s, inline: true)
    fields << EmbedField.new(name: "Ties", value: match["ties"].to_s, inline: true)
    fields << EmbedField.new(name: "League", value: "#{match["league"]} #{match["tier"]}", inline: true)
    fields << EmbedField.new(name: "Win Rate", value: "#{'%.2f' % match["win_rate"]}%", inline: true)
    thumbnail_url = if match["race"] == "vanguard" 
        VG_URL
    else
        INF_URL
    end

    Embed.new(
        title: name,
        thumbnail: EmbedThumbnail.new(url: thumbnail_url),
        fields: fields
    )
end

BOT.command :around, description: "Return the page that the given rank falls on" do |event, *args|
    if args.length < 1 
        return "Please enter a rank to search around"
    end

    rank = args.first.to_i

    if rank < 0 
        return "Please enter a positive rank"
    end

    page = (rank / 10).floor + 1

    data = leaderboard_response(get_leaderboard(page: page, count: 10, order: :points), "Points")

    rank_output = rank.to_s.rjust(4, "0")
    data.gsub!(/(#{rank_output}\t.+\t.+\t)(.+)(\n)/, '\1\2 <<\3')

    data
end

BOT.run
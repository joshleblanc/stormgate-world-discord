require 'discordrb'
require 'dotenv/load'
require 'faraday'

include Discordrb::Webhooks

INF_URL = "https://stormgateworld.com/_astro/infernals-small-glow.jbWP777a.png"
VG_URL = "https://stormgateworld.com/_astro/vanguard-small-glow.NsCUjSZx.png"
URL = "https://api.stormgateworld.com/v0"

bot = Discordrb::Commands::CommandBot.new token: ENV.fetch("TOKEN"), client_id: ENV.fetch("CLIENT_ID"), prefix: ENV.fetch("PREFIX"), intents: [:server_messages]
puts "This bot's invite URL is #{bot.invite_url}"
puts 'Click on it to invite it to your server.'


def get_leaderboard(**kwargs)
    query = ""

    query = kwargs.map do |key, value|
        "#{key}=#{value}"
    end.join("&")

    response = Faraday.get("#{URL}/leaderboards/ranked_1v1?#{query}")
    JSON.parse(response.body)
end

def leaderboard_response(json, points = "MMR")
    resp = [["Rank", "Race", "Name", points]]
    json["entries"].each do |entry|
        resp << [entry["rank"], entry["race"][0].upcase, entry["nickname"], entry["mmr"].floor]
    end

    resp.map! do |entry|
        [entry[0].to_s.rjust(4, "0"), entry[1].ljust(4, " "), entry[2].ljust(20, " "), entry[3]].join("\t")
    end

    <<~OUTPUT
        ```
        #{resp.join("\n")}
        ```
    OUTPUT
end

bot.command :leaderboard do |event|
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

bot.command :search do |event, *args|
    json = get_leaderboard(count: 1, page: 1, order: :mmr, query: args.join(' '))

    match = json["entries"].first

    if match 
        response = Faraday.get("#{URL}/players/#{match["player_id"]}")
        json = JSON.parse(response.body)
    
        json["leaderboard_entries"].each do 
            event.respond nil, nil, build_player_embed(match["nickname"], _1)
        end

        nil
    else 
        "Couldn't find a player named #{args.join(" ")}"
    end
end

bot.command :around do |event, *args|
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

bot.run
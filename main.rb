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

bot.command :leaderboard do |event|
    response = Faraday.get("#{URL}/leaderboards/ranked_1v1?count=10&page=1&order=mmr")
    json = JSON.parse(response.body)
    

    resp = [["Rank", "Race", "Name", "MMR"]]
    json["entries"].each do |entry|
        resp << [entry["rank"], entry["race"][0].upcase, entry["nickname"], entry["mmr"].floor]
    end

    resp.map! do |entry|
        [entry[0].to_s.rjust(4, "0"), entry[1].ljust(4, " "), entry[2].ljust(20, " "), entry[3]].join("\t")
    end

    event.respond <<~OUTPUT
        ```
        #{resp.join("\n")}
        ```
    OUTPUT
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
    response = Faraday.get("#{URL}/leaderboards/ranked_1v1?count=1&page=1&order=mmr&query=#{args.join(" ")}")
    json = JSON.parse(response.body)

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

bot.run
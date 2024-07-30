module Commands
  module SearchCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
      event.channel.start_typing

      query = args.join(" ")
      queries = query.split(",")

      api = Utilities::Api.new
      players = queries.map do
        api.find_player(_1.strip)
      end

      json = []

      players.each do |player|
        if player && player["ranks"]["ranked_1v1"].nil?
          # event << "No ranks found for #{player["playerName"]}"
        elsif player
          data = player["ranks"]["ranked_1v1"]
          data.each do |k, v|
            v["race"] = k
            v["playerName"] = player["playerName"]
            json.push v
          end
        end
      end

      json.sort_by! { _1["points"].to_f }.reverse!

      send_html event, render("leaderboard", { query: query, json:, description: json.map { _1["playerName"] }.uniq.join(", ") })
    end
  end
end

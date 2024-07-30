module Commands
  module SearchCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
      event.channel.start_typing

      query = args.join(" ")

      api = Utilities::Api.new

      player = api.find_player(query)

      return "No player found for #{query}" if !player || player["detail"] == "Not found."

      if player["ranks"]["ranked_1v1"].nil?
        return "No ranks found for #{player["playerName"]}"
      end

      attachments = []

      data = player["ranks"]["ranked_1v1"]

      json = []
      data.each do |k, v|
        v["race"] = k
        v["playerName"] = player["playerName"]
        json.push v
      end

      json.sort_by! { _1["points"].to_f }.reverse!

      send_html event, render("leaderboard", { json:, description: player["playerName"] })
    end
  end
end

module Commands
  module MatchHistoryCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :match_history, description: "Shows a player's match history" do |event, *args|
      event.channel.start_typing

      api = Utilities::Api.new
      query = args.join(" ")

      if query.empty?
        event.respond "Please provide a player name or ID"
        return
      end

      player = api.find_player(query)

      if player.nil?
        event.respond "Could not find player: #{query}"
        return
      end

      matches = api.match_history(player["profileId"])

      output = render("match_history", {
        matches:,
        player:,
      })

      send_html event, output
    end
  end
end

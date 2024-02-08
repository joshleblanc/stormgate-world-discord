module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            match = find_player(args.join(' '))
        
            return "Could not find player named #{args.join(' ')}" unless match
        
            response = Faraday.get("#{URL}/players/#{match["player_id"]}")
            json = JSON.parse(response.body)
        
            json["leaderboard_entries"].each do 
                event.respond nil, nil, build_player_embed(match["nickname"], _1)
            end
        
            nil
        end
    end
end

module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            event.channel.start_typing

            query = args.join(' ')

            player_api = StormgateWorld::PlayersApi.new
            api = Utilities::Api.new

            player = api.find_player(query)

            return "No player found for #{query}" unless player
            
            attachments = []
            
            threads = player.leaderboard_entries.map do |entry|
                Thread.new do 
                    send_html(event, render("profile_card", {
                        entry:, player:
                    }))
                end
            end

            threads.each(&:join)
            
            nil
        end
    end
end

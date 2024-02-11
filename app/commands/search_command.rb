module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            query = args.join(' ')

            api = Utilities::Api.new
            player = api.search(query)

            return "No player found for #{query}" unless player

            player_api = StormgateWorld::PlayersApi.new
            player = player_api.get_player(player.player_id)

            client = HTMLCSSToImage.new

            player.leaderboard_entries.each do |entry|
                next unless entry.rank 
                
                p entry
                text = File.read("app/views/profile_card.html.erb")
                template = ERB.new(text)

                image = client.create_image(template.result(binding), css: "body { background-color: transparent; }", google_fonts: "Nunito+Sans")


                event.respond image.url
            end


            nil
        end
    end
end

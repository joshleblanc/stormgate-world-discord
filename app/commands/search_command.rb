module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        def self.fetch_image(html) 
            cache_key = "htmlcssimage/#{html}"
            cached_url = CACHE.read(cache_key)

            return cached_url if cached_url.present?

            client = HTMLCSSToImage.new
            image = client.create_image(html, css: "body { background-color: transparent; }", google_fonts: "Nunito+Sans")

            if image.success?
                CACHE.write(cache_key, image.url)
            end

            image.url
        end

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            query = args.join(' ')

            api = Utilities::Api.new
            player = api.search(query)

            return "No player found for #{query}" unless player

            player_api = StormgateWorld::PlayersApi.new
            player = player_api.get_player(player.player_id)


            player.leaderboard_entries.each do |entry|
                text = File.read("app/views/profile_card.html.erb")
                template = ERB.new(text)

                event.respond fetch_image(template.result(binding))
            end


            nil
        end
    end
end

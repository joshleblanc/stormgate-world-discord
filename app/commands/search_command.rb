module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        def self.build_player_embed(name, match)
            fields = []
            fields << EmbedField.new(name: "Rank", value: match.rank.to_s, inline: true)
            fields << EmbedField.new(name: "MMR", value: match.mmr.floor.to_s, inline: true)
            fields << EmbedField.new(name: "Points", value: match.points.to_i.floor.to_s, inline: true)
            fields << EmbedField.new(name: "Wins", value: match.wins.to_s, inline: true)
            fields << EmbedField.new(name: "Losses", value: match.losses.to_s, inline: true)
            fields << EmbedField.new(name: "Ties", value: match.ties.to_s, inline: true)
            fields << EmbedField.new(name: "League", value: "#{match.league&.titleize} #{match.tier}", inline: true)
            fields << EmbedField.new(name: "Win Rate", value: "#{'%.2f' % match.win_rate}%", inline: true)
            thumbnail_url = if match.race == "vanguard" 
                VG_URL
            else
                INF_URL
            end

            Embed.new(
                title: name,
                description: "API limits exceeded for image. Ping @Cereal",
                thumbnail: EmbedThumbnail.new(url: thumbnail_url),
                fields: fields
            )
        end


        def self.fetch_image(html) 
            cache_key = "htmlcssimage/#{html}"
            cached_url = CACHE.read(cache_key)

            return cached_url if cached_url.present?

            client = HTMLCSSToImage.new
            image = client.create_image(html, css: "body { background-color: transparent; }", google_fonts: "Nunito+Sans")

            if image.success?
                CACHE.write(cache_key, image.url)
            end

            image&.url
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

                url = fetch_image(template.result(binding))
                if url 
                    event.respond url
                else 
                    event.respond nil, nil, build_player_embed(player.nickname, entry)
                end
                
            end


            nil
        end
    end
end

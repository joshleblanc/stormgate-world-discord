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
                thumbnail: EmbedThumbnail.new(url: thumbnail_url),
                fields: fields
            )
        end

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            api = Utilities::Api.new

            match = api.search(args.join(' '))
        
            return "Could not find player named #{args.join(' ')}" unless match
        
            player_api = StormgateWorld::PlayersApi.new

            player = player_api.get_player(match.player_id)
        
            player.leaderboard_entries.each do 
                event.respond nil, nil, build_player_embed(match.nickname, _1)
            end
        
            nil
        end
    end
end

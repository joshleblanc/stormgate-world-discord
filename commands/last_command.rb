module Commands 

    module LastCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        def self.player_nickname(json)
            result = if json["result"] == "loss"
                "Loser"
            elsif json["result"] == "win"
                "Winner"
            else
                "Name"
            end

            EmbedField.new(name: result, value: json["player"]["nickname"], inline: true)
        end

        def self.title(json)
            race_1 = json["players"][0]["race"][0].upcase
            race_2 = json["players"][1]["race"][0].upcase

            name_1 = json["players"][0]["player"]["nickname"]
            name_2 = json["players"][1]["player"]["nickname"]

            mmr_1 = json["players"][0]["mmr"].floor
            mmr_2 = json["players"][1]["mmr"].floor

            "(#{race_1}) #{name_1} (#{mmr_1}) vs (#{race_2}) #{name_2} (#{mmr_2})"
        end

        def self.player_race(json)
            EmbedField.new(name: "Race", value: json["race"], inline: true)
        end

        def self.player_league(json)
            league = json["player_leaderboard_entry"]["league"]
            tier = json["player_leaderboard_entry"]["tier"]
            EmbedField.new(name: "League", value: "#{league} #{tier}", inline: true)
        end

        def self.blank
            EmbedField.new(name: "", value: "", inline: true)
        end

        def self.match_player(match, json) 
            json["players"].find { _1["player"]["player_id"] == match["player_id"]}
        end

        def self.color(match, json) 
            if json["state"] == "ongoing"
                return "#607D8B"
            end

            player = match_player(match, json)

            if player["result"] == "win"
                "#4CAF50"
            elsif player["result"] == "loss"
                "#F44336"
            else
                "#FFEB3B"
            end
        end

        def self.score(json, what)
            EmbedField.new(name: what.titleize, value: json["scores"][what], inline: true)
        end

        command :last, description: "Return information about the last match a player played", min_args: 1 do |event, *args|
            match = find_player(args.join(' '))

            return "Couldn't find player #{args.join(' ')}" unless match
        
            response = Faraday.get("#{URL}/players/#{match["player_id"]}/matches/last")
            json = JSON.parse(response.body)

            players = json["players"]
                
            blank = EmbedField.new(name: "", value: "", inline: true)
        
            event.respond nil, nil, Embed.new(
                fields: [
                    score(players[0], "xp"),
                    blank,
                    score(players[1], "xp"),
                    score(players[0], "units_killed"),
                    blank,
                    score(players[1], "units_killed"),
                    score(players[0], "resources_mined"),
                    blank,
                    score(players[1], "resources_mined"),
                    score(players[0], "structures_killed"),
                    blank,
                    score(players[1], "structures_killed"), 
                    score(players[0], "creep_resources_collected"),
                    blank,
                    score(players[1], "creep_resources_collected")
    
                ],
                title: "#{match["nickname"]} (#{match_player(match, json)["result"].titleize})",
                description: title(json),
                footer: EmbedFooter.new(text: ActiveSupport::Duration.build(json["duration"]).inspect),
                timestamp: DateTime.parse(json["created_at"]).to_time,
                color: color(match, json)
            )
        end
    end
end
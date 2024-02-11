module Commands 

    module LastCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        def self.player_nickname(json)
            result = if json.result == "loss"
                "Loser"
            elsif json.result == "win"
                "Winner"
            else
                "Name"
            end

            EmbedField.new(name: result, value: json.player.nickname, inline: true)
        end

        def self.title(json)
            race_1 = json.players[0].race[0].upcase
            race_2 = json.players[1].race[0].upcase

            name_1 = json.players[0].player.nickname
            name_2 = json.players[1].player.nickname

            mmr_1 = json.players[0].mmr.floor
            mmr_2 = json.players[1].mmr.floor

            "(#{race_1}) #{name_1} (#{mmr_1}) vs (#{race_2}) #{name_2} (#{mmr_2})"
        end
        
        def self.ongoing_title(json)
            name_1 = json.players[0].player.nickname
            name_2 = json.players[1].player.nickname

            "#{name_1} vs #{name_2}"
        end

        def self.player_race(json)
            EmbedField.new(name: "Race", value: json.race.titleize, inline: true)
        end

        def self.player_mmr(json)
            EmbedField.new(name: "MMR", value: json.mmr.floor, inline: true)
        end

        def self.player_league(json)
            league = json.player_leaderboard_entry.league&.titleize
            tier = json.player_leaderboard_entry.tier
            EmbedField.new(name: "League", value: "#{league} #{tier}", inline: true)
        end

        def self.match_player(match, json) 
            json.players.find { _1.player.player_id == match.player_id}
        end

        def self.ping(json)
            EmbedField.new(name: "Ping", value: json.ping, inline: true)
        end

        def self.color(match, json) 
            player = match_player(match, json)

            if player.result == "win"
                "#4CAF50"
            elsif player.result == "loss"
                "#F44336"
            else
                "#FFEB3B"
            end
        end

        def self.score(json, what)
            EmbedField.new(name: what.to_s.titleize, value: json.scores[what], inline: true)
        end

        ##
        # onogoing 
        # {"cached_at"=>"2024-02-08T23:40:15.195173900", "match_id"=>"rJO9w8", "state"=>"ongoing", "leaderboard"=>"ranked_1v1", "server"=>"Washington_DC", "players"=>[{"player"=>{"player_id"=>"XDPwbG", "nickname"=>"Néos", "nickname_discriminator"=>"2309"}, "player_leaderboard_entry"=>{"leaderboard_entry_id"=>"k0wY5o", "league"=>"platinum", "tier"=>3, "rank"=>704, "wins"=>81, "losses"=>55, "ties"=>0, "win_rate"=>59.558823}, "race"=>"vanguard", "team"=>1, "party"=>1, "mmr"=>1615.8809, "mmr_updated"=>0.0, "mmr_diff"=>nil, "result"=>nil, "ping"=>43, "scores"=>nil}, {"player"=>{"player_id"=>"CYAC6B", "nickname"=>"vintobea", "nickname_discriminator"=>"1880"}, "player_leaderboard_entry"=>{"leaderboard_entry_id"=>"xiyjpj", "league"=>"platinum", "tier"=>3, "rank"=>773, "wins"=>58, "losses"=>35, "ties"=>0, "win_rate"=>62.365593}, "race"=>"infernals", "team"=>0, "party"=>0, "mmr"=>1619.6914, "mmr_updated"=>0.0, "mmr_diff"=>nil, "result"=>nil, "ping"=>24, "scores"=>nil}], "created_at"=>"2024-02-08T23:30:49", "ended_at"=>nil, "duration"=>nil}

        def self.ongoing_response(match, json)
            players = json.players

            Embed.new(
                fields: [
                    EmbedField.new(name: "Server", value: json.server),
                    player_league(players[0]),
                    blank,
                    player_league(players[1]),
                    player_race(players[0]),
                    blank,
                    player_race(players[1]),
                    player_mmr(players[0]),
                    blank,
                    player_mmr(players[1]),
                    ping(players[0]),
                    blank,
                    ping(players[1]),
                ],
                title: match.nickname,
                description: ongoing_title(json),
                footer: EmbedFooter.new(text: "Ongoing"),
                timestamp: json.created_at,
                color: "#607D8B"
            )
        end

        def self.finished_response(match, json)
            players = json.players

            Embed.new(
                fields: [
                    score(players[0], :xp),
                    blank,
                    score(players[1], :xp),
                    score(players[0], :units_killed),
                    blank,
                    score(players[1], :units_killed),
                    score(players[0], :resources_mined),
                    blank,
                    score(players[1], :resources_mined),
                    score(players[0], :structures_killed),
                    blank,
                    score(players[1], :structures_killed), 
                    score(players[0], :creep_resources_collected),
                    blank,
                    score(players[1], :creep_resources_collected)
    
                ],
                title: "#{match.nickname} (#{match_player(match, json).result.titleize})",
                description: title(json),
                footer: EmbedFooter.new(text: ActiveSupport::Duration.build(json.duration).inspect),
                timestamp: json.created_at,
                color: color(match, json)
            )
        end

        command :last, description: "Return information about the last match a player played", min_args: 1 do |event, *args|
            api = Utilities::Api.new

            query = args.join(' ')

            match = api.search(query)

            return "Couldn't find player #{query}" unless match
        
            json = api.last(player_id: match.player_id) 

            event.respond nil, nil, if json.state == "ongoing"
                ongoing_response(match, json)
            else
                finished_response(match, json)
            end
        end
    end
end
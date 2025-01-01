module Utilities
    class Api 
        URL = "https://api.stormgate.untapped.gg"

        def client(params = {})
            Faraday.new({
                url: URL,
                params:,

            }) do |builder|
                builder.request :json
                builder.response :json
            end
        end

        def leaderboard(**kwargs)
            count = kwargs.delete(:count)
            page = kwargs.delete(:page)
            sort = kwargs.delete(:order)
            race = kwargs.delete(:race)

            response = client(kwargs.merge(match_mode: "ranked_1v1")).get("/api/v1/leaderboard").body
            response.sort_by! { _1[sort.to_s] }.reverse! if sort
            response = response.drop(page * count) if page && count && count > 0
            response = response.take(count) if count && count > 0
            response.select! { _1["race"] == race } if race 

            response
        end

        def ongoing 
            0
        end

        def infernal_players
            leaderboard(count: 0, page: 0, race: "infernals").count
        end

        def vanguard_players
            leaderboard(count: 0, page: 0, race: "vanguard").count
        end

        def search(query)
            response = client({ q: query }).get("/api/v1/players").body
            response.sort_by { _1.dig("ranks", "ranked_1v1")&.values&.map { |v| v["mmr"] || 0 }&.max || 0 }.reverse.first
        end

        def lookup(id)
            client.get("/api/v1/players/#{id}").body
        end

        def find_player(query)
            player = if query.size == 8 && query.start_with?("#")
                lookup(query[1..-1])
            end
                
            return player if player 

            search(query)
        end

        def match_history(profile_id)
            response = client.get("/api/v2/matches/players/#{profile_id}/recent/ranked_1v1?season=current").body
            
            matches = []
            matches.concat(response["vanguard"] || [])
            matches.concat(response["infernals"] || [])
            matches.concat(response["celestials"] || [])
            
            matches.sort_by! { |match| -match["match_start"] }
            matches.take(10)
        end

        def player_stats(profile_id)
            response = client.get("/api/v2/matches/players/#{profile_id}/stats/ranked_1v1?season=current").body
            
            # Remove any empty faction stats
            response.delete_if { |_, stats| stats.empty? }
            response["all"]
        end
    end
end
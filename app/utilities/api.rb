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
            response.sort_by { _1["mmr"] }.reverse.first
        end

        def lookup(id)
            client.get("/api/v1/players/#{id}").body
        end

        def find_player(query)
            player = if query.size == 7
                lookup(query)
            end
                
            return player if player 

            search(query)
        end
    end
end
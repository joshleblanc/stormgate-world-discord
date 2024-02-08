module Utilities
    class Api 
        URL = "https://api.stormgateworld.com/v0"

        def leaderboard(**kwargs)
            query = query_from_kwargs(kwargs)
            response = Faraday.get("#{URL}/leaderboards/ranked_1v1?#{query}")
            JSON.parse(response.body)
        end

        def search(query)
            json = leaderboard(count: 1, page: 1, order: :mmr, query:)
            json["entries"].first
        end

        def last(player_id:)
            response = Faraday.get("#{URL}/players/#{player_id}/matches/last")
            JSON.parse(response.body)
        end

        private 

        def query_from_kwargs(kwargs)
            kwargs.map do |key, value|
                "#{key}=#{CGI.escape(value.to_s)}"
            end.join("&")
        end
    end
end
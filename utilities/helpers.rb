module Utilities
    module Helpers
        include Discordrb::Webhooks

        def get_leaderboard(**kwargs)
            query = ""
        
            query = kwargs.map do |key, value|
                "#{key}=#{value}"
            end.join("&")
        
            response = Faraday.get("#{URL}/leaderboards/ranked_1v1?#{query}")
            JSON.parse(response.body)
        end
        
        def leaderboard_response(json, points = "MMR")
            resp = [["Rank", "Race", "Name", points]]
            json["entries"].each do |entry|
                resp << [entry["rank"], entry["race"][0].upcase, entry["nickname"], entry["mmr"].floor]
            end
        
            resp.map! do |entry|
                [entry[0].to_s.rjust(4, "0"), entry[1].ljust(4, " "), entry[2].ljust(20, " "), entry[3]].join("\t")
            end
        
            <<~OUTPUT
                ```
                #{resp.join("\n")}
                ```
            OUTPUT
        end
        
        def find_player(query)
            json = get_leaderboard(count: 1, page: 1, order: :mmr, query:)
        
            json["entries"].first
        end
    end
end

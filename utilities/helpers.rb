module Utilities
    module Helpers
        include Discordrb::Webhooks
        
        def leaderboard_response(json, points = "MMR")
            resp = [["Rank", "Race", "Name", points]]
            json.entries.each do |entry|
                resp << [entry.rank, entry.race[0].upcase, entry.nickname, entry.mmr.floor]
            end
        
            resp.map! do |entry|
                [entry[0].to_s.rjust(4, "0"), entry[1].ljust(4, " "), entry[2].ljust(25, " "), entry[3]].join("\t")
            end
        
            <<~OUTPUT
                ```
                #{resp.join("\n")}
                ```
            OUTPUT
        end
    end
end

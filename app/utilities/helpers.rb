module Utilities
    module Helpers
        include Discordrb::Webhooks
        include ActiveSupport::NumberHelper

        VALID_LEAGUES = [
            "master", "diamond", "platinum", "gold", "silver", "bronze", "aspirant"
        ]
        
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

        def number_to_percentage(...)
            NumberToPercentageConverter.convert(...)
        end

        def number_with_precision(...)
            NumberToRoundedConverter.convert(...)
        end

        def blank
            EmbedField.new(name: "", value: "", inline: true)
        end

        def field(name, value, inline = true)
            EmbedField.new(name:, value: value.to_s, inline:)
        end
    end
end

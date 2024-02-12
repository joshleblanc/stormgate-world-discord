module Utilities
    module Helpers
        include Discordrb::Webhooks
        include ActiveSupport::NumberHelper

        VALID_LEAGUES = [
            "master", "diamond", "platinum", "gold", "silver", "bronze", "aspirant"
        ]

        LEAGUE_MAP = {
            master: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Fmaster-1.Upb0ETXP.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fmaster-2.lHM152kH.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fmaster-3.niUs3X95.png&f=webp
            ],
            diamond: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Fdiamond-1.I4IQBdkB.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fdiamond-2.e3mAoUDT.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fdiamond-3.EmclqKOy.png&f=webp
            ],
            platinum: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Fplatinum-1.wRRkqm-M.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fplatinum-2.5SLnIxGC.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fplatinum-3._xtibM4l.png&f=webp
            ],
            gold: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Fgold-1.57kCQZWY.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fgold-2.xHUHsFhT.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fgold-3.RQ0vpJ9c.png&f=webp
            ],
            silver: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Fsilver-1.kPZ9adS2.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fsilver-2.84ZTx_eH.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fsilver-3.AMrt8hm_.png&f=webp
            ],
            bronze: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Fbronze-1.9Sel4tuE.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fbronze-2.jkb7L-ym.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Fbronze-3.WWFlhd3O.png&f=webp
            ],
        aspirant: %w[
                https://stormgateworld.com/_image?href=%2F_astro%2Faspirant-1.4t-uHZDX.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Faspirant-2.HZNpSbVW.png&f=webp
                https://stormgateworld.com/_image?href=%2F_astro%2Faspirant-3.lDwWjEs4.png&f=webp
            ]
        }

        def faction_icon(faction)
            if faction == "vanguard"
                VG_URL
            else
                INF_URL
            end
        end

        def league_icon(league, tier)
            return nil unless league
            LEAGUE_MAP[league&.to_sym][tier.pred]
        end
        
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

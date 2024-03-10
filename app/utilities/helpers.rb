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

        def fetch_chart(config)
            cache_key = "chart/#{config}"

            cached = CACHE.read(cache_key)

           # return cached if cached 

            conn = Faraday.new(
                url: "https://quickchart.io/chart",
                headers: { 
                    "Content-Type" => "application/json"
                },
            )

            response = conn.post do |req|
                req.body = JSON.generate({
                    backgroundColor: "#EDF8FD",
                    width: 500,
                    height: 300,
                    chart: config
                })
            end

            data = response.body

            CACHE.write(cache_key, data)

            data
        end

        def league_icon(league, tier)
            return "https://stormgateworld.com/_image?href=%2F_astro%2Funranked.BrngpH03.png&f=webp" unless league
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

        def render(...)
            Utilities::Renderer.instance.render(...)
        end

        def generate_image(html) 
            cache_key = Base64.encode64("image-generation/#{html}")

            cached = CACHE.read(cache_key)

            #return cached if cached 

            output = Open3.capture3("node", "javascript/htmltoimage.js", html)

            output = output.first

            CACHE.write(cache_key, output)

            output
        end

        def send_html(event, html)
            Tempfile.open(binmode: true) do |t|
                t.write generate_image(html)

                t.rewind
                event.send_file t, filename: "output.png"
            end
        end
    end
end

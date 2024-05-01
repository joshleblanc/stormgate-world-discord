module Utilities
    module Helpers
        include Discordrb::Webhooks
        include ActiveSupport::NumberHelper

        def self.image_to_data_uri(path)
            data = File.read(path, binary: true)
            "data:image/png;base64,#{Base64.encode64(data)}"
        end

        INF_URL = image_to_data_uri("app/assets/race_icons/infernals-small-glow.png")
        VG_URL = image_to_data_uri("app/assets/race_icons/vanguard-small-glow.png")
        F3_URL = "data:image/webp;base64,UklGRnACAABXRUJQVlA4WAoAAAAQAAAAfwAAfwAAQUxQSLwBAAABkJftb9hGgiAGE4QwqBksDGIGKQOHQSB4DALBEAJBEAxB2+4uVmP//utzT0RMAL1zZZnCn8JweFr3Q+1qPY80CwgOezHvM4fhcSzVXqubjCwc1e6YZVC8nnbbLAPirdqddRnOVu3u+1iCWoenjIOz9akyiqDWq/IYNuu4jIC/rOvnAJJ1PvUXeiv9UenMQn+ht9IfVS/N6+fHB/3Jj5jVzUJ/yaPmhak5qtfeH9em8mDyTU7aH6VrNTH5Rx/j/uRKTUwvffqE/qj8qwi9urgsAwh/05leH1zSAKj8cTDdUT3yCFazutI986C46kQ3TYOiKNRRGsKN8e0en1gOjwmLehDUyRwLltUjYVGPCUo0RyWo6rFA2cxRCamYZ4KiHkpIN/NckDzNMxPQyTxVgIi6zIRT1DwT4WQ1z52AHuZ5EtDNPJWBRPNUIZyiHioEVM3xZAK6mWNhAirmmAmqOmSCGq09EVTWtkxYN2vOBFabTgYTrVWFwJYmIbBirSuhjS2Z4OYWwXM2ZILL1ih4poZMeOcGAbReKwQ4XVvgCbqT0GV4K7wHvAkeQZ7zxR3TW99ZXXck0Vzz//S8mQZWUDggjgAAADAKAJ0BKoAAgAA+USCNRCOiIRdPtAA4BQS0t3BgAAWO4OPt1giRe7uivyvZv53ZnNFocB1G2vx4uuSJsEEmyxsw5g8h0iDzjM4QpuCjXxMZKrk9COqi6rL8IAD+1c8nf//6gvWu9ov//UF4MHvvk7///0ONPaho///opRTDf//9FNT/5TgCd/+gRAAAAAA="

        VALID_LEAGUES = [
            "master", "diamond", "platinum", "gold", "silver", "bronze", "aspirant"
        ]

        LEAGUE_MAP = {
            grandmaster: [
                image_to_data_uri("app/assets/league_icons/grandmaster.png")
            ],
            master: [
                image_to_data_uri("app/assets/league_icons/master-1.png"),
                image_to_data_uri("app/assets/league_icons/master-2.png"),
                image_to_data_uri("app/assets/league_icons/master-3.png"),
            ],
            diamond: [
                image_to_data_uri("app/assets/league_icons/diamond-1.png"),
                image_to_data_uri("app/assets/league_icons/diamond-2.png"),
                image_to_data_uri("app/assets/league_icons/diamond-3.png"),
            ],
            platinum: [
                image_to_data_uri("app/assets/league_icons/platinum-1.png"),
                image_to_data_uri("app/assets/league_icons/platinum-2.png"),
                image_to_data_uri("app/assets/league_icons/platinum-3.png"),
            ],
            gold: [
                image_to_data_uri("app/assets/league_icons/gold-1.png"),
                image_to_data_uri("app/assets/league_icons/gold-2.png"),
                image_to_data_uri("app/assets/league_icons/gold-3.png"),
            ],
            silver: [
                image_to_data_uri("app/assets/league_icons/silver-1.png"),
                image_to_data_uri("app/assets/league_icons/silver-2.png"),
                image_to_data_uri("app/assets/league_icons/silver-3.png"),
            ],
            bronze: [
                image_to_data_uri("app/assets/league_icons/bronze-1.png"),
                image_to_data_uri("app/assets/league_icons/bronze-2.png"),
                image_to_data_uri("app/assets/league_icons/bronze-3.png"),
            ],
            aspirant: [
                image_to_data_uri("app/assets/league_icons/aspirant-1.png"),
                image_to_data_uri("app/assets/league_icons/aspirant-2.png"),
                image_to_data_uri("app/assets/league_icons/aspirant-3.png"),
            ],
            unranked: [
                image_to_data_uri("app/assets/league_icons/unranked.png")
            ]
        }

        def faction_icon(faction)
            if faction == "vanguard"
                VG_URL
            elsif faction == "infernals"
                INF_URL
            else
                F3_URL
            end
        end

        def fetch_chart(config)
            cache_key = "chart/#{config}"

            cached = CACHE.read(cache_key)

            return cached if cached 

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
            return LEAGUE_MAP[:unranked][0] unless league
            LEAGUE_MAP[league&.to_sym][tier.pred]
        end
        
        def leaderboard_response(json, points = "MMR")
            resp = [["Rank", "Race", "Name", points]]
            json.entries.each do |entry|
                resp << [entry["race"][0].upcase, entry["playerName"], entry["mmr"].floor]
            end
        
            resp.map! do |entry|
                [entry[0].ljust(4, " "), entry[1].ljust(25, " "), entry[2]].join("\t")
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

            tmpfile = Tempfile.new
            tmpfile.write(html)
            tmpfile.close

            output = Open3.capture3("node", "javascript/htmltoimage.js", tmpfile.path)

            output = output.first

            CACHE.write(cache_key, output)

            tmpfile.unlink 

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

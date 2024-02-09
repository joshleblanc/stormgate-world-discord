module Commands
    module Graph 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        TITLE = {
            "win_rate" => "Win rates over time",
            "pick_rate" => "Pick rates over time",
            "players_count" => "Player count over time",
            "matches_count" => "Match count over time",
            "wins_count" => "Win count over time",
            "losses_count" => "Losses count over time",
            "matches_count_with_mirror" => "Mirror count over time"
        }

        command :graph do |event, graph_type, league|
            graph_type&.downcase!
            league&.downcase!
            
            return "No graph type specified. Valid graph types: #{TITLE.keys.join(", ")}" unless graph_type
            return "Invalid graph type. Valid graph types: #{TITLE.keys.join(", ")}" unless TITLE.keys.include?(graph_type)

            if league && !VALID_LEAGUES.include?(league) 
                return "Please enter a value league. Valid leages are: #{VALID_LEAGUES.join(', ')}"
            end

            stats_api = StormgateWorld::StatisticsApi.new

            stats = stats_api.get_statistics(league:)


            config = {
                type: 'line',
                data: {
                    labels: stats.races[0].history.map { _1.date.to_s },
                    datasets: []
                },
                options: {
                    title: {
                        display: true,
                        text: TITLE[graph_type]
                    }
                }
                
            }

            stats.races.each do |race|
                config[:data][:datasets].push({
                    label: race.race.titleize,
                    data: race.history.map do |hist|
                        number_with_precision(hist.send(graph_type), precision: 2)
                    end
                })
            end

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


            Tempfile.open(binmode: true) do |t|
                t.write response.body

                t.rewind
                event.send_file t, filename: "win_rate.png"
            end
        
        end
    end
end

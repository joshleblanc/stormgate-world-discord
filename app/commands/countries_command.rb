module Commands
    module CountriesCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :countries do |event|
            players_api = StormgateWorld::StatisticsApi.new
            data = players_api.get_statistics_countries

            limit = 20

            values = data.countries[1..limit].map(&:players)
            labels = data.countries[1..limit].map(&:code)

            config = {
                type: 'bar',
                data: {
                    datasets: [{
                        data: [*values, data.countries[limit..-1].sum(&:players)],
                        backgroundColor: [
                            '#696969',
                            '#7f0000',
                            '#808000',
                            '#483d8b',
                            '#008000',
                            '#00008b',
                            '#66cdaa',
                            '#ff0000',
                            '#ffa500',
                            '#ffff00',
                            '#7cfc00',
                            '#ba55d3',
                            '#00ff7f',
                            '#0000ff',
                            '#ff00ff',
                            '#1e90ff',
                            '#fa8072',
                            '#dda0dd',
                            '#ff1493',
                            '#87cefa',
                            '#ffe4c4'
                        ]
                    }],
                    labels: [*labels, "Everywhere else"],
 
                },
                options: {
                    title: {
                        display: true,
                        text: "Players per country"
                    },
                    legend: {
                        display: false
                    }
                }
            }

            data = fetch_chart(config)

            Tempfile.open(binmode: true) do |t|
                t.write data

                t.rewind
                event.send_file t, filename: "countries.png"
            end


        end
    end
end
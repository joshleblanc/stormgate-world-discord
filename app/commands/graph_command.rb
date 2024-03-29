module Commands
    module GraphCommand
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

        PLAYER_GRAPH_TYPES = {
            "win_rate" => "win_rate",
            "matches_count" => "matches",
            "wins_count" => "wins",
            "losses_count" => "losses",
        }

        def self.line_color(race)
            if race == "infernals"
                "rgb(160, 46, 23)"
            elsif race == "vanguard"
                "rgb(11, 86, 151)"
            end
        end

        def self.background_color(race)
            if race == "infernals"
                "rgba(160, 46, 23, 0.5)"
            elsif race == "vanguard"
                "rgba(11, 86, 151, 0.5)"
            end
        end

        def self.title(graph_type, league_or_player, player)
            title = [TITLE[graph_type]]

            if league_or_player.present?
                if player.present?
                    title << "#{player.nickname}##{player.id}"
                else 
                    title << "#{league_or_player} league"
                end                
            end

            title
        end

        def self.bar_graph(stats, method)
            config = {
                type: 'bar',
                data: {
                    labels: stats.races[0].history.map { _1.date.to_s },
                    datasets: []
                },
                options: {
                    title: {
                        display: true,
                        text: ""
                    }
                }
                
            }

            stats.races.each do |race|
                label = if race.respond_to?(:race) 
                    race.race
                else
                    race.history.first&.race 
                end

                next unless label 

                sum = 0
                config[:data][:datasets].push({
                    label: label.titleize,
                    borderColor: line_color(label),
                    backgroundColor: background_color(label),
                    data: race.history.map.with_index do |hist, index|
                        datum = hist.send(method)

                        datum
                    end
                })
            end

            config
        end

        def self.line_graph(stats, method, is_player = false)
            config = {
                type: 'line',
                data: {
                    labels: stats.races[0].history.map { _1.date.to_s },
                    datasets: []
                },
                options: {
                    title: {
                        display: true,
                        text: ""
                    }
                }
                
            }

            stats.races.each do |race|
                label = if race.respond_to?(:race) 
                    race.race
                else
                    race.history.first&.race 
                end

                next unless label 

                sum = 0
                config[:data][:datasets].push({
                    label: label.titleize,
                    borderColor: line_color(label),
                    backgroundColor: background_color(label),
                    lineTension: 0.4,
                    data: race.history.map.with_index do |hist, index|
                        datum = hist.send(method)
                        sum += datum

                        if is_player
                            number_with_precision(sum / index.next, precision: 2)
                        else 
                            number_with_precision(datum, precision: 2)
                        end
                        
                    end
                })
            end

            config
        end

        command :graph do |event, graph_type, *args|
            league_or_player = args.join(" ")
            
            graph_type&.downcase!
            league_or_player&.downcase!
            player = nil

            graph_type_method = graph_type

            return "No graph type specified. Valid graph types: #{TITLE.keys.join(", ")}" unless graph_type
            return "Invalid graph type. Valid graph types: #{TITLE.keys.join(", ")}" unless TITLE.keys.include?(graph_type)

            stats = if league_or_player.present?
                if VALID_LEAGUES.include?(league_or_player)
                    stats_api = StormgateWorld::StatisticsApi.new
                    stats_api.get_statistics(league: league_or_player)
                else
                    graph_type_method = PLAYER_GRAPH_TYPES[graph_type]

                    return "Invalid graph type for player. Valid graph types: #{PLAYER_GRAPH_TYPES.keys.join(", ")}" unless graph_type_method

                    api = Utilities::Api.new

                    result = api.find_player(league_or_player)

                    return "No player found for #{league_or_player}" unless result

                    player = result

                    players_api = StormgateWorld::PlayersApi.new

                    begin
                        players_api.get_player_statistics_activity(result.id)
                    rescue 
                        return "Failed to fetch statistics for #{result.nickname}##{result.id}"
                    end
                    
                end
            else
                stats_api = StormgateWorld::StatisticsApi.new
                stats_api.get_statistics
            end

            

            config = if player.present? && PLAYER_GRAPH_TYPES.keys.include?(graph_type) && graph_type != "win_rate"
                bar_graph(stats, graph_type_method)
            else
                line_graph(stats, graph_type_method, player.present?)
            end
            config[:options][:title][:text] = title(graph_type, league_or_player, player)

            data = fetch_chart(config)

            Tempfile.open(binmode: true) do |t|
                t.write data

                t.rewind
                event.send_file t, filename: "win_rate.png"
            end
        end
    end
end

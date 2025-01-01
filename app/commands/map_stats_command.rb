module Commands
  module MapStatsCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :map_stats, description: "Shows win/loss stats by map" do |event, *args|
      event.channel.start_typing

      api = Utilities::Api.new
      query = args.join(" ")
      
      # Find player
      player = api.find_player(query)
      return event.respond "Could not find player: #{query}" unless player

      # Get stats
      stats = api.player_stats(player["profileId"])
      return event.respond "No stats found for #{query} or account is private" if stats.nil? || stats.empty?

      # Create datasets for each faction
      datasets = []
      
      faction_colors = {
        "vanguard" => "rgb(12, 116, 200)",
        "infernals" => "rgb(202, 59, 29)",
        "celestials" => "rgb(140, 48, 175)"
      }

      # Get all maps and sort by total games across all factions
      all_maps = {}
      stats.each do |faction, faction_stats|
        faction_stats["outcomes_by_map"].each do |map, map_stats|
          map_name = map.gsub("V2", "")
          all_maps[map_name] ||= { total_games: 0 }
          all_maps[map_name][:total_games] += map_stats["wins"] + map_stats["losses"]
        end
      end

      # Get top 10 most played maps
      top_maps = all_maps.sort_by { |_, stats| -stats[:total_games] }.first(10).map(&:first)

      # Create datasets for each faction
      stats.each do |faction, faction_stats|
        map_stats = faction_stats["outcomes_by_map"]
        map_data = {}
        
        # Process map stats for this faction
        map_stats.each do |map, stats|
          map_name = map.gsub("V2", "")
          total = stats["wins"] + stats["losses"]
          map_data[map_name] = total > 0 ? (stats["wins"].to_f / total * 100).round(1) : 0
        end

        # Create dataset with win rates for top maps
        win_rates = top_maps.map { |map| map_data[map] || 0 }
        games_played = top_maps.map do |map|
          original_map = map_stats.keys.find { |k| k.gsub("V2", "") == map }
          stats = original_map ? map_stats[original_map] : nil
          stats ? stats["wins"] + stats["losses"] : 0
        end

        # Add win rate dataset
        datasets << {
          label: "#{faction.capitalize} Win Rate %",
          data: win_rates,
          backgroundColor: "#{faction_colors[faction].gsub('rgb', 'rgba').gsub(')', ', 0.7)')}",
          borderColor: faction_colors[faction],
          borderWidth: 1,
        }

        # Add games played dataset
        # datasets << {
        #   label: "#{faction.capitalize} Games",
        #   data: games_played,
        #   backgroundColor: "#{faction_colors[faction].gsub('rgb', 'rgba').gsub(')', ', 0.3)')}",
        #   borderColor: faction_colors[faction],
        #   borderWidth: 1,
        #   yAxisID: 'y'
        # }
      end

      # Create chart config
      config = {
        type: 'horizontalBar',
        data: {
          labels: top_maps,
          datasets: datasets
        },
        options: {
          title: {
            display: true,
            text: "Map Stats for #{player['playerName']} (Top 10 Most Played)"
          }
        }
      }

      # Generate and send chart
      data = fetch_chart(config)
      Tempfile.open(binmode: true) do |t|
        t.write data
        t.rewind
        event.send_file t, filename: "map_stats.png"
      end
    end
  end
end
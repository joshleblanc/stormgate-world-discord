module Commands
  module RaceStatsCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :race_stats, description: "Shows win/loss stats by opponent race" do |event, *args|
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

      # Get all opponent races
      all_races = stats.values.flat_map { |s| s["outcomes_by_opponent_race"].keys }.uniq.sort

      # Create datasets for each faction
      stats.each do |faction, faction_stats|
        race_stats = faction_stats["outcomes_by_opponent_race"]
        race_data = {}
        
        # Process race stats for this faction
        race_stats.each do |race, stats|
          total = stats["wins"] + stats["losses"]
          race_data[race] = total > 0 ? (stats["wins"].to_f / total * 100).round(1) : 0
        end

        # Create dataset with win rates for all races
        win_rates = all_races.map { |race| race_data[race] || 0 }

        # Add win rate dataset
        datasets << {
          label: "#{faction.capitalize}",
          data: win_rates,
          backgroundColor: "#{faction_colors[faction].gsub('rgb', 'rgba').gsub(')', ', 0.7)')}",
          borderColor: faction_colors[faction],
          borderWidth: 1
        }
      end

      # Create chart config
      config = {
        type: 'bar',
        data: {
          labels: all_races.map(&:capitalize),
          datasets: datasets
        },
        options: {
          title: {
            display: true,
            text: "Race Win Rates for #{player['playerName']}"
          }
        }
      }

      # Generate and send chart
      data = fetch_chart(config)
      Tempfile.open(binmode: true) do |t|
        t.write data
        t.rewind
        event.send_file t, filename: "race_stats.png"
      end
    end
  end
end

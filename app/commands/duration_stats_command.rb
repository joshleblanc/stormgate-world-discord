module Commands
  module DurationStatsCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :duration_stats, description: "Shows win/loss stats by game duration" do |event, *args|
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
        "vanguard" => {
          win: "rgba(12, 116, 200, 0.7)",
          loss: "rgba(12, 116, 200, 0.3)"
        },
        "infernals" => {
          win: "rgba(202, 59, 29, 0.7)",
          loss: "rgba(202, 59, 29, 0.3)"
        },
        "celestials" => {
          win: "rgba(140, 48, 175, 0.7)",
          loss: "rgba(140, 48, 175, 0.3)"
        }
      }

      # Find all unique minutes across all factions
      all_minutes = stats.values.flat_map { |s| s["outcomes_by_duration"].values.first.map { |d| d["minute"] } }.uniq.sort

      # For each faction, create win and loss datasets
      stats.each do |faction, faction_stats|
        duration_stats = faction_stats["outcomes_by_duration"].values.first
        duration_map = duration_stats.to_h { |d| [d["minute"], d] }

        # Create wins dataset
        wins = all_minutes.map { |m| duration_map[m]&.fetch("wins", 0) || 0 }
        datasets << {
          label: "#{faction.capitalize} Wins",
          data: wins,
          backgroundColor: faction_colors[faction][:win],
          borderColor: faction_colors[faction][:win].gsub('0.7', '1'),
          borderWidth: 1,
          stack: faction
        }

        # Create losses dataset
        losses = all_minutes.map { |m| duration_map[m]&.fetch("losses", 0) || 0 }
        datasets << {
          label: "#{faction.capitalize} Losses",
          data: losses,
          backgroundColor: faction_colors[faction][:loss],
          borderColor: faction_colors[faction][:loss].gsub('0.3', '0.6'),
          borderWidth: 1,
          stack: faction
        }
      end

      # Create chart config
      config = {
        type: 'bar',
        data: {
          labels: all_minutes.map { |m| "#{m} min" },
          datasets: datasets
        },
        options: {
          title: {
            display: true,
            text: "Game Duration Stats for #{player['playerName']}"
          },
          scales: {
            y: {
              beginAtZero: true,
              stacked: true,
              title: {
                display: true,
                text: 'Games'
              }
            },
            x: {
              stacked: false,
              title: {
                display: true,
                text: 'Game Duration'
              }
            }
          }
        }
      }

      # Generate and send chart
      data = fetch_chart(config)
      Tempfile.open(binmode: true) do |t|
        t.write data
        t.rewind
        event.send_file t, filename: "duration_stats.png"
      end
    end
  end
end

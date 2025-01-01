module Commands
  module MmrHistoryCommand
    extend Discordrb::Commands::CommandContainer
    include Utilities::Helpers

    command :mmr_history, description: "Shows a player's MMR history graph" do |event, *args|
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


      max_games = stats.values.map { |s| s["recent_mmr_history"].size }.max

      p player

      stats.each do |faction, faction_stats|
        mmr_history = faction_stats["recent_mmr_history"]
        datasets << {
          label: faction.capitalize,
          data: (mmr_history + [nil] * (max_games - mmr_history.size)).reverse,
          borderColor: faction_colors[faction],
          tension: 0.1
        }
      end

      # Create chart config
      config = {
        type: 'line',
        data: {
          labels: (1..max_games).to_a,
          datasets: datasets
        },
        options: {
          responsive: true,
          title: {
            display: true,
            text: "MMR History for #{player['playerName']}"
          },
          legend: {
            display: true,
            position: 'top'
          },
          scales: {
            y: {
              beginAtZero: false
            }
          }
        }
      }

      # Generate and send chart
      data = fetch_chart(config)
      Tempfile.open(binmode: true) do |t|
        t.write data
        t.rewind
        event.send_file t, filename: "mmr_history.png"
      end
    end
  end
end

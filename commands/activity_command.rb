module Commands
    module ActivityCommand
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :activity, description: "return activity information for a given player" do |event, *args|
            api = Utilities::Api.new 
            player = api.search(args.join(' '))

            return "No player found for #{args.join(' ')}" unless player

            players_api = StormgateWorld::PlayersApi.new
            activity = players_api.get_player_statistics_activity(player.player_id).aggregated
            event.send_embed do |embed|
                embed.title = "#{player.nickname}'s activity"
                embed.description = ""
                embed.fields = [
                     field("Matches", activity.matches),
                     field("Matches per day", number_with_precision(activity.matches_per_day.average, precision: 2)),
                     field("Wins", activity.wins),
                     field("Losses", activity.losses),
                     field("Ties", activity.ties),
                     field("Win Rate", number_to_percentage(activity.win_rate, { precision: 2 })),
                     field("Max MMR", number_with_precision(activity.mmr.max, precision: 2)),
                     field("Avg MMR", number_with_precision(activity.mmr.average, precision: 2)),
                     field("Points", number_with_precision(activity.points.max, precision: 2)),
                     field("Avg Match Length", ActiveSupport::Duration.build(activity.match_length.average.floor).inspect)
                ]
            end
        end
    end
end

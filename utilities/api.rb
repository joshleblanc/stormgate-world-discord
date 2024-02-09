module Utilities
    class Api 
        URL = "https://api.stormgateworld.com/v0"

        def leaderboard(**kwargs)
            leaderboard_api = StormgateWorld::LeaderboardsApi.new
            leaderboard_api.get_leaderboard(kwargs)
        end

        def ongoing 
            matches_api = StormgateWorld::MatchesApi.new
            matches = matches_api.get_matches(count: 0, page: 1, state: "ongoing")
            matches.total
        end

        def infernal_players
            leaderboard(count: 0, page: 1, race: "infernals").total
        end

        def vanguard_players
            leaderboard(count: 0, page: 1, race: "vanguard").total
        end

        def search(query)
            response = leaderboard(count: 1, page: 1, order: :mmr, query:)
            response.entries.first
        end

        def last(player_id:)
            players_api = StormgateWorld::PlayersApi.new

            players_api.get_player_last_match(player_id)
        end
    end
end
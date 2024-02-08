module Commands
    module LeaderboardCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :leaderboard, description: "Returns the top 10 players on the 1v1 ranked ladder (by mmr)" do |event|
            json = get_leaderboard(count: 10, page: 1, order: :mmr)
        
            leaderboard_response(json)
        end
    end
end

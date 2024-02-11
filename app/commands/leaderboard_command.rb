module Commands
    module LeaderboardCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :leaderboard, description: "Returns the top 10 players on the 1v1 ranked ladder (by mmr)" do |event|
            api = Utilities::Api.new

            page_size = 10 

            pagination_container = Utilities::PaginationContainer.new("Ranked 1v1", page_size, event)

            pagination_container.paginate do |embed, index|
                json = api.leaderboard(count: page_size, page: index + 1, order: :mmr)
                response = "Leaderboard, sorted by MMR\n"
                response << leaderboard_response(json)
                embed.description = response

                json.total
            end
        end
    end
end

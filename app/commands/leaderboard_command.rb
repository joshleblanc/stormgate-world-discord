module Commands
    module LeaderboardCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :leaderboard, description: "Returns the top 10 players on the 1v1 ranked ladder (by mmr)" do |event, page|
            api = Utilities::Api.new

            page = [0, page.to_i].max || 0

            json = api.leaderboard(count: 10, page: page, order: :mmr)

            output = render("leaderboard", {
                json:,
            })
            
            send_html event, output
        end
    end
end

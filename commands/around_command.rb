module Commands 
    module AroundCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers
                
        command :around, description: "Return the page that the given rank falls on" do |event, *args|
            if args.length < 1 
                return "Please enter a rank to search around"
            end

            rank = args.first.to_i

            if rank < 0 
                return "Please enter a positive rank"
            end

            page = (rank / 10.to_f).ceil

            api = Utilities::Api.new

            pagination_container = Utilities::PaginationContainer.new("Around rank #{rank}", 10, event, page: page)

            pagination_container.paginate do |embed, index|
                json = api.leaderboard(page: index, count: 10, order: :points)
                rank_output = rank.to_s.rjust(4, "0")

                response = "Leaderboard, sorted by Points\n"
                response << leaderboard_response(json, "Points")
                
                response.gsub!(/(#{rank_output}\t.+\t.+\t)(.+)(\n)/, '\1\2 <<\3')

                embed.description = response 

                json.total
            end
        end
    end
end
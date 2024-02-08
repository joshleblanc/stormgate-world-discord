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

            data = leaderboard_response(api.leaderboard(page: page, count: 10, order: :points), "Points")

            rank_output = rank.to_s.rjust(4, "0")
            data.gsub!(/(#{rank_output}\t.+\t.+\t)(.+)(\n)/, '\1\2 <<\3')

            data
        end
    end
end
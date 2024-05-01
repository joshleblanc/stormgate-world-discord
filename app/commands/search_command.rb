module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            event.channel.start_typing

            query = args.join(' ')

            api = Utilities::Api.new

            player = api.find_player(query)

            return "No player found for #{query}" if !player || player["detail"] == "Not found."

            if player["ranks"]["ranked_1v1"].nil?
                return "No ranks found for #{player["playerName"]}"
            end
            
            attachments = []
            
            threads = player["ranks"]["ranked_1v1"].map do |race, entry|
                entry["race"] = race
                entry["win_rate"] = (entry["wins"].to_f / (entry["wins"] + entry["losses"])) * 100

                Thread.new do 
                    send_html(event, render("profile_card", {
                        entry:, player:
                    }))
                end
            end

            threads.each(&:join)
            
            nil
        end
    end
end

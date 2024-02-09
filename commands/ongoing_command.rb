module Commands
    module OngoingCommand 
        extend Discordrb::Commands::CommandContainer

        command :ongoing, description: "Return the number of currently active matches" do 
            api = Utilities::Api.new

            return "There are currently #{api.ongoing} ongoing games"
        end
    end
end

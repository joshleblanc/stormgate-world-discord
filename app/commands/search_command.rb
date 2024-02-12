module Commands 
    module SearchCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        TEXT = File.read("app/views/profile_card.html.erb")

        def self.generate_image(html) 
            cache_key = "profile-card/#{html}"

            cached = CACHE.read(cache_key)

            return cached if cached 

            output = `node javascript/htmltoimage.js '#{html}'`

            CACHE.write(cache_key, output)

            output
        end

        command :search, description: "Show details of a player on the 1v1 ranked ladder" do |event, *args|
            event.channel.start_typing

            query = args.join(' ')

            player_api = StormgateWorld::PlayersApi.new
            api = Utilities::Api.new

            player = api.find_player(query)

            return "No player found for #{query}" unless player || player_search
            
            attachments = []
            
            threads = player.leaderboard_entries.map do |entry|
                Thread.new do 
                    template = ERB.new(TEXT)

                    Tempfile.open(binmode: true) do |t|
                        t.write generate_image(template.result(binding))
        
                        t.rewind
                        event.send_file t, filename: "#{entry.race}.png"
                    end
                end
            end

            threads.each(&:join)
            
            nil
        end
    end
end

module Commands 
    module StatsCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers
        
        def self.stat_embed(stats, name)
            value = stats.aggregated.send(name)
            value = if name == "win_rate" || name == "pick_rate"
                NumberToPercentageConverter.convert(value, { precision: 2 })
            else
                NumberToDelimitedConverter.convert(value, {})
            end
            EmbedField.new(name: name.to_s.titleize, value:, inline: true)
        end

        command :stats, description: "Return aggregate statistics" do |event, league| 
            league = league&.downcase 

            if league && !VALID_LEAGUES.include?(league) 
                return "Please enter a value league. Valid leages are: #{VALID_LEAGUES.join(', ')}"
            end

            stats_api = StormgateWorld::StatisticsApi.new
            stats = stats_api.get_statistics(league: league)

            keys = ["win_rate", "pick_rate", "players_count", "matches_count", "wins_count", "losses_count", "matches_count_with_mirror"]
            
            fields = []

            stats.races.each do |race|
                inner_fields = []
                inner_fields << EmbedField.new(name: race.race.titleize, value: "", inline: true)
                inner_fields.push *keys.map { |key| self.stat_embed(race, key) }

                fields << inner_fields
            end

            fields.insert(1, [blank] * keys.size.next) unless stats.races.size > 2

            event.send_embed do |embed|
                embed.fields = fields.transpose.flatten
                if league
                    embed.description = "Stats for #{league} league"
                else
                    embed.description = "Stats for all leagues"
                end
            end
        end
    end
end
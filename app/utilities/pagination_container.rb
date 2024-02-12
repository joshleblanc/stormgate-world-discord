module Utilities
    class PaginationContainer
        include Discordrb::Webhooks
        include Discordrb::Events
    
        def initialize(title, page_size, event, page: 1)
            @index = page
            @total = 1
            @user = event.user
            @event = event
            @embed = Embed.new(title: title)
            @embed.footer = EmbedFooter.new
            @embed.footer.text = "Page #{@index}/#{@total} (#{@total} entries)"
            @embed.author = EmbedAuthor.new
            @embed.author.name = @user.name
            @embed.author.icon_url = @user.avatar_url
            @page_size = page_size.to_f
        end
    
        def paginate(&blk)
            @update_block = -> {
                @total = blk.call(@embed, @index)
                @embed.footer.text = "Page #{@index + 1}/#{num_pages} (#{@total} entries)"
            }
            @update_block.call
            send
        end
        private
    
        def send
            @message = @event.respond nil, false, @embed
            add_reactions
            add_awaits
        end
    
        def num_pages
            (@total / @page_size).ceil
        end
    
        def add_reactions
            # this takes forever to do because of rate limiting, so
            # do it in a new thread so we can immediately add the awaits
            Thread.new do
                Thread.current.abort_on_exception = true
                @message.create_reaction("⏮")
                @message.create_reaction("◀")
                @message.create_reaction("▶")
                @message.create_reaction("⏭")
            end
        end
    
        def update
            @update_block.call
            @message.edit nil, @embed
        end
    
        def add_awaits
            threads = []
            emojis = {
                start: "⏮",
                back: "◀",
                next: "▶",
                end: "⏭"
            }
            loop do 
                response = BOT.add_await!(ReactionAddEvent, timeout: 60)

                break unless response
                next unless response.user.id == @user.id && response.message.id == @message.id
                Thread.new do
                    case response.emoji.name
                    when emojis[:start]
                        @index = 0 unless @index == 0
                    when emojis[:back]
                        @index -= 1 if @index > 0
                    when emojis[:next]
                        @index += 1 if @index < @total - 1
                    when emojis[:end]
                        @index = num_pages - 1 unless @index == num_pages
                    end
                    if emojis.values.include?(response.emoji.name)
                        update
                        @message.delete_reaction(response.user.id, response.emoji.name)
                    end
                end
            end
            begin
                @message.delete_all_reactions
            rescue StandardError => e
                p "Failed to remove reaction from pagination container"
                nil
            end
        end
    end
end

module Commands 
    class CardCommand 
        extend Discordrb::Commands::CommandContainer
        include Utilities::Helpers

        command :card do |event|
            client = HTMLCSSToImage.new

            text = File.read("app/views/profile_card.html.erb")
            template = ERB.new(text)

            image = client.create_image(template.result(binding), css: "body { background-color: transparent; }", google_fonts: "Nunito+Sans")


            image.url
        end
    end
end

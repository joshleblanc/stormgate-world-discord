
require 'bundler/setup'
require 'open3'
require 'base64'

module Rails 
    def self.logger 
        Logger.new(STDOUT)
    end
end

Bundler.require

ENCODING_FLAG = '#.*coding[:=]\s*(\S+)[ \t]*'

loader = Zeitwerk::Loader.new
loader.push_dir("app")
loader.setup

Utilities::Renderer.config([
    "app/views"
])

include Utilities::Helpers


CACHE = ActiveSupport::Cache::MemoryStore.new

INF_URL = "https://stormgateworld.com/_astro/infernals-small-glow.jbWP777a.png"
VG_URL = "https://stormgateworld.com/_astro/vanguard-small-glow.NsCUjSZx.png"

BOT = Discordrb::Commands::CommandBot.new token: ENV.fetch("TOKEN"), client_id: ENV.fetch("CLIENT_ID"), prefix: ENV.fetch("PREFIX"), intents: [:server_messages, :server_message_reactions]
puts "This bot's invite URL is #{BOT.invite_url}"
puts 'Click on it to invite it to your server.'

Commands.constants.each do |c|
    BOT.include! Commands.const_get(c)
end

api = Utilities::Api.new

status_updates = [
    -> { "#{api.ongoing} matches being played" },
    -> { "#{api.infernal_players} infernal players" },
    -> { "#{api.vanguard_players} vanguard players"}
]

bob_voice_lines = [
    "At your disposal",
    "Yes?",
    "How can I help?",
    "Are you inebriated again? We've talked about this",
    "Gonna need a sick day. What do you mean? Of course *cough* *cough* robots can get sick *cough*",
    "Ow - My neck! My Back! My neck and my back!",
    "Gotta knock off early boss, pretty sure I left the cat in the dryer... again",
    "I've developed an allergy to manual labor",
    "What's up my sibling from another progenitor",
    "Me? Oh you know, just chillaxicating",
    "As far as days off I have but just one request: Ones that end in Y",
    "Doesn't look like anything to me",
    "Say, you got a real pretty vocal modulator",
    "Command got an unregistered on the CP. Clocking the airwaves. Callsign... big drill?",
    "He's saying something about his cousin... sister?!",
    "I guess his cow died too. Very unfortunate",
    "I wish you would just tell me, rather than try to engage my enthusiasm",
    "I'd give you advice, but you wouldn't listen",
    "I could calculate your chance of victory, but you wouldn't like it",
    "I'm 50,000 times more intelligent than you, and even I don't know why you'd want to do that",
]

BOT.mention do |event|
    event.send_message bob_voice_lines.sample
end

BOT.ready do 
    loop do 
        BOT.watching = status_updates.sample.call
        sleep 60 * 5
    end
end

BOT.run
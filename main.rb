require 'bot.class.rb'

botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordia', 'rubicante', 0)
$active = true
while 1
  botty.start
end

#ugly hack
#`ruby main.rb`


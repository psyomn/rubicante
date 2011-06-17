require 'bot.class.rb'

botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordiabottest', 'rubicante-beta', 0)
$restart = false
while $restart == false
  botty.start
end

#ugly hack
#`ruby main.rb`


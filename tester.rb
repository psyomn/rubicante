load 'bot.class.rb'

botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordiabottest', 'rubicante-beta', 0)

while botty.mStatus != nil
  if botty.mStatus == 2
    load 'bot.class.rb'
  elsif botty.mStatus == 1
    break
  end
  botty.start
end

#ugly hack
#`ruby main.rb`


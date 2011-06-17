load 'bot.class.rb'

botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordia', 'rubicante', 0)

while botty.mStatus != nil
  if botty.mStatus == 2
    botty.destroy
    load 'bot.class.rb'
    botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordia', 'rubicante', 0)
  elsif botty.mStatus == 1
    break
  end
  botty.start
end

#ugly hack
#`ruby main.rb`


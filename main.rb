botty = nil
while 1
  #status of 2 is reload
  if botty
    case botty.mStatus
    #status of 1 is exit program
    when 1    
      botty.destroy
      break
    #status of 2 is reload
    when 2
      botty.destroy
    end
  end
  load 'bot.class.rb'
  botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordia', 'rubicante', 0)
  botty.start
end

#ugly hack
#`ruby main.rb`


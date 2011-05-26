require_relative 'bot.class.rb'

botty = Bot.new('irc.freenode.net', 6667, '#spaceconcordia', 'rubicante', 1)

botty.start


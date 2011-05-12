require_relative 'irc.class.rb'

botty = Bot.new('irc.freenode.net', 6667, '#shameful', 'rubicante')

botty.start


def process(msg, bot)
  msg =~ /(\w+)[ ]?(.*)/i
  case $1
  when 'say'
    bot.msgChannel($2)
  end
end


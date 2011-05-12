# Author:: psyomn, with gratuitous help form stack overflow, and google
# This is a small bot written to store logs of chat messages on irc.
# It's aim is to be on a channel 24/7 and log all the messages into
# text files so that a team can refer to them if needed.
# It provides the bare essentials of the simplest bot.

require 'socket'

class Bot 
 
  attr_accessor :mHostname  # the hostname of the irc server
  attr_accessor :mPort      # the port to connect to (standard should be 6667)
  attr_accessor :mChannel   # the channel to join
  attr_accessor :mNick      # the nick of the bot
  attr_reader   :mSocket    # the socket information stored as member

public 
  # default constructor 
  def initialize(hostname,port,channel,nick)
    @mHostname = hostname
    @mPort = port.to_i
    @mChannel = channel
    @mNick = nick 
    @mList = Array.new

    puts "Rubicante was initialized with following credentials"
    puts "  - hostname " + @mHostname
    puts "  - mPort    " + @mPort.to_s
    puts "  - mChannel " + @mChannel
    puts "  - mNick    " + @mNick
    
    ObjectSpace.define_finalizer(self, (:destroy).to_proc)
  end

  # Destructor to make sure that the final logs are written in
  # the logfile. 
  # TODO this is not working properly
  def destroy
    if @mList.size > 0
      str = @mList.join
      dt = Time.now.localtime
      fname =  dt.year.to_s + "_" + dt.month.to_s + "_" + dt.day.to_s
      fh = File.open("logs/" + fname + ".txt", "a")
      fh.write(str)
      fh.close
      @mList.clear
    end
    puts "Dumped final logs."
  end

  def start
    connect
  end

  # and our obligatory FF quote here.
  def rubicante_message
    @mSocket.puts "PRIVMSG #{@mChannel} : I respect men like you. Men with...courage. " + 
    " But you are a slave to your emotions, and so will never know true strength." + 
    " Such is the curse of men."
  end

  # connection routine to connect to the irc server
  # it also satisfies basic protocol requirements. 
  def connect
    @mSocket = TCPSocket.open(@mHostname,@mPort)
    print("addr| ", @mSocket.addr.join(":"), "\n")
    print("peer| ", @mSocket.peeraddr.join(":"), "\n")
    @mSocket.puts "USER testing 0 * Testing"
    @mSocket.puts "NICK #{@mNick}"
    @mSocket.puts "JOIN #{@mChannel}"

    # print the silly message for the lolz
    rubicante_message 

    until @mSocket.eof? do
      msg = @mSocket.gets
              
      # respond to server pings
      if msg =~ /ping/i 
        @mSocket.puts "PONG :pingis "
        puts "Received ping, sent pong"
      else
        # make the message have a prefix of a unix timestamp
        # and store it only if it's not a ping from server
        @mList.push(Time.now.to_i.to_s + " " + msg) 
      end

      # Less redundant writting
      # filenames are date, easy archiving, and date search for later
      if @mList.size > 0 
        str = @mList.join
        dt = Time.now.localtime
        fname =  dt.year.to_s + "_" + dt.month.to_s + "_" + dt.day.to_s
        fh = File.open("logs/" + fname + ".txt", "a")
        fh.write(str)
        fh.close
        @mList.clear
        puts "Dumped logs."
      end
    end
  end

end

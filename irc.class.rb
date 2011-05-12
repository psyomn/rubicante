# Author:: psyomn, with gratuitous help form stack overflow, and google
# This is a small bot written to store logs of chat messages on irc.

require 'socket'

class Bot 
 
  attr_accessor :mHostname  # the hostname of the irc server
  attr_accessor :mPort      # the port to connect to (standard should be 6667)
  attr_accessor :mChannel   # the channel to join
  attr_accessor :mNick      # the nick of the bot
  attr_reader   :mSocket    # the socket information stored as member

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
      # make the message have a prefix of a unix timestamp
      @mList.push(Time.now.to_i.to_s + " " + msg) 
      
      # Less redundant writting
      # filenames are date, easy archiving, and date search for later
      if @mList.size > 5 
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

  def send
  end

  def read
  end

  def start
    connect
  end

  # and our obligatory FF quote here.
  def rubicante_message
    @mSocket.puts "PRIVMSG #{@mChannel} : I respect men like you. Men with...courage. But you are a"
    @mSocket.puts "PRIVMSG #{@mChannel} : slave to your emotions, and so will never know true strength. Such is the curse of men."
  end

  # why is this even here
  def silly_message
    @mSocket.puts "PRIVMSG #{@mChannel} : AHHHH. AFTER 5000 YEARS I'M FREE!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : TIME TO CONQUER EARTH!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : CHUG CHUG GHUG, CHUG CHUG CHUG, CHUG CHUG GHUGCHUG!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : CHUG CHUG GHUG, CHUG CHUG CHUG, CHUG CHUG GHUGCHUG!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : THEY'VE. GOT. A POWER AND A FORCE YOU NEVER SEEN BEFORE! "
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : CHUG CHUG GHUG, CHUG CHUG CHUG, CHUG CHUG GHUGCHUG!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : THEY'VE. GOT. THE ABILITY TO MORPH AND EVEN UUUUUUP. THE SCORE."
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : CHUG CHUG GHUG, CHUG CHUG CHUG, CHUG CHUG GHUGCHUG!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : NO ONE. CAN EVER BRING THEM DOWN *CHUG CHUG* THEY HAVE THE POWER ON THEIR SAAA-IEE-AAII-EEIII-AIDE!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : GO GO POWER RANGERS!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : GO GO POWER RANGERS!"
    sleep(3)
    @mSocket.puts "PRIVMSG #{@mChannel} : GO GO POWER RANGERS! YOU MIGHTY MORPHIN' POWER RANGGGEEERRSSSSS."
  end

end

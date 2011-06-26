# Author:: psyomn, with gratuitous help form stack overflow, and google
# This is a small bot written to store logs of chat messages on irc.
# It's aim is to be on a channel 24/7 and log all the messages into
# text files so that a team can refer to them if needed.
# It provides the bare essentials of the simplest bot.

require 'socket'
require 'db.class.rb'
require 'ftools'

class Bot 
 
  attr_accessor :mHostname    # the hostname of the irc server
  attr_accessor :mPort        # the port to connect to (standard should be 6667)
  attr_accessor :mChannel     # the channel to join
  attr_accessor :mNick        # the nick of the bot
  attr_accessor :mStoreMethod # How to store the message (flat file, mysql, ...)
  attr_reader   :mSocket      # the socket information stored as member
  attr_reader   :mDBHandle    # the db handler stored as object
  attr_accessor :mStatus      # holds the status of the bot

  # Default constructor (see the parameter list for more info)
  #  *hostname: (eg: irc.freenode.net)
  #  *port:     (eg: 6667 is standard port)
  #  *channel:  (eg: #somechannel)
  #  *nick:     (eg: rubicante)
  #  *strmethod: this is the method of storage. At the momment there
  #              are only two ways. One is a text flat file with unix
  #              timestamps. The other is using a mysql database. Set
  #              to 0, 1 respectively for storage methods. 
  #    * 0 : unix timestamped text logs
  #    * 1 : MySQL database (you'll need to set credentials below)
  def initialize(hostname,port,channel,nick,strmethod=0)
    @mHostname = hostname
    @mPort = port.to_i
    @mChannel = channel
    @mNick = nick 
    @mList = Array.new
    @mStoreMethod = strmethod
    # status of 0 is active
    @mStatus = 0

    
    # Create the object only if needed. 
    # IMPORTANT - You need to suply the info to your mysql database in this part
    # TODO maybe the credentials should be set in a different way instead of 
    #      hardcoding them. 
    #   usage: DBLogs.new('host','username','password','databasename')
    if @mStoreMethod == 1 then @mDBHandle = DBLogs.new('localhost','rubicante','ruby-bot','rubicante') end

    storeDebug("Rubicante was initialized with following credentials")
    storeDebug("  - hostname " + @mHostname)
    storeDebug("  - mPort    " + @mPort.to_s)
    storeDebug("  - mChannel " + @mChannel)
    storeDebug("  - mNick    " + @mNick)
    if @mStoreMethod == 0 then storeDebug("  - Using flat file storage") end
    if @mStoreMethod == 1 then storeDebug("  - Using database storage system ") end
    
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
      fh = File.open("logs/" + fname, "a")
      fh.write(str)
      fh.close
      @mList.clear
    end
    @mSocket.close
    storeDebug("Dumped final logs.")
  end

  # Interface function for starting up everything
  def start
    while 1
      connect
      monitor
      if @mStatus == 1
        destroy
	break
      elsif @mStatus == 2
	break
      end
    end
  end

private
 
  # and our obligatory FF quote here.
  def rubicante_message
    #@mSocket.puts "PRIVMSG #{@mChannel} : I respect men like you. Men with...courage. " + 
    #" But you are a slave to your emotions, and so will never know true strength." + 
    #" Such is the curse of men."
    @mSocket.puts "Long ago in a distant land, I, Aku, the shape-shifting Master of Darkness, unleashed an unspeakable evil..."
  end 

  # Simple interface for choosing between different mediums of
  # storage for each case.
  def store(msg)
    case @mStoreMethod
      when 0 # FLAT FILE
        dt = Time.now.localtime
	str = dt.hour.to_s + ":" + dt.min.to_s + ":" + dt.sec.to_s + " -- " + msg 

        # Less redundant writting
        # filenames are date, easy archiving, and date search for later
        dt = Time.now.localtime
        fname =  dt.year.to_s + "_" + dt.month.to_s + "_" + dt.day.to_s
        fh = File.open("logs/" + fname + ".txt", "a")
        fh.write(str)
        fh.close
        storeDebug("Dumped logs.")
      when 1 # MYSQL 
        @mDBHandle.storeMessage(msg) 
    end
  end

  def storeDebug(msg)
    dt = Time.now.localtime
    msg = dt.to_s + ' -- ' + msg
    #msg = dt.hour.to_s + ":" + dt.min.to_s + ":" + dt.sec.to_s + " -- " + msg
    fname =  dt.year.to_s + "_" + dt.month.to_s + "_" + dt.day.to_s
    fh = File.open("debug-logs/" + fname + ".txt", "a")
    fh.write(msg)
    fh.close
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
    @mSocket.puts "PRIVMSG NickServ identify ruby-bot"

    # print the silly message for the lolz
    rubicante_message 
  end

  def msgChannel(msg)
    @mSocket.puts("PRIVMSG #{@mChannel} " + msg)
  end

  def monitor
    until @mSocket.eof? or @mStatus > 0 do
      raw = @mSocket.gets
      storeDebug(raw)

      raw =~ /(:([^!]+)![^@]+@[\S]+ )?([A-Z]+) ([#\w\-\.]+ )?:(.*)/i
      nick    = $2
      command = $3
      obj     = $4
      extra   = $5

      # respond to server pings
      case command
      when "PING"
	@mSocket.puts "PONG :pingis"
	storeDebug(raw)
        storeDebug("Received ping, sent pong\n")
      when "JOIN"
	msg = nick + ' joined ' + extra
	store(msg)
      when "PRIVMSG"
	#storeDebug("got a msg " + obj + @mChannel + " \n")
	  msg = '[' + nick + '] ' + extra
	  store(msg)
       
	if obj == @mNick
	  extra =~ /(\w) (.*)/i
	  if    $1 == 'do'
	    @mSocket.puts $2
	  elsif $1 == 'op'
	    @mSocket.puts 'MODE '
	  elsif $1 == 'reload'
            # A status of 2 is restarting
            @mStatus = 2
            storeDebug("reloading class")	
	  elsif $1 == 'die'
            # A status of 1 is dying
            msgChannel "you killed me!"
            storeDebug("received die command")
            @mStatus = 1
            @mSocket.puts "QUIT"
            @mSocket.close
	  end
	end
      when "QUIT"
	msg = nick + ' quit with the words: ' + extra
	store(msg)
#      elsif raw =~ /rubicante (\w+)(.*)/i
#	case $1
#       when "ping"
#        msgChannel("pong :pingis ")
#	  storeDebug("ping requested")
        #when "op"
        #  @mSocket.puts "MODE 
#        when "reload"
	  # A status of 2 is restarting
#          @mStatus = 2
#	  storeDebug("reloading class")
	  #msgChannel("reloading")
#        when "die"
#	  # A status of 1 is dying
#	  msgChannel "you killed me!"
#          storeDebug("received die command")
#          @mStatus = 1
#	  @mSocket.puts "QUIT"
#	  @mSocket.close
#	when "do"
#	  @mSocket.puts $2
#        end
#	store(raw)
#      else
        # make the message have a prefix of a unix timestamp
        # and store it only if it's not a ping from server
#        store(raw)
      end

    end
  end

end


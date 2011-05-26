# Author:: psyomn (mailto:psyomn@xenagoras.net)
# Simple wrapper class for our datbase needs. 
# This class requires a running MySQL datbase and the
# ruby-mysql package installed
 
require 'mysql'

class DBLogs 
  
  attr_accessor :mHost # Host to connect to
  attr_accessor :mUser # User for mysql
  attr_accessor :mPassword # The password to the database
  attr_accessor :mDBName # The database name that we will use
  attr_reader :mResource # Store the connection / resource for later

  # Default constructor, requiring specified db info
  def initialize(host,user,pass,dbname)
    @mHost = host
    @mUser = user
    @mPassword = pass
    @mDBName = dbname

    @mResource = Mysql.new(@mHostname,@mUser,@mPassword,@mDBName)
    puts "DB Connection Successful. " 
    
    # See if table which insertions occurs exist 
    checkifexists
  end

  # Standard routine in order to store the message in the database
  def storeMessage(msg)
    msg = msg.gsub("\'", "\\\\'")
    msg.strip! # remove all the whitespaces trailing from irc
    dt = Time.now

    # This part splits the messages to store them into the database
    line = msg
    line.chomp!
    tmp = Array.new

    # What to ignore

    # The if statement makes sure that what is being stored
    # is none from the welcome messages from irc.freenode.net 
    # This is somewhat a hack because I'm negating all the raw
    # numerals from IRC, and taking 0 as a true case (IRC raw
    # numerals do not include 0, but converting a string "example"
    # to an integer will make it 0). 
    if line.split[1] == "PRIVMSG" and (line.split[1].to_i < 1 or line.split[1].to_i > 606) then
      
      # This part splits up all the needed information to put inside
      # the database. It might need some cleaning up, because I wrote this
      # in a rush 
      # TODO clean up the splitting code.
      
      puts "INSIDE IF! line = " + line 

      tmp = line.split('!~')
      username = tmp[0]
      username = username.split('') # get rid of the ':'
      username.shift
      username = username.join 

      tmp = tmp[1].split
  
      clienthost = tmp[0]
      action = tmp[1]
      channel = tmp[2]
      tmp.shift # get rid of the other two parts
      tmp.shift 
      tmp.shift
  
      message = tmp.join(' ').gsub(':', '')
   
      # Form the query as string for better readability
      que  = "INSERT INTO rubicante_logs(timestamp, nickname, clienthost, action, channel, msg) VALUES ('"
      que += dt.to_s  + "', '"
      que += username + "', '"
      que += clienthost + "', '"
      que += action + "', '"
      que += channel + "', '" 
      que += message + "');"
      
      # Perform the query using the MySQL object! 
      @mResource.query(que)
      puts "derp" 
    else 
      puts "Ignoring numeral " + line.split[1] 
    end
  end

private 

  # This function will check if the needed table from rubicante exists
  # if it does not, it creates the table.
  def checkifexists
    que  = " CREATE TABLE IF NOT EXISTS rubicante_logs ( "
    que += " id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, "
    que += " timestamp DATETIME, "
    que += " nickname VARCHAR(31), "
    que += " clienthost VARCHAR(255), "
    que += " action VARCHAR(20), "
    que += " channel VARCHAR(100), "
    que += " msg TEXT "
    que += " );"

    # Perform the query! 
    @mResource.query(que) 
  end

end

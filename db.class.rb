# Author:: psyomn (mailto:psyomn@xenagoras.net)
# Simple wrapper class for our datbase needs. 
# This class requires a running MySQL datbase and the
# ruby-mysql package installed
 
require 'ruby-mysql'

class DBLogs 
  
  attr_accessor :mHost # Host to connect to
  attr_accessor :mUser # User for mysql
  attr_accessor :mPassword # The password to the database
  attr_accessor :mDBName # The database name that we will use
  attr_reader :mResource # Store the connection / resource for later

public 

  # Default constructor, requiring specified db info
  def initialize(host,user,pass,dbname)
    @mHost = host
    @mUser = user
    @mPassword = pass
    @mDBName = dbname

    @mResource = Mysql.new(@mHostname,@mUser,@mPassword,@mDBName)
    
    # See if table which insertions occurs exist 
    checkifexists
  end

  # Standard routine in order to store the message in the database
  def storeMessage(msg)
    dt = Time.now
    que  = "INSERT INTO rubicante_logs(timestamp, msg) VALUES ('"
    que += dt.to_s + "',  '"
    que += msg + "');"

    @mResource.query(que)
  end

private 

  # This function will check if the needed table from rubicante exists
  # if it does not, it creates the table.
  def checkifexists
    que  = " CREATE TABLE IF NOT EXISTS rubicante_logs ( "
    que += " id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, "
    que += " timestamp DATETIME, "
    que += " msg TEXT "
    que += " );"

    # Perform the query! 
    @mResource.query(que) 
  end

end

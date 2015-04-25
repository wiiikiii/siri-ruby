#!/usr/bin/env ruby

require './note.rb'

# ----------------------------------
# external command we've bind
# ----------------------------------
def switch_light_on
  puts "*** switch_light_on"
  true
end

# ----------------------------------
# external command we've bind
# ----------------------------------
def switch_light_off
  puts "*** switch_light_off"
  true
end

# -----------------------------------------------
# main
# username and password, server, ssl
# -----------------------------------------------
note = Notes.new( USERNAME, PASSWD ).build do

  # ------------------------------------------------
  # add_command a global accessable function and the 
  # command strings we can call from iphone siri
  # ------------------------------------------------
  add_command( :switch_light_on, [ "licht an", "licht ein" ] )
  add_command( :switch_light_off, [ "licht aus", "kein licht", "nicht licht" ] )

end.run( 'iphone' ) do | item |
  # ------------------------------
  # if we like, we can handle other
  # items from the notes mailbox
  # especially
  # ------------------------------
  puts "handle in a block ------------------"
  pp item
  puts "handle in a block ------------------"
end

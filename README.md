# siri-ruby

We use siri to create notes, we then read from icloud imap server and execute commands

The idea was stolen from SiriAPI8. But because I do not like programming in python
I rewrote the class in ruby.

At the moment the program in only working with os x 10.10 and before.
Notes added with ios 9 and after are no longer accessable with imap.

A simple workaround is to dictate a mail with the defined subject to the own mail account.

    "send a mail to office, light off"
    
The new version handles text and subject with defined keys.    

Quite simple.

### Create and connect to server

    note = Note.new( USERNAME, PASSWD )

### DSL for creating commands and bind strings

    note.build do
      add_command( :switch_light_on, [ "light on", "make light", "lightning" ] ),
      add_command( :switch_lign_off, [ "light off", "make it dark", "off" ] )
    end.
       
### Running and bind to keyword

    note.run( 'iphone' ) do | item |
       # optional block if you like to make something special
       # with item
       pp item
    end

### Create commands

    # ----------------------------------
    # external command we've bind
    # ----------------------------------
    def switch_light_on
      puts "*** switch_light_on"
      Piface.write 0, 1
      true # if true message will be deleted from imap server
    end

    # ----------------------------------
    # external command we've bind
    # ----------------------------------
    def switch_light_off
      puts "*** switch_light_off"
      Piface.write 0, 0
      true
    end

## References

http://blog.smartnoob.de/2015/01/26/siriapi8-siri-api-fuer-ios8/#more-1010
https://github.com/HcDevel/SiriAPI8/blob/master/SiriAPI8/SiriAPI.py
https://github.com/tpitale/mail_room
https://gist.github.com/oogali/3528688
https://github.com/ConradIrwin/em-imap/blob/5424d9b4cf87488604e295cad3aadc3d9b723fdc/lib/em-imap/client.rb
https://gist.github.com/solyaris/b993283667f15effa579

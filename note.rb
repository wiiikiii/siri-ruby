#!/usr/bin/env ruby

require 'rubygems'
require "pp"
require 'net/imap'
require 'time'
 
# Net::IMAP.debug = true 

trap("SIGINT") { throw :ctrl_c }
trap("INT") { throw :ctrl_c }

#
# Notes is a siri interface 
#
# we use siri to create notes. the default storeage for notes
# must be the imap server (icloud or an other) we connect to.
#
# we connect once and use the idle feature in imap to wait for
# other commands/messages.
# 
# the notes includes commands we can define
# is a string found, we can bind it to a command that will be executed
#

class Notes

  def initialize(username, passwd, host = 'imap.mail.me.com', port = 993, ssl = true )
    @imap = Net::IMAP.new host, port, ssl
    @imap.login username, passwd
    @imap.select 'Notes'
    @commands ||= []
  end
  
  # ----------------------------------------
  # some dsl calling
  # ----------------------------------------
  def build &block
    return unless block_given?
    instance_eval( &block )
    self
  end
  
  # ----------------------------------------
  # only avaliable command for dsl
  # ----------------------------------------
  def add_command( func, commands )
    @commands.push( { func => commands } )
  end

  # ----------------------------------------
  # did we receive an command we've created
  # ----------------------------------------
  def find_and_exec_command( text )
    commands = @commands.select do | cmd | 
      f = cmd.values.flatten.select { | c | text.match( /#{c}/ ) } 
      cmd if f.size > 0
    end.each do | item |
      return eval( "#{item.keys.first}()" )
    end
    false
  end

  # ----------------------------------------
  # after all initialisation is done, we run
  # ----------------------------------------
  def run( keyword = 'iphone' &block )
    loop do
      @imap.idle do | resp |
        if resp.kind_of?( Net::IMAP::UntaggedResponse ) and resp.name == "EXISTS"
          @imap.idle_done
        end
      end
      # @list = @imap.sort(['DATE'], ['ALL'], 'US-ASCII').reverse
      @list = @imap.uid_search( ["SUBJECT", keyword ] )
      if block_given?
        @list.each do | id | 
          get id, &block  
        end
      end
      @imap.expunge
    end
    self
  end
  
  def delete( uid )
    @imap.uid_store( uid, "+FLAGS", [:Deleted] )
  end
  
  def unseen( uid )
    @imap.uid_store( uid, "+FLAGS", [:Seen] )
    @imap.uid_store( uid, "-FLAGS", [:Deleted] )
  end
  
  def close
    @imap.logout
    @imap.disconnect
  end
  
  def get( num, &block )
    begin
      if note = @imap.uid_fetch( num, [ 'UID', 'RFC822.TEXT', 'RFC822.HEADER'])
        note = note.first
        uid = note.attr[ "UID" ]
        text = note.attr[ "RFC822.TEXT" ]
        header = note.attr[ "RFC822.HEADER" ]
        if block_given?
          param = { :uid => uid, :text => text, :header => header }
          yield param
        end
        ret = find_and_exec_command( text )
        if ret
          delete( uid ) 
        else
          unseen( uid )
        end
      end
    rescue Exception => e
      puts "- in rescue"
      note = nil
      pp e
    end
  end
  
end

#catch :ctrl_c do
#  note.close
#end

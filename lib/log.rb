#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# sevkme@gmail.com

require 'logger'
require 'fileutils'

$logDir = File.join(Dir.pwd , 'log') if not defined? $logDir
if not File.directory? $logDir
  Dir.mkdir $logDir
end

unless defined? Myname
  Myname = File.basename($0, ".rb")
end
puts File.join($logDir,Myname + '.log')
$zip_log ||= false

def zip_log
   return unless $zip_log
   s_log = "#$logDir/#{Myname}.log"
   if File.exist? s_log
      d_now = "#$logDir/#{Myname}.log.7z"
      s_now = "#$logDir/#{Myname}1.log"
      FileUtils.cp(s_log,s_now)
      system("start /min cmd /c 7z a #{d_now} #{s_now}")
   end

   yd = (Time.now-86400).strftime("%Y%m%d")
   s = "#$logDir/#{Myname}.log.#{yd}"
   if File.exist? s
      d1 = "#$logDir\\#{yd}_#{Myname}.log.7z"
      unless File.exist? d1
         system("start /min cmd /c 7z a #{d1} #{s}")
      else
         FileUtils.rm s
      end
      p ' 7z cab log ok '
   end
end

def log_init
  $log_init.exit if defined? $log_init
  $log_init = Thread.new{
     Thread.current[:name] = 'Log file to cab '
     loop do
        sleep 60
        zip_log rescue(p $!.message,$@)
        sleep 1740
     end
  }
end
log_init

def log(s=nil)
   if not s
      if $!
         s = "#{$!.message} #{$@[0..4].join("\n")}"
      else
         return
      end
   elsif s.empty?
     puts "#{$!.message} #{$@.join("\n")}"
     return
   else
      s = s.to_s
      #s << " #{caller[0]} " if $DEBUG
   end
   if s.bytesize < 600
      p s
   end

   if $!
      f= Myname + '-err.log'
      p f
      f = Logger::LogDevice.new(File.join($logDir,f))
      p f
      le = Logger.new(f ,shift_age=30,shift_size = 1200000)
      le.datetime_format = "%m-%d %H:%M:%S"
      le.debug s
      le.close
   else
      f= Myname + '.log'
      p f
      f = Logger::LogDevice.new(File.join($logDir,f))
      if $zip_log
         l = Logger.new(f , 'daily' )
      else
         l = Logger.new(f ,shift_age =33, shift_size = 1200000)
      end
      l.datetime_format = "%m-%d %H:%M:%S"
      l.info s
      l.close
   end
   nil
end



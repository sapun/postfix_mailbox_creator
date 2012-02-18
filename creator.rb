#!/usr/bin/env ruby
require "rubygems"
require "net/smtp"
require "mysql2"
require 'yaml'
RE_EMAIL = /^[A-Za-z][._A-Za-z\d-]+@[A-Za-z\d][._A-Za-z\d-]+\.[A-Za-z]{2,}$/

class Creter_mails

	def initialize(email)
		if email =~ RE_EMAIL
			@email = email
			puts @email
		else
			puts "email is not valid"
			exit
		end
		@local_part = @email.split("@").first
		@domain = @email.split("@").last
		@password_now = random_password
		@body_hello_message = "now empty"
	end

	def create_mail
		connect_mysql
		p @mysql_connection
		result = @mysql_connection.query("SELECT * FROM `domain` WHERE `domain` = 'gorod-skidokdd.com' ").count
		p result
		#result.each { |e| puts e }
		a = mail_exist?
		if mail_exist? == false
			puts "this mail alredy exists"
			exit
		end
		if domain_exist?
			puts "this domain unregistred"
			exit
		end	
		@mysql_connection.query("INSERT INTO `postfix`.`mailbox` (`username`, `password`, `name`, `maildir`, `quota`,
							 `local_part`, `domain`, `created`, `modified`,
							 `active`) VALUES ('@email', '@password_now',
							 '@local_part', '@domain/@@email/', '0',
							  '@local_part', '@domain', 'Time.now', 'Time.now', '1'")
		
	end

	protected
	def mail_exist?
		if @mysql_connection.query("SELECT * FROM mailbox WHERE username='#{@email}'").count > 0
			return false
		end
		return true
	end

	def domain_exist?
		if @mysql_connection.query("SELECT * FROM domain WHERE domain= '#{@domain}'").count > 0
			return false
		end
		return true
	end

	def connect_mysql
		config = File.open("mysql_config.yaml")
		yp = YAML::load_documents( config ) { |param|
	  	#puts "#{param['hostname']} #{param['database']} #{param['username']} #{param['password']}"
	  	@mysql_connection = Mysql2::Client.new(:host => "#{param['hostname']}",
	  										   :username => "#{param['username']}",
	  										   :password => "#{param['password']}", 
	  										   :database => "#{param['database']}")
		}
		#p yp	
	end	

	def initial_message
		config = File.open("smtp_config.yaml")
		yp = YAML::load_documents( config ) { |param|
			smtp = Net::SMTP.start("#{param['smtp_server']}","#{param['port']}","#{param['smtp_server']}",
            					    "#{param['username']}", "#{param['password']}", :login)
        	smtp.send_message @body_hello_message, "#{param['smtp_server']}", @email
        	smtp.finish
        }
	end

	def random_password(size = 10)
  		chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
  		(1..size).collect{|a| chars[rand(chars.size)] }.join
	end
end


if ARGV[0]
	email = Creter_mails.new(ARGV[0])
else
	puts "Put email address, please"
	puts "get help there"
	exit
end

email.create_mail
	

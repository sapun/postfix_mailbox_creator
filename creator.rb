#!/usr/bin/env ruby
require "rubygems"
require "net/smtp"
#require "mysql2"
require 'yaml'
RE_EMAIL = /^[A-Za-z][._A-Za-z\d-]+@[A-Za-z\d][._A-Za-z\d-]+\.[A-Za-z]{2,}$/

class Creter_mails

	def initialize(email)
		if email =~ RE_EMAIL
			@email = email
			puts @email
		else
			puts "email not valid"
			exit
		end
		@local_part = @email.split("@").first
		@domain = @email.split("@").last
		@password_now = `pwgen -1 10`
	end
	
		
	def mail_exist?
		if @connect_mysql.query("SELECT * FROM mailbox WHERE username='#{email}'").nil?
			return false
		end
		return true
	end

	def domain_exist?
		if condition
			return true
		end
	end

	def create_mail
		@connect_mysql.query("INSERT INTO `postfix`.`mailbox` (`username`, `password`, `name`, `maildir`, `quota`,
							 `local_part`, `domain`, `created`, `modified`,
							 `active`) VALUES ('@email', '@password_now',
							 '@local_part', '@domain/@@email/', '0',
							  '@local_part', '@domain', Time.now, 'Time.now', '1'")
		
	end

	def connect_mysql
		config = File.open("mysql_config.yaml")
		yp = YAML::load_documents( config ) { |param|
	  	puts "#{param['hostname']} #{param['database']} #{param['username']} #{param['password']}"
	  	@mysql_connection = Mysql2::Client.new(:host => "#{param['hostname']}",
	  										   :username => "#{param['username']}",
	  										   :password => "#{param['password']}", 
	  										   :database => "#{param['database']}")
		}
		p yp	
	end	

	def initial_message(email)
		smtp = Net::SMTP.start('your.smtp.server', 25,'mail.from.domain',
                'Your Account', 'Your Password', :login)
        smtp.send_message any, 'from@mail', email
        smtp.finish
	end
end


if ARGV[0]
	email = Creter_mails.new(ARGV[0])
else
	puts "Exit now"
	exit
end

	

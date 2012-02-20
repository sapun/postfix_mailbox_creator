#!/usr/bin/env ruby
require "rubygems"
require "net/smtp"
require "mysql2"
require 'yaml'
RE_EMAIL = /^[A-Za-z][._A-Za-z\d-]+@[A-Za-z\d][._A-Za-z\d-]+\.[A-Za-z]{2,}$/

class MailsCreator

	def initialize(email)
		puts "email is not valid" and exit unless email =~ RE_EMAIL

		@email = email
		@local_part, @domain = @email.split("@")
		@password_now = random_password

		@body_hello_message = <<END_OF_MESSAGE
From: Email Administrator <sapun@gorod-skidok.com>
To: #{@local_part} <#{@email}>
Subject: Hellow Message
Date: #{Time.now.to_s}

Welcome to gorod-skidok email system.
END_OF_MESSAGE

		@maildir = File.join(@domain, @email, '')
	end

	def create_mail
		connect_mysql

		puts "this mail alredy exists" and exit if mail_exist?
		puts "this domain unregistred" and exit unless domain_exist?

		mailbox_params = {
		  :username   => @email,
		  :password   => @password_now,
		  :name       => @local_part,
			:maildir    => @maildir,
			:quota      => 0,
  		:local_part => @local_part,
			:domain     => @domain,
			:created    => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
			:modified   => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
		 	:active     => 1
		}
		mailbox_fields = mailbox_params.keys.join(',')
		mailbox_values = mailbox_params.values.map{|v| @mysql_connection.escape(v) }.join(',')
		query("
		  INSERT INTO
		    mailbox (#{mailbox_fields})
		 	VALUES
  	 	  (#{mailbox_values})")

		query("INSERT INTO alias (address, goto,domain, created, modified, active)
								VALUES ( '#{@email}', '#{@email}','#{@domain}',
										'#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}',
										'#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}', '1')
								")
		puts @password_now
		initial_message
		disconnect_mysql
	end

	protected
	def mail_exist?
		!query("SELECT count(*) AS counter FROM mailbox WHERE username='#{@email}'").first.fetch(:counter).zero?
	end

	def domain_exist?
		!query("SELECT count(*) AS counter FROM domain WHERE domain= '#{@domain}'").first.fetch(:counter).zero?
	end

	def connect_mysql
		config = File.open("mysql_config.yaml")
		param = YAML::load( config )
    @mysql_connection =
  	  Mysql2::Client.new(
        :host     => param['hostname'],
		    :username => param['username'],
		    :password => param['password'].to_s,
		    :database => param['database']
		  )
	end

	def disconnect_mysql
		@mysql_connection.close
	end

	def query(query_str)
	  @mysql_connection.query(query_str)
  end

	def initial_message
		config = File.open("smtp_config.yaml")
		param = YAML::load( config )
	  smtp =
	    Net::SMTP.start(
  		  param['smtp_server'],
  		  param['port'],
  		  param['smtp_server'],
	      param['username'],
	      param['password'],
	      :login
	    )
  	smtp.send_message @body_hello_message, "#{param['username']}", @email
  	smtp.finish
	end

	def random_password(size = 10)
		chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
		(1..size).collect{|a| chars[rand(chars.size)] }.join
	end
end


if ARGV[0]
	email = MailsCreator.new(ARGV[0])
else
	puts "Put email address, please"
	puts "get help there"
	exit
end

email.create_mail


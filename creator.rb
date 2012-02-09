#!/usr/bin/env ruby
require "rubygems"
require "net/smtp"
require "mysql2"
require 'yaml'

def mail_exist?
	
end

def domain_exist?
	
end

def create_mail
	
end

def initial_message
	
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

def disconnection_mysql
	@mysql_connection.disconnect!
end
puts "anymail"

connect_mysql
disconnection_mysql
#
# Cookbook Name:: tctest
# Recipe:: database
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'ruby-dev'
package 'libmysqlclient-dev'
package 'make'

mysql2_chef_gem 'default' do
  action :install
end

mysql_client 'default' do
  action :create
end

mysql_service 'default' do
  initial_root_password data_bag_item('passwords', 'mysql_admin_password')['password']
  action [:create, :start]
end

mysql_database node['tctest']['app']['database'] do
  connection(
    :host => node['tctest']['database']['host'],
    :username => node['tctest']['database']['admin'],
    :password => data_bag_item('passwords', 'mysql_admin_password')['password']
  )
  action :create
end

mysql_database_user node['tctest']['app']['dbuser'] do
  connection(
    :host => node['tctest']['database']['host'],
    :username => node['tctest']['database']['admin'],
    :password => data_bag_item('passwords', 'mysql_admin_password')['password']
  )
  password data_bag_item('passwords', 'mysql_user_password')['password']
  database_name node['tctest']['app']['database']
  host node['tctest']['app']['userhosts']
  action [:create, :grant]
end

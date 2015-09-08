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

mysql_database node['tctest']['database']['name'] do
  connection(
    :host => '127.0.0.1',
    :username => node['tctest']['database']['admin'],
    :password => data_bag_item('passwords', 'mysql_admin_password')['password']
  )
  action :create
end

mysql_database_user node['tctest']['database']['user'] do
  connection(
    :host => '127.0.0.1',
    :username => node['tctest']['database']['admin'],
    :password => data_bag_item('passwords', 'mysql_admin_password')['password']
  )
  password data_bag_item('passwords', 'mysql_user_password')['password']
  database_name node['tctest']['database']['name']
  host node['tctest']['database']['origin']['app']
  action [:create, :grant]
end

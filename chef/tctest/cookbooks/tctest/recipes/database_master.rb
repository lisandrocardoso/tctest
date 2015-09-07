#
# Cookbook Name:: tctest
# Recipe:: database_master
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'tctest::database'

chef_gem 'mysql' do
  compile_time false
end

chef_gem 'mysql2' do
  compile_time false
end

#mysql_database_user 'replication' do
#  connection(
#    :host => node['tctest']['database']['host'],
#    :username => node['tctest']['database']['admin'],
#    :password => data_bag_item('passwords', 'mysql_admin_password')['password']
#  )
#  password data_bag_item('passwords', 'mysql_replication_password')['password']
#  database_name '*'
#  host node['tctest']['app']['userhosts']
#  privileges ['replication slave']
#  action [:create, :grant]
#end

mysql_config 'master replication' do
  config_name 'replication'
  instance 'default'
  source 'replication_master.erb'
  variables(server_id: node['tctest']['database']['master_id'], mysql_instance: 'default')
  notifies :restart, 'mysql_service[default]', :immediately
  action :create
end

## mysql::master
ruby_block "store_mysql_master_status" do
  block do
    require 'rubygems'
    Gem.clear_paths
    require 'mysql'
    node.set[:tctest][:database][:master] = true
    m = Mysql.new("127.0.0.1", node[:tctest][:database][:admin], data_bag_item('passwords', 'mysql_admin_password')['password'])
    m.query("show master status") do |row|
      row.each_hash do |h|
        node.set[:tctest][:database][:master_file] = h['File']
        node.set[:tctest][:database][:master_position] = h['Position']
      end
    end
    m.query("grant replication slave on *.* to replication@'#{node[:tctest][:app][:userhosts]}' identified by '#{data_bag_item('passwords', 'mysql_replication_password')['password']}'")
    Chef::Log.info "Storing database master replication status: #{node[:tctest][:database][:master_file]} #{node[:tctest][:database][:master_position]}"
    node.save
  end
  # only execute if mysql is running
  only_if "pgrep 'mysqld$'"
  # subscribe to mysql service to catch restarts
  subscribes :create, 'mysql_service[default]'
end


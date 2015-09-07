#
# Cookbook Name:: tctest
# Recipe:: master_slave
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

## mysql::master
ruby_block "store_mysql_master_status" do
  block do
    node.set[:tctest][:database][:master] = true
    m = Mysql.new("localhost", node[:tctest][:database][:admin], data_bag_item('passwords', 'mysql_admin_password')['password'])
    m.query("show master status") do |row|
      row.each_hash do |h|
        node.set[:tctest][:database][:master_file] = h['File']
        node.set[:tctest][:database][:master_position] = h['Position']
      end
    end
    Chef::Log.info "Storing database master replication status: #{node[:tctest][:database][:master_file]} #{node[:tctest][:database][:master_position]}"
    node.save
  end
  # only execute if mysql is running
  only_if "pgrep 'mysqld$'"
  # subscribe to mysql service to catch restarts
  subscribes :create, resources(:service => "mysql")
end


#
# Cookbook Name:: tctest
# Recipe:: database_slave
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

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

mysql_config 'slave replication' do
  config_name 'replication'
  instance 'default'
  source 'replication_slave.erb'
  variables(server_id: node['tctest']['database']['slave_id'], mysql_instance: 'default')
  notifies :restart, 'mysql_service[default]', :immediately
  action :create
end


## mysql::slave
ruby_block "start_replication" do
  block do
    require 'rubygems'
    Gem.clear_paths
    require 'mysql'

    dbmasters = search(:node, "tctest_database_master:true")

    if dbmasters.size != 1
      Chef::Log.error("#{dbmasters.size} database masters, cannot set up replication!")
    else
      dbmaster = dbmasters.first
      Chef::Log.info("Using #{dbmaster.name} as master")

      m = Mysql.new("127.0.0.1", node[:tctest][:database][:admin], data_bag_item('passwords', 'mysql_admin_password')['password'])
      command = %Q{
      CHANGE MASTER TO
        MASTER_HOST="#{dbmaster.ipaddress}",
        MASTER_USER="replication",
        MASTER_PASSWORD="#{data_bag_item('passwords', 'mysql_replication_password')['password']}",
        MASTER_LOG_FILE="#{dbmaster.tctest.database.master_file}",
        MASTER_LOG_POS=#{dbmaster.tctest.database.master_position};
      }
      Chef::Log.info "Sending start replication command to mysql: "
      Chef::Log.info "#{command}"

      m.query("stop slave")
      m.query(command)
      m.query("start slave")
    end
  end
  not_if do
    require 'rubygems'
    Gem.clear_paths
    require 'mysql'

    #TODO this fails if mysql is not running - check first
    m = Mysql.new("127.0.0.1", node[:tctest][:database][:admin], data_bag_item('passwords', 'mysql_admin_password')['password'])
    slave_sql_running = ""
    m.query("show slave status") {|r| r.each_hash {|h| slave_sql_running = h['Slave_SQL_Running'] } }
    slave_sql_running == "Yes"
  end
end

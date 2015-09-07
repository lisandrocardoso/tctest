#
# Cookbook Name:: tctest
# Recipe:: user
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

group node['tctest']['group']

user node['tctest']['user'] do
  group node['tctest']['group']
  home "/home/#{node['tctest']['user']}"
  manage_home true
  system true
  shell '/bin/bash'
end

directory "/home/#{node['tctest']['user']}/.ssh" do
  owner node['tctest']['user']
  group node['tctest']['group']
end

cookbook_file "/home/#{node['tctest']['user']}/.ssh/id_dsa" do
  source 'deploy_key.priv'
  owner node['tctest']['user']
  group node['tctest']['group']
  mode '0600'
end

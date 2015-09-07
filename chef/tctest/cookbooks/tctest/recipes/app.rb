#
# Cookbook Name:: tctest
# Recipe:: app
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

app_database = {
  :database => node['tctest']['app']['database'],
  :adapter => node['tctest']['app']['adapter'],
  :username => node['tctest']['app']['dbuser'],
  :password => data_bag_item('passwords', 'mysql_user_password')['password']
}

directory node['tctest']['app']['deploy_path'] do
  recursive true
  owner node['tctest']['user']
  group node['tctest']['group']
end

ssh_known_hosts_entry 'github.com'

package 'git'
package 'libmysqlclient-dev'

git node['tctest']['app']['deploy_path'] do
  repository node['tctest']['app']['repourl']
  revision 'master'
  user node['tctest']['user']
  group node['tctest']['group']
  action :checkout
end

python_runtime '2'

python_virtualenv 'tctest' do
  path "#{node['tctest']['app']['deploy_path']}/ve"
  user node['tctest']['user']
  group node['tctest']['group']
  pip_version true
  system_site_packages true
end

python_package 'tctest app packages' do
  package_name ['django', 'mysqlclient', 'gunicorn']
  virtualenv 'tctest'
end

dbmasters = search(:node, "tctest_database_master:true")
dbmaster = dbmasters.first

template "#{node['tctest']['app']['deploy_path']}/local_settings.py" do
  source 'local_settings.py.erb'
  mode '0644'
  owner node['tctest']['user']
  group node['tctest']['group']
  variables({
    :dbpassword => data_bag_item('passwords', 'mysql_user_password')['password'],
    :dbhost => dbmaster.ipaddress
  })
end

execute 'tctest_collectstatic' do
  command "#{node['tctest']['app']['deploy_path']}/ve/bin/python manage.py collectstatic --settings local_settings --noinput"
  action :run
  cwd node['tctest']['app']['deploy_path']
  user node['tctest']['user']
end

execute 'tctest_migrate' do
  command "#{node['tctest']['app']['deploy_path']}/ve/bin/python manage.py migrate --settings local_settings --fake-initial"
  action :run
  cwd node['tctest']['app']['deploy_path']
  user node['tctest']['user']
end

template '/etc/init/tctest.conf' do
  source 'tctest.conf.erb'
  owner 'root'
  group 'root'
end

service 'tctest' do
  action [:enable, :start]
end

nginx_proxy 'tctest.com' do
  url 'http://127.0.0.1:8000/'
  custom_config ['location /static/ {',"  root #{node['tctest']['app']['deploy_path']}/;", '}']
end

directory '/var/www/nginx-default/' do
  recursive true
end

file '/var/www/nginx-default/index.html' do
  content 'OK'
end

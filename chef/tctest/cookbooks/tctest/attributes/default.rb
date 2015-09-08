default['tctest']['user'] = 'tctest'
default['tctest']['group'] = 'tctest'

default['tctest']['database']['host'] = '127.0.0.1'
default['tctest']['database']['admin'] = 'root'
default['tctest']['database']['origin']['app'] = '10.2.1.%'
default['tctest']['database']['origin']['replication'] = '10.2.2.%'
default['tctest']['database']['master_id'] = 1
default['tctest']['database']['name'] = 'tctest'
default['tctest']['database']['user'] = 'tctest'

default['tctest']['app']['repourl'] = 'git@github.com:/lisandrocardoso/tctest_app.git'
default['tctest']['app']['deploy_path'] = '/opt/tctest'
default['tctest']['app']['deploy_key_path'] = '/tmp/deploy_key.priv'

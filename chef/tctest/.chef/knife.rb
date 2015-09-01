# See https://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "lisandroec"
client_key               "#{current_dir}/lisandroec.pem"
validation_client_name   "lisandroec-validator"
validation_key           "#{current_dir}/lisandroec-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/lisandroec"
cookbook_path            ["#{current_dir}/../cookbooks"]

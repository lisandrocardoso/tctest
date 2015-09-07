# Terraform / Chef test

###### What's in the repo

* terraform/ contains all Terraform code
* chef/ contains the chef repo
* keys/ any keys needed, such as the SSH key pair

##### Notes / Warnings

* AWS access and secret keys with full EC2 access are needed. Their location is passed in terraform/aws/variables.tf
* The proper way to bootstrap AWS boxes would be to set up a VPN to the established VPC and use private IPs. Here we're assigning public IP addresses to the boxes and enableing SSH access in the security groups in the sake of simplicity.
* The bootstrapping requires a keypair for SSH access. It's path is needed in terraform/aws/tctest.tf, 'conn_key_file', in this test setup it sits in /keys.
* The hosted chef setup uses a validation key, that should be configured using knife and the hosted chef management console.
* There must be a private key file called "deploy_key.priv" in the Chef files directory that should be used as a deploy key for the tctest_app repo.
* MySQL admin/user/replication passwords are not encrypted because installing the secret key manually into the destination boxes is not possible and beats the automation purpose. Alternatives such as chef-vault are known to exist but where not taken into consideration because of the additional time it would take to be implemented, and again, simplicity.


##### How it works

After making sure the needed keys are in place, run 'terraform plan && terraform apply' in terraform/aws/ and the initial provisioning should begin; this is in order what happens;

* Terraform sets up the AWS credentials.
* Module 'vpc' runs; which does the following
  * Creates 'tctest_vpc'
  * Creates an internet gateway for the VPC
  * Creates subnets for web and database nodes, associated to the VPC
  * Creates route tables for the subnets, associated with the internet gateway
  * Creates security groups for web and database nodes. Web allows HTTP and SSH from everywhere, database allows SSH from everywhere, MySQL (3306) from web and database security groups (application and replication)
* Module 'mysql_master' runs
  * Creates an instance in the database subnet, with the database security group, and provisions it with Chef recipes apt::default and tctest::database_master.
  * Chef recipes roughly do;
    * Use tctest::database to install the needed packages, create a mysql service, setup the empty database and grant the app user privileges over it.
    * tctest::database_master adds replication master specific configuration, install needed gems and then uses a ruby_block snippet to set an attribute which will identify this node as master, grant the replication user privilegs, and extract the master_file and master_position values, which will store also as attributes.
* Module 'mysql_slave' runs
  * Creates an instance in the database subnet, with the database security group, and provisions it with Chef recipes apt::default and tctest::databa
    se_slave. It is worth noting here that sort of an explicit dependency (in the form of master_dependency variable) is used here, because terraform's 'depends_on' attribute is not valid for modules. It forces to wait for the mysql_master output and uses it as dummy input in the mysql_slave instance. It also takes a 'servers' input that it will use to start up to n slaves.
  * Chef recipes roughly do;
    * Use tctest::database to install the needed packages, create a mysql service, setup the empty database and grant the app user privileges over it.
    * tctest::database_slave adds replication slave specific configuration, install needed gems and then uses a ruby_block snippet to search for the node with the attribute tctest_database_master = true. It then uses the data from the node's attributes, such as ipaddress, and stored master_file and master_position, to run a 'CHANGE MASTER TO' query and set up proper replication.
* Module 'web_node' runs
  * Creates an instance in the web subnet, with the web security group, and provisions it with Chef recipes apt::default and tctest::app. Same mechanism for implicit dependency is used here; we need the mysql slave servers up here since the web node provisioning by Chef runs a migrate of the app, which will populate tables. It also takes a 'servers' input that it will use to start up to n up nodes.
  * Chef recipes roughly do;
    * Create the neded directories for the app
    * Install the needed packages
    * Check out the app repo from ['tctest']['app']['repourl']
    


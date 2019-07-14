
![openstack Installs](./gh_img/openstack_installs.png)


## Openstack Installs from Host system to Setup to install cloud images. 

* Rocky - CENTOS7/OpenSUSE15:
  * CentOS7 Openstack Rocky installs Packstack
  * Opensuse15 DevStack
  * CentOS7 Demo network.

* Stein - CENTOS7:
  * Openstack Stein installs Packstack.
  * Manual DEMO Network 
  * Automated DEMO Network with BASH scripts.

* Cloud-init - Loads for many of the primary Linux OS's:
  * Debian 8/9
  * Ubuntu 18
  * CentOS 7
  * Fedora 30
* Cloud-init - Automated script to generate specific types of servers:
  * JUMP
  * WEB
  * SQL
  * PUPPETMASTER

* ELKSTACK 7.x - Elasticsearch & Logstash & Kibana:
  * Setup on CENTOS7.6 and for Openstack. 
  * Script to setup sFlow device for OpenVswitch.
* Logstash configuration examples:
    * Openstack 
    * Apache2
    * System Resources using SAR.   

* MISC - Various programs that can help facilitate Openstack


## TODO:

 - [ ] Setup Openstack Router "if" SDN router data can be monitored. Waiting to install VMs on Openstack to test it out. 
 - [X] Basic Puppet Server cloud-init image for CentOS7 
 - [ ] Basic Puppet Client setup for cloud-init Centos7 & Fedora
 - [ ] Puppet working with gihub repo. 
 - [ ] Puppet SQL and WEB setups for CentOS7 and Fedora
 - [ ] Python Openstack SDK script examples.

## FAR OFF TODO:
  * Magnum:  Docker Openstack images.
  * Magnum:  Kubernetes Openstack images.
  * Heat:    Network Templates.
  * Trove:   Openstack DBaaS.
  * Cinder:  Openstack SAN.
  * Octavia: Load Balancer. 

   
   


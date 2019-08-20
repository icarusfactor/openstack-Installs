
[ ![openstack Installs](./gh_img/openstack_installs.png) ](https://icarusfactor.github.io/openstack-Installs) 


## Openstack Installs from Host system to Setup to install cloud images. 

* Rocky - CentOS7/OpenSUSE15:
  * CentOS7 Openstack Rocky installs Packstack
  * Opensuse15 DevStack
  * CentOS7 Demo network.

______

* Stein - CentOS7:
  * Openstack Stein [Packstack Install](https://icarusfactor.github.io/openstack-Installs/stein/centos7_packstack)  
  * DEMO Manual install [External & Internal Private Network](https://icarusfactor.github.io/openstack-Installs/stein/centos7_packstack_manual_demo)  
  * Automated DEMO Network with [BASH scripts](https://github.com/icarusfactor/openstack-Installs/tree/master/stein/automation_scripts).

______

* [Cloud-init](https://github.com/icarusfactor/openstack-Installs/tree/master/cloud-init) - Loads for many of the primary Linux OS's:
  * Debian 9/10
  * Ubuntu 18/19
  * CentOS 7
  * Fedora 30
  * CloudLinux 7
  * AWS-EC 2

* Automated script to generate specific types of servers:
  * JUMP
  * WEB
  * SQL
  * PUPPETMASTER
  * PUPPETAGENT

______

* ELKSTACK 7.x - Elasticsearch & Logstash & Kibana:
  * [Setup ELKStack on CentOS7.6](https://icarusfactor.github.io/openstack-Installs/elkstack/centos7/) for Openstack.
  * Script to setup sFlow device for OpenVswitch.
* Logstash configuration examples:
    * Openstack 
    * Apache2
    * System Resources using SAR.   

______

* MISC - Various programs that can help facilitate Openstack


## TODO:

 - [ ] Software Defined Router data for Logstash to view. 
 - [ ] Basic Puppet Server cloud-init image for Fedora 
 - [ ] Basic Puppet Client setup for cloud-init Fedora 
 - [ ] Puppet SQL and WEB setups for Fedora 
 - [ ] Python Openstack SDK script examples.

______

## FAR OFF TODO:
  * Magnum:   Docker Openstack images.
  * Magnum:   Kubernetes Openstack images.
  * ELKSTACK: Cloud-init image.
  * Trove:    Openstack Database as a service at least for MariaDB and PostgreSQL images.
  * Heat:     Network Templates.
  * Cinder:   Openstack SAN mounting.
  * Octavia:  Load Balancer. 

   
   


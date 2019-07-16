## Openstack Stein on Centos 7.6 with AllInOne Packstack.

**Prologue:** A new feature in Stein,is the use of the OVN networking and Geneve routing
          protocol by default,so you can easily work with a single network adapater 
          in a flat configuration and not disrupt your Internet access, but will add
          a couple more IP's to your local Class C IPv4 network. So you will have to make
          sure they're not used by your local DHCP or are still being unused.
>     Reference: https://docs.openstack.org/releasenotes/networking-ovn/stein.html 

______


1. With this tutorial we will be using [Oracle Virtualbox](https://www.virtualbox.org) to install a [CentOS7.6 1810 minimal server](https://cloud.centos.org/centos/7/images) QCOW2 image to be the core virtual server that the nested Openstack VM's will use.
  * Set CPU's to >=4.
  * Set Memory Size: >=8G.
  * Set Storage Size: >=30 gig should work fine.

 Setup one virtual network adapater that'll be needed while using Openstack **flat** network.
(With a Flat Network setup all tentants use the same virtual switch/router to
get out to the Internet.)       

 For Debian or RedHat based hosts,I setup the network adapter as **Bridged**. ( enp0s3 <-- will attach
to the br-ex device here via OpenVswitch once we have it setup.)

 **NOTE:** Sometime Oracle Virtualbox mouse interaction does not work , you have to set the mouse to
 multitouch. VirtualBox bug maybe on Debian,CentOS,OpenSuse,but as bare metal host has no issue with this.

______

     
2.  Setup new VM of CentOS 7.6 minimal server and enable one networking device that should be called ***enp0s3*** and hostname ***packstack*** .This will be edited later to connect to the OpenVswitch BR-EX device.
    
______
 
3.  Now setup the size of the disk, I use all of it for the root or ***/*** parition. As virtual vm images
    will be inside this. Other disk can be mounted later for Cinder and a /boot is needed. I do
    this by selecting to clear current partition setup and delete the /home and / paritition and add
    the / paritition back with the capacity empty. This will select the entire free space. 

______

4. Set root and user password and create with admin or sudo capabilites. 

______

5. Wait for CentOS to install. CentOS minimal version 1810 was used,then reboot.
______

6. Logging into the Oracle Virtualbox terminal. Check to see what IP I have for enp0s3 
    `$ ip a`
______
    
7. We will login to the system with this ip using ssh. 
    `$ ssh <IP Reported>
     $ sudo su`
______
    
8. We'll edit network setting to change it to a static ip to make things easier for switching over to OpenVswitch
    cd /etc/sysconfig/network-scripts/
    vi ifcfg-enp0s3
    
    #Remove all the lines in the file and add these to become a static IP we can use throughout the rest of this installtion.     
    
NAME="enp0s3"   
DEVICE="enp0s3"
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
UUID="538adbb0-fbee-4b38-bcf5-9c5b4efad462"
ONBOOT="yes"
IPADDR=192.168.1.29 # Old eth1 IP since we want the network restart to not
                    # kill the connection, otherwise pick something outside
                    # your dhcp range
NETMASK=255.255.255.0  # your netmask
GATEWAY=192.168.1.1  # your gateway
DNS1=8.8.8.8     # use google as nameserver
    
    
9. #From here you can reboot the system to use the static IP and then log into the remote system from host with ssh as
     #user we made admin.This makes cut and paste easier with local terminal.  
     reboot

10. #Copy your local machines ssh key to virtual box host to make access easy from local host system: 

    Make sure to add remote system to known hosts.
    ssh-keygen -f "/home/factor/.ssh/known_hosts" -R 192.168.1.29

    ssh-copy-id -i ~/.ssh/id_rsa.pub datasci@192.168.1.29
    You should now be able to log in without password. 
    
11. Edit SSH config to let root in as this will make instaling packstack easier while installilng.     
    sudo vi /etc/ssh/sshd_config
    remove the # to have "PermitRootLogin yes" enabled. 
    sudo service sshd restart 
    log back out. 
    
12. See if you can now log into root via remote "ssh root@192.168.1.29"
     Copy public key to root 
     ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.1.29

     
13. (OPTIONAL) #Log back in root and install useful commandline packages to help debug systems.
     sudo yum -y install mc nmap elinks wget screen curl wireshark
     
     
14. Log back in and edit hosts file.
     vi /etc/hosts
     #Add two lines. Packstack is you Virtualbox host IP.
     192.168.1.29  packstack
     10.0.2.1      controller   
     
15. Goto the network device directory for CENTOS
     cd /etc/sysconfig/network-scripts/      
     vi ifcfg-enp0s3
     Remove any lines in this file and replace them with these below. 
     
     DEVICE=enp0s3
     TYPE=OVSPort
     DEVICETYPE=ovs
     OVS_BRIDGE=br-ex
     ONBOOT=yes
     
     Edit Bridge Device file. 
     vi ifcfg-br-ex
     Add below lines to file. 
     
     NAME=br-ex
     DEVICE=br-ex
     ONBOOT=yes
     DEVICETYPE=ovs
     TYPE=OVSBridge
     OVS_BRIDGE=br-ex
     BOOTPROTO=static
     NM_CONTROLLED=no
     IPADDR=192.168.1.29 # Old eth1 IP since we want the network restart to not
                         # kill the connection, otherwise pick something outside
                         # your dhcp range
     NETMASK=255.255.255.0  # your netmask
     GATEWAY=192.168.1.1  # your gateway
     DNS1=8.8.8.8     # use google as nameserver

      
16. Update system and remove and add needed packages for networking and packstack.     
     
     NOTE: This will conflict with packstack version.
     wont be installed, but make sure its not installed.
     pip uninstall urllib3
     
     #Normally CENTOS has this but I run RHEL to get latest version of packages from each.
     #This may change in the future , but works best for now.
     $ sudo yum install -y https://www.rdoproject.org/repos/rdo-release.rpm     
     #Check to make sure the repo made it into the list and enabled.
     $ yum repolist   <--- Look for Openstack stein     
     # Stein here or what version you want replace the text name. 
     $ sudo yum install -y centos-release-openstack-stein     
     #This conflicts with packstack version so remove.
     $ yum erase mariadb-libs     
     $ sudo yum update -y
     $ sudo yum install -y openstack-packstack
     
     #We need to install the openvswitch before installing packstack (packstack will install it also)
     #So we can reboot and get the OpenVswitch bridge working before the install.     
     $ sudo yum install openvswitch
     $ sudo systemctl disable firewalld
     $ sudo systemctl stop firewalld
     #Disable NetworkManager as it conflicts with iptables.
     $ sudo systemctl disable NetworkManager
     $ sudo systemctl stop NetworkManager
     $ sudo systemctl enable network
     $ sudo systemctl start network

     
17. #Disable SELinux     
     $ vi /etc/selinux/config
     $ Change SELINUX=enforcing to SELINUX=disabled
          

18. At this point we can reboot to get access to the OpenVswitch device BR-EX 
     $ reboot
     #Once the system is back up check to see BR-EX is enable and has IP address 10.0.2.1.
     $ ip a
     #Good to make sure you can still get to the Internet at this point. 
     
19. (Optional) Create stack user. I like to keep all of my login scripts and custom vm files and binaries in here.       
     $ sudo useradd -s /bin/bash -d /opt/stack -m stack
     $ echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
     S sudo su - stack
    
20. Log in as root and clear DEFAULT values with Puppet installer. As this many remove RabbitMQ timeout issues.
     $ cd /usr/share/openstack-puppet
     $ grep -Ri "timeout = 300"| grep db_sync_timeout
     #Select and edit each file from grep output. Change 300 to 0.

 
21. #Now we will install packstack All In One Openstack system.   
     #This will be for a dry run and generate the answerfile we will use for actual install.

     #  Generating this dry run will also let us go over all the options and change them if needed before
     #we install Openstack. You can talor your stack according to your memory,cpu cores,storage,gpu cores
     #and passthrough and networking setup.Passwords are also set with this file. Note This is "packstack"
     #so everything is on one node. I've not tested if this setup is good for setting up only compute nodes
     #on one system and controller on another.I imagine it could do so,but how much configuration is needed,
     #I can not answer that.
     
     #Some of the options in the packstack answer file. 
     #Minimal stack would be Keystone, Glance, Nova and Neutron.
     -------------------------------------------------
     #Dashboard or Horion: Web Based Admin. Default set to "Y"
     #TROVE      : Database as a service for Cassandra,CouchBase,CouchDB,DataStax,DB2,MariaDB,MongoDB,MySQL,Oracle,Percona,PostgreSQL,Redis and Vertica. 
     #MAGNUM     : Container orchestration for Docker and Kubernetes and Apache Mesos
     #HEAT       : General Orchestration.
     #CINDER     : Openstack Block Storage.Backend can be lvm,gluster,nfs,netapp,vmdk,solidfire. Default set to "Y" and lvm
     #MANILA     : Shared Filesystem.
     #SWIFT      : Object Store for unstructured data. Default set to "Y"
     #CEILOMETER( gnocchi ) : Metering, billing, resource tracking,event data . Default set to "Y"
     #AODH       : Trigger and alerting. Default set to "Y"
     #IRONIC     : Bare metal provisioning.
     #PANKO      : Event Service
     #SAHARA     : Big Data prcoessing for HADOOP,SPARK or STORM
     #TEMPEST    : Integration Test Suite
     #DEMO       : Example project
     #MARIADB    : Primary Database. Default set to "Y"
     #GLANCE     : Image Service. Images can be saved as file or in Swift. Default set to "Y" and saved as file. 
     #NEUTRON    : Networking. Default to "Y" and type will be flat. This will work with normal home networks.  
     #NOVA       : Compute service.  
     #RABBITMQ   : AMQP broker or message service. Default service.
     #KEYSTONE   : Identity service version 2 or 3. Backend can be sql or ldap. 3 and sql are the default settings.   

     
     sudo su
     su - stack
     packstack --allinone --provision-demo=n --os-heat-install=y --timeout=0 --debug --dry-run

     #No files are changed but an answerfile is created in the stack directory.
     #I have diabled the demo project if you are not familiar with this setup you can enable it.
     #But I will have additional instructions for setting uup different types of network installs.
          
22. #Now we are ready to install Packstack with answerfile that you can modify to add or
     #remove certian capbilities. This can take up some time and you can view var log 
     #messages with updates. 
     packstack --debug --timeout=0 --answer-file=packstack-answers-<TIMESTAMP>.txt 
     
     #Open another terminal on your host and log in to view and monitor log of status.
     ssh root@192.168.1.29 -t "cd /var/log; tail -f ./messages| grep -iEv '(logind | Session | Reloading )' ; /bin/bash"
     
     #Open another terminal pointing to location and your specific log file name. 
     ssh  root@192.168.1.29 -t "tail -f /var/tmp/packstack/<TIMESTAMP>-_eR_sW/openstack-setup.log"
     
     #I also open a terminal to leave "top" running to see acitivity has not stalled. 
     
23. #Wait for message from the installtion. **** Installation completed successfully ******

     #NOTE: If you get ERROR with RabbitIM, just rerun packstack AllInOne command again. 
      #If this still does not work you can stop and restart the server.
      $ sudo service rabbitmq-server stop
      $ sudo service rabbitmq-server start
      #To get information if the server is functioning and other system data.
      $ sudo service rabbitmq-server status
      #If the server is hung and wont stop you can force it down.
      $ pkill -KILL -u rabbitmq
      $ service rabbitmq-server start
      #then run the packstack command again.

     #Check login creditals. 
     $ cat /root/keystonerc_admin 
     #You will use these to login to the Openstack GUI Horizon.


24. (OPTIONAL)#Extra addon to get login data on your screen from prompt.
     $ wget -O screenfetch-dev https://git.io/vaHfR
     $ sudo cp ./screenfetch-dev  /usr/bin/screenfetch
     $ sudo chmod +x /usr/bin/screenfetch
     #Test screen fetch out. 
     $ screenfetch
     #Now add it to /etc/bashrc and also ~./.bashrc if you wish,so it runs when login.
     $ vi /etc/bashrc
     $ if [ -f /usr/bin/screenfetch ]; then screenfetch; fi
     #Logout and then back in to test it. 
     
25. #Now to access the webserver for Dashboard to configure Openstack. 
     #Log into the main system from host. i.e. 192.168.1.29
     ssh 192.168.1.29      
     #From here we can use nmap to check what ports are being used. 80(HTTP) and 5900(VNC)
     nmap localhost
     #Use elinks to check if Openstack page to the host device is working. 
     elinks 192.168.1.29     
     #Elinks should show openstack dashboard login as text version.
     #If you see this , then your setup is working. 

     
26. #The Openstack Server should be setup and running.
     #The Openstack web Interface Horizon shoud be avialable from a localhost browser now.
     #Login with "admin" and get the password from the /root/keystone_adminrc file.
     DASHBOARD  : 192.168.1.29:80
     #Browser VNC access of the serial interface to the cloud servers
     BROWSER VNC: 192.168.1.29:6080

27. #Using Centos7.6 and Python2.x EOL coming on Jan 1 2020. We need to install python 3.x packages
     #and they are not in the standard repos,so for your system to be ready for the event, we will add
     #the extra Python3 repo.   

     $ sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
     $ sudo yum update
     $ sudo yum install -y python36u python36u-libs python36u-devel python36u-pip
     $ python3.6 -V 
     #Now you're ready for Py2020

28. # With CentOS7.6 using an older 3.10 kernel without the CONFIG_RANDOM_TRUST_CPU option of 4.19+, the
     # newer Linux VM's may run into a Boottime Entropy Starvation condition. For me this casued many
     # cloud-init problems and is linked to systemd and ssh package and its keys. To resolve this issue
     # where urandom needs to make sure it gets its randomness checked in a timley manner you should only
     # have to install a single package.
  
     #A check to find problems around this issue are to 
     dmesg | grep -E "(rng|random)" 

     #Haveged is a user-space daemon that gathers entropy though the timing jitter any CPU has.
     #This programs runs late in the boot process, but should fix the ssh issue if you cant get 
     #kernel 4.19 or newer. 
     yum -y install haveged  
     

29. #(Optional) Install ELKSTACK7.x to monitor,log and audit activity. ELK stands for
     #Elasticsearch - Logstash - Kibana. Each of these systems makes up a system to 
     #gather,setup collections and vizualize realtime data from your network. I needed this for
     #this lab setup to monitor and test resources on vm's,SDN routers and switch.
     https://raw.githubusercontent.com/icarusfactor/openstack-Installs/master/elkstack/ELK_INSTALL_CENTOS7.6.txt
   
 
30. #You will now have a clean Openstack Stein install and able to explore and add projects. Look on the Internet for 
     #installing Openstack user and projects. With the AllInOne install. We did not enable demo tentant, this can
     #be enabled if you want an example to view.
          
     #With the new OVN networking and full use of only openstack only commands the older version ScalableWebService will not
     #work in a reliable manner. I have made a new demo proejct that will work with Stein.
          
     https://raw.githubusercontent.com/icarusfactor/openstack-Installs/master/stein/ScalableWebService-Stein
     
     
     

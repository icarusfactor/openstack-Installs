## OpenStack Scalable Web Serice. 

**Prologue** This is a manual install tutorial with a base set of images with security for use with growing a user based webserver farm with the below specifications. Normally you want to automate this proceedure, which I do have scrips for doing this(Bash shell and Python), But you need this knowledge if you have to monitor,troubleshoot or fix issues on the fly.

One Jump Server 

One Mysql server

One Web Server

This will be working with a Packstack Stein install.  

Uses 1 vcpu/Ram 2G/20G for jump server. This will be a minimal setup for ssh access from outside private network.

Uses 1 vcpu/Ram 2G/20G for web service. Will have a setup for:
  * Apache2
  * Mediawiki
  * Wordpress
  * Myphpadmin

Uses 1 vcpu/Ram 2G/20G for mysql service. MariaDB Database Setup.

The setup and templates I will be using are on my github that will be posted in this tutorial ending with .ci for Cloud-Init. (OpenSUSE does not use cloud-init so I cant get this QCOW2 to work.)

## Start Virtualbox On Centos 7.6 with Packstack.

Using the image that had been created with following below link tutorial. 

[Openstack: OVN flat network for Stein](https://github.com/icarusfactor/openstack-Installs/blob/master/stein/PackStack-Stein-AllInOne-CentOS7.6.md)


## Start SSH session:


```

$ ssh root@192.168.1.29


```

## Access Dashboard with Browser

Point to IP and get to login to Horizon dashboard:


```

http://192.168.1.29

```
   
#Load Admin Creditials 

As root, load environment with your keystone adminrc creditials.

```

$ cat /root/keystonerc_admin
$ . /root/keystonerc_admin


```

## Project Requirements

We will need to add:

    * Basic non admin user for the project.
    * Project : Scalable Web Server.
    * Operating System Image loading into the Glance service.
    * Will use "Default" domain so not needed to add another.

   ***NOTE:*** We will perform the following commands with "Horizon Web Page" and "openstack command line tool". This is the first version where I was able to do this. So all of the major networking commands have been ported to the Openstack CLI interface. You can still use neutron commandline tool, but have had unstable outcomes from doing so ,so not recommended in this version.
   
## Create Flat External Network
 
A flat network will work with a normal home setup. Unlike the VLAN tagged infrastructure for high density farms.

```
$ openstack network create --provider-network-type flat --provider-physical-network extnet --share --external OCEANUS

```


## Create External Subnet:

A subnet with same network as your single network device adapter. 


```

$ openstack subnet create --subnet-range 192.168.1.0/24 --gateway 192.168.1.1 \
  --network OCEANUS --allocation-pool start=192.168.1.100,end=192.168.1.200 \
  --dns-nameserver 8.8.4.4 RIVERS


```


## Create Private network 

Attach internal subnet and create internal network. 

```
  
$ openstack network create --share ELYSIUM
$ openstack subnet create --subnet-range 192.0.2.0/24 \
--network ELYSIUM --dns-nameserver 8.8.4.4 FIELDS

```
      

## Create & Setup Router

Create a software defined router and attach it to the internal subnet.

```

$ openstack router create LIMBO
$ openstack router add subnet LIMBO FIELDS

```


## Connect Networks Via Gateway 

Add a software defined router interface to external network and set its gateway.  

```

$ openstack router set --external-gateway OCEANUS LIMBO


```


## Create Project And Its User 

A non-admin user ***planner*** in openstack and the project for user.     

```

$ openstack project create --enable "Scalable Web Service"
$ openstack user create --project "Scalable Web Service" --password easypassword --enable planner    


```
 
    
## User CLI Script

 **[Optional]** Create a non-admin user planner script if you need to run commands as user:

```

$ cp /root/keystonerc_admin /root/keystonerc_planner

```

Edit the script to match these values.

```

export OS_USERNAME=planner
export OS_PASSWORD=easypassword
export OS_PROJECT_NAME="Scalable Web Service"

```
Next source the environment values to start using them.

```

$ . /root/keystonerc_planner


```
  
## Give User Access to Project

To finalize above step login to HORIZON web GUI as ***admin*** and add user ***planner*** to ***Scalable Web Service*** project. 

```
Project->Project->Manage Memembers on the Scalable Web Service

```

## Login As Non-Admin User

Log into Horizon gui as ***planner***.


## Verify network setup:

```
Project -> Network -> Network Topology

```

You should see your external and internal network. Non-admin users do not have access to the external router. 

    
 
## Load Cloud Image.   

```
Select Project -> Compute -> Images

Image Name  : Deb9Server
Browse      : debian-9-openstack-amd64.qcow2   <--- basic minimal debian install. 
Format      : qcow2

Create Image. 

```

Wait for "Deb9Server" to become "Active".

We will use this Glance image as basis of all the node operating systems and apply a specific
cloud init file to each to give in its profile. 

     
## Import Public Key.     

```
Project -> Compute -> Key Pairs

+ Import Public Key

```

On your desktop system cat your public key if on *NIX based system and copy and paste.

```
$ cat ./.ssh/id_rsa.pub

```

## Create Security Groups 

for each of the instance type:

```

PROJECT -> NETWORK -> Security Groups:

```
Create Security Group for ***JUMP*** 

```
     
+Create Security Group
Group Name: JUMP
Description : Access Point SSH=EX + INT
     
Select Add or Manage Rules

Add ICPM Egress and Ingress

Add TCP SSH 

```
    
Create Security Group for ***SQL***

```
 
+Create Security Group
Group Name: SQL
Description : Database Server ICPM+MYSQL+SSH=INT
     
Select Manage Rules
Add ICPM Ingress
Add TCP SSH 
ADD MYSQL

```

Create Security Group for ***WEB***


```
     
+Create Security Group
Group Name: WEB
Description : Web Server HTTP=INT + EX  SSH=INT  
     
Select Manage Rules
Add ICPM Ingress Egress
Add TCP SSH 
Add HTTP custom TCP port 8080   <--- This can be routed back to port 80 for Internet, or left as proxy.

```
     
NOTE: If it takes too long to install instances you can
watch the install of the server.            
Dashboard has a log viewer, click the full
log option and keep it refreshed with a browser plugin.
Also, be sure to update your ISO image if you want less time
for updating packages. 
     
Basic debian cloud image download location.

```
https://cdimage.debian.org/cdimage/openstack/current/

```
     
TEST IMAGE:
Excellent image to test basic network and serial access. 
No SSH key needed.Will post its username and password at login.

```

http://download.cirros-cloud.net/

```

  
     
## Install JUMP instance.      

```
     Project -> Compute -> Instances
     Select Launch
     Launch Instance
     Instance Name JUMP
     Description: ACCESS POINT
     NEXT
     Select minimal Debian image.
     NEXT
     Select m1.small  1 vcpu 2Gig RAM 20gig space.
     NEXT
     Select ELYSIUM Private Network. 
     #NEXT until Security Groups
     Deselect default.
     Select JUMP
     NEXT
     Select MERCURY public key
     NEXT

```
Copy and paste JUMP Server Cloud Init file .


[CLOUD-INIT FOR DEBIAN JUMP](https://github.com/icarusfactor/openstack-Installs/blob/master/cloud-init/JUMPSERVER_DEBIAN_10.ci)

```
     LAUNCH INSTANCE
     Select Associate Floating IP from drop down.
     Click the Plus on IP address to generate a legal IP address. 
     Pool should be from OCEANUS
     Description: ACCESS POINT 
     Allocate IP. Then Associate IP.
     The floating IP address should appear in your Jump Servers' IP address column. 

```

## Install SQL instance:      

```
     Project -> Compute -> Instances
     Select Launch
     Launch Instance
     Instance Name SQL
     Description: DATABASE SERVER
     NEXT
     Select minimal Debian image.
     NEXT
     Select m1.small  1 vcpu 2Gig RAM 20gig space.
     NEXT
     Select ELYSIUM Private Network. 
     #NEXT until Security Groups
     Deselect default.
     Select SQL
     NEXT
     Select MERCURY public key
     NEXT
```
Copy and paste JUMP Server Cloud Init file .


[CLOUD-INIT FOR DEBIAN SQL](https://github.com/icarusfactor/openstack-Installs/blob/master/cloud-init/SQLSERVER_DEBIAN_10.ci )

```
     LAUNCH INSTANCE

```
     
## Install WEB instance:

``` 
     
     Project -> Compute -> Instances
     Select Launch
     Launch Instance
     Instance Name WEB
     Description: WEB SERVER
     NEXT
     Select minimal Debian image.
     NEXT
     Select m1.small  1 vcpu 2Gig RAM 20gig space.
     NEXT
     Select ELYSIUM Private Network. 
     #NEXT until Security Groups
     Deselect default.
     Select WEB
     NEXT
     Select MERCURY public key
     NEXT

```

Copy and paste JUMP Server Cloud Init file .

[CLOUD-INIT FOR DEBIAN WEB](https://github.com/icarusfactor/openstack-Installs/blob/master/cloud-init/WEBSERVER_DEBIAN_10.ci )


```
    LAUNCH INSTANCE

     Select Associate Floating IP from drop down.
     Click the Plus on IP address to generate a legal IP address. 
     Pool should be from OCEANUS
     Description: WEB  
     Allocate IP. Then Associate IP.

```

The floating IP address should appear in your Jump Servers' IP address column.        


## Finishing Up 
    
Now all nodes are setup and have uploaded your public key to them,mine is called MERCURY
to the servers via cloud-init and a JUMP server to log into as a central server to
reduce port activty and manage connections. But to do this you will have to setup 
SSH on the JUMP instance as a FORWARDER. 

     
## Log onto JUMP instance:

```     
$ cat /etc/ssh_config

```
Print out the /etc/ssh_config file

```
Host *
SendEnv LANG LC_*
ForwardAgent no

```
      
If you see the following, you will need to comment out the ForwardAgent.
This will override your home directory config if so.

     
## Create SSH configuration file

Add forwarding capabilites to ssh.
 
```
touch ~/.ssh/config
Host *
ForwardAgent yes

```
     
## Restart ssh server.

```

$ service sshd restart

```


## Add Default Keys
     
No arguments will add default keys while on host system.  

```

$ ssh-add 


```
     
## List Keys  


```

$ ssh-add -L 


```

## Login With SSH Forwarding 
     
Use SSH with -A to enable forwading.
Only needed on the first jump.

```
ssh -A debian@192.168.1.100

```

## Outro
     
Now you should be able to log into all of the internal IPs from 
the jumpbox with your desktop SSH key and keep only the JUMP box 
port open from the 192.168.1.x addresses. 


#!/bin/bash
#Create External Network as ADMIN .  

#Load config data. Only one file for extneral network so put all the variables in here. 
ROUTERNAME="LIMBO"
EXT_NET="OCEANUS"
EXT_SUBNET="RIVERS"
EXT_GATEWAY="192.168.1.1"
EXT_NETRANGE="192.168.1.0/24"
EXT_DNS1="8.8.4.4"
EXT_STARTNET="192.168.1.100"
EXT_ENDNET="192.168.1.200"

# Load admin creditials as root 
. /root/keystonerc_admin

#Create flat external network:
#A flat network will work with a normal home setup. 
openstack network create --provider-network-type flat --provider-physical-network extnet --share --external $EXT_NET

#Create external subnet:
# Subnet with same network as your single device adapter. 
openstack subnet create --subnet-range $EXT_NETRANGE --gateway $EXT_GATEWAY \
	  --network $EXT_NET --allocation-pool start=$EXT_STARTNET,end=$EXT_ENDNET \
	    --dns-nameserver $EXT_DNS1 $EXT_SUBNET
#Create router 
openstack router create $ROUTERNAME
#Add router interface to external network and set gateway.  
openstack router set --external-gateway $EXT_NET $ROUTERNAME

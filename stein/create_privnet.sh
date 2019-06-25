#!/bin/bash
#Create Private Network as USER for PROJECT.  

#Load config data
. /root/priv_config

# Load admin creditials as root then switch to user
. /root/keystonerc_admin

export OS_USERNAME=$USERNAME
export OS_PASSWORD=$USERPASS
export OS_PROJECT_NAME="$PROJECT"

# Load admin creditials 
. ./keystonerc_admin

# Create Private network , attach internal subnet
openstack network create --share $PRIV_NET
openstack subnet create --subnet-range $PRIV_IPCLASS/24 \
      --network $PRIV_NET --dns-nameserver 8.8.4.4 $PRIV_SUBNET 
#Attach router to internal subnet.     
openstack router add subnet $ROUTERNAME $PRIV_SUBNET

#!/bin/bash

#Load config data
. /root/priv_config


# Load admin creditials as root then switch to user
. /root/keystonerc_admin

export OS_USERNAME=$USERNAME
export OS_PASSWORD=$USERPASS
export OS_PROJECT_NAME="$PROJECT"

###############################################################JUMP

openstack server create --flavor m1.small --image $GLANCE_NAME \
   --nic net-id=$PRIV_NET --security-group $SECGROUP_NAME3  \
   --user-data $CLOUDINIT_LOC3 --key-name $KEY_NAME $SECGROUP_NAME3 

#Create floating IP and add to provider network.
openstack floating ip create OCEANUS

#Search for a free floating ip and attach to instance. 
COUNT=0
for OUTPUT in $(openstack floating ip list --format value)
do
let COUNT+=1
if [ "$COUNT" = "2" ] ; then
FLOAT=$OUTPUT
fi
if [ "$COUNT" = "4" ] ; then
PORT=$OUTPUT
fi
done
#Check free floating IP
if  [ "$PORT" = "None"  ] ; then
openstack server add floating ip $SECGROUP_NAME3 $FLOAT 
fi

###########################################################


###############################################################WEB

openstack server create --flavor m1.small --image $GLANCE_NAME \
   --nic net-id=$PRIV_NET --security-group $SECGROUP_NAME1  \
   --user-data $CLOUDINIT_LOC1 --key-name $KEY_NAME $SECGROUP_NAME1 

#Create floating IP and add to provider network.
openstack floating ip create OCEANUS

#Search for a free floating ip(without port) and attach to instance. 
COUNT=0
for OUTPUT in $(openstack floating ip list --format value)
do
let COUNT+=1
if [ "$COUNT" = "2" ] ; then
FLOAT=$OUTPUT
fi
if [ "$COUNT" = "4" ] ; then
PORT=$OUTPUT
fi
done
#Check free floating IP
if  [ "$PORT" = "None"  ] ; then
openstack server add floating ip $SECGROUP_NAME1 $FLOAT 
fi

###########################################################

###############################################################SQL

openstack server create --flavor m1.small --image $GLANCE_NAME \
   --nic net-id=$PRIV_NET --security-group $SECGROUP_NAME2  \
   --user-data $CLOUDINIT_LOC2 --key-name $KEY_NAME $SECGROUP_NAME2 

###############################################################

#!/bin/bash
#I like to keep all my images updated and on another system.
#I usually have many openstack sessions on virtualbox
#that use these cloud images and having all of them on one
#system that is an scp accesable stoage system fits this need.
  
#Load image to openstack image list that is located on remote system using bash
#and scp by copying it to the local tmp directory that will be deleted on reboot.

# Load admin creditials as root then switch to user
. /root/keystonerc_admin
#Load config data
. /root/priv_config

 
 scp $QCOW2_IMAGE_LOCATION$QCOW2_IMAGE_NAME /tmp/
 #Load QCOW2 image from tmp directoy.  
 openstack image create --public \
 --disk-format qcow2 --container-format bare \
 --file /tmp/$QCOW2_IMAGE_NAME $GLANCE_NAME
 #Remove image file from local file system. 
 rm /tmp/$QCOW2_IMAGE_NAME

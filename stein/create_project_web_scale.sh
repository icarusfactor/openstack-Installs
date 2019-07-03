#!/bin/bash


#Create user as admin and key as user
./create_project_user_key.sh

#Create image as admin
./create_osc_img.sh

#Create secuirty groups for network
./create_privnet_secgroups.sh

#Create private subnet and connect it to the exteranl router. 
./create_privnet.sh

#Create all three boxes for the web control system.
./launch_img_to_instance.sh

#This is just a text on how tomanually  setup ssh forwarding and
# get to all the systems in the group. So you can add or change
# user that this is for.  
sh_fwd_test.sh

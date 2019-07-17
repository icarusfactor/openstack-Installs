#!/bin/bash
# Create Project and add Load Local Key. 

#Load config data
. /root/priv_config

# Load admin creditials as root
. /root/keystonerc_admin


#Create a non-admin user developer in openstack and the project for the user.     
openstack project create --enable "$PROJECT"
openstack user create --project "$PROJECT" --password $USERPASS --enable $USERNAME  
#Assign user a role in project 
openstack role add --user $USERNAME --project "$PROJECT" _member_


export OS_USERNAME=$USERNAME
export OS_PASSWORD=$USERPASS
export OS_PROJECT_NAME="$PROJECT"

#Importing your local key pair as new user to the local openstack install and name it.  
scp $KEY_SCP_LOCATION /tmp/id_rsa.pub
openstack keypair create --public-key /tmp/id_rsa.pub $KEY_NAME
#Remove the key from temp directory
rm /tmp/id_rsa.pub

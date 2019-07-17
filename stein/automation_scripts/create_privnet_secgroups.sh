#!/bin/bash
#Load Security Groups as USER for PROJECT.  

#Load config data
. /root/priv_config

# Load admin creditials as root then switch to user
. /root/keystonerc_admin

# Create Security Groups as admin
openstack security group create --description "$SECGROUP_DESC1" --project "$PROJECT" $SECGROUP_NAME1    
openstack security group create --description "$SECGROUP_DESC2" --project "$PROJECT" $SECGROUP_NAME2   
openstack security group create --description "$SECGROUP_DESC3" --project "$PROJECT" $SECGROUP_NAME3   

export OS_USERNAME=$USERNAME
export OS_PASSWORD=$USERPASS
export OS_PROJECT_NAME="$PROJECT"


#WEB Secuirty Group 
#--------------------------------------------------------------------------------------------------------
#Add WEB Rules for SSH
openstack security group rule create $SECGROUP_NAME1 \
     --ingress --description SSH --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
 
#Add WEB rule for WEB ingress and egress
openstack security group rule create $SECGROUP_NAME1 \
     --ingress  --description PROXY --protocol tcp --dst-port 8080:8080 --remote-ip 0.0.0.0/0
    
openstack security group rule create $SECGROUP_NAME1 \
     --egress   --description PROXY --protocol tcp --dst-port 8080:8080 
  
#Add WEB rule for PING ingress and egress
openstack security group rule create $SECGROUP_NAME1 \
     --ingress  --description PING --protocol icmp --remote-ip 0.0.0.0/0 

openstack security group rule create $SECGROUP_NAME1 \
     --egress   --description PING --protocol icmp     
     
     
#SQL Security Group 
#----------------------------------------------------------------------------------------------------------  
#Add SQL Rules for SSH
openstack security group rule create $SECGROUP_NAME2 \
     --ingress --description SSH --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
 
#Add SQL rule for MYSQL ingress 
openstack security group rule create $SECGROUP_NAME2 \
     --ingress  --description MYSQL --protocol tcp --dst-port 3306:3306 --remote-ip 0.0.0.0/0
     
#---Optional access for desktop mysqlclient otherwise use internal web based client-------     
#Add SQL rule for MYSQL egress 
# openstack security group rule create $SECGROUP_NAME2 \
#     --egress  --description MYSQL --protocol tcp --dst-port 3306:3306
#------------------------------------------

#Add SQL rule for PING ingress 
openstack security group rule create $SECGROUP_NAME2 \
     --ingress  --description PING --protocol icmp --remote-ip 0.0.0.0/0     
     
     
#JUMP Security Group 
#----------------------------------------------------------------------------------------------------------  
#Add JUMP Rules for SSH ingress
openstack security group rule create $SECGROUP_NAME3 \
     --ingress --description SSH --protocol tcp --dst-port 22:22 --remote-ip 0.0.0.0/0
     
#Add JUMP Rules for SSH egress
openstack security group rule create $SECGROUP_NAME3 \
     --egress --description SSH --protocol tcp --dst-port 22:22   
  
#Add JUMP Rules for PING ingress 
openstack security group rule create $SECGROUP_NAME3 \
     --ingress  --description PING --protocol icmp --remote-ip 0.0.0.0/0     
     
#Add JUMP Rules for PING egress 
openstack security group rule create $SECGROUP_NAME3 \
     --egress  --description PING --protocol icmp        


#!/bin/bash

echo "Now before you're done you'll have to setup ssh forwarding on" 
echo "the JUMP box so you can ssh to it and then on to the WEB or SQL box"
echo " "
echo "STEP1: Ssh to the JUMP box from your desktop system with your key."
echo " "
echo "STEP 2: Create the ssh config file in the JUMP box home directory"
echo "touch /home/debian/.ssh/config"
echo "Add these two lines to this file."
echo "Host *" 
echo "ForwardAgent yes"
echo " "
echo "Also check the /etc/ssh_config and comment out ForwardAgent in this file"
echo " "
echo "STEP 3: Restart the ssh service:  service sshd restart"
echo " "
echo "STEP 4: No arguments will add default keys while on desktop:   ssh-add" 
echo " " 
echo "STEP 5: List the keys to check they have been added:    ssh-add -L"
echo " "
echo "Now you should be able to log into all of the internal IPs from" 
echo "the JUMP box with your desktop box SSH key." 

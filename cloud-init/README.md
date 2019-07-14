
![Openstack Cloud-init](../gh_img/openstack_cloud-init.png)

## CLOUD IMAGE INFORMATION

> I only have Debian and Ubuntu for all three items currently.
> Will make a ***WEB*** and ***SQL*** server for CENTOS and Fedora. OpenSUSE does not have
> or use cloud-init. Will have to figure out what they use to boot thier cloud images.
> NOTE: The Cirros and Ubuntu QCOW2 image is a ***.img*** file . 
> I have ran into a problem with older kernels (Older than 4.19 ) and
> newer images not working at all or with long delays. This problem has been
> diagnosed as ***BoottimeEntropyStarvation*** problem. This is a problem with
> SystemD and SSH(OpenSSL) causing it to hang. The fix this problem, you need
> to have a newer kernel with ***CONFIG_RANDOM_TRUST_CPU*** enabled or install
> the havaged package.

APT based package systems.

`sudo apt-get install havaged`

YUM based package systems.

`sudo yum -y install havaged`

Cirros 4 |                                         
-------- | --------------------------------------
URL      | http://download.cirros-cloud.net/   
TESTED   | cirros-0.4.0-x86_64-disk.img      
Login    | username:cirros  password: gocubsgo 


#-----------------------------------------------------------------

#Debian 9--:

#URL-------: https://cdimage.debian.org/cdimage/openstack/current/

#TESTED----: debian-9.9.4-20190703-openstack-amd64.qcow2

#Login account is debian. The password is cloud.

#----------------------------------------------------------------

#Debian 10--:

#URL-------: https://cdimage.debian.org/cdimage/openstack/current/

#TESTED----: debian-10.0.1-20190708-openstack-amd64.qcow2

#Login account is debian. The password is cloud.

#----------------------------------------------------------------

#Ubuntu 18-:

#URL-------: http://cloud-images.ubuntu.com/bionic/current/

#TESTED----: bionic-server-cloudimg-amd64.img 

#Login account is ubuntu. The password is cloud.

#----------------------------------------------------------------

#CENTOS 7--:

#URL-------: https://cloud.centos.org/centos/7/images/

#TESTED----: CentOS-7-x86_64-GenericCloud-1811.qcow2

#Login account is centos. The password is cloud.

#---------------------------------------------------------------

#Fedora 30--:

#URL-------: https://alt.fedoraproject.org/cloud/

#TESTED----: Fedora-Cloud-Base-30-1.2.x86_64.qcow2

#---------------------------------------------------------------

#THESE URLS I HAVE NOT TESTED OR GOTTEN TO WORK YET

#OPENSUSE--: 

#URL-------: https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.0/images/





![Openstack Cloud-init](../gh_img/openstack_cloud-init.png)

## CLOUD IMAGE INFORMATION

> I've only Debian and Ubuntu and CentOS made for all three image items currently.
> Will make a ***WEB*** and ***SQL*** server image for CENTOS and Fedora. But
> have to configure them with Puppet instead of debconf. OpenSUSE does not have
> or use cloud-init. Will have to figure out what they use to boot thier cloud 
> images. ***NOTE: The Cirros and Ubuntu QCOW2 image are an .img file.*** 
> I've ran into a problem with older kernels(Older than 4.19)and newer images
> not working at all or with long delays. This problem has been diagnosed as
> a ***BoottimeEntropyStarvation*** problem. This is a problem with SystemD 
> and SSH(OpenSSL) causing it to hang. The fix for this problem, you need
> to have a newer kernel with ***CONFIG_RANDOM_TRUST_CPU*** enabled or install
> the havaged package.

APT based package systems.

`sudo apt-get install havaged`

YUM based package systems.

`sudo yum -y install havaged`

## Cloud Location and Image tested against. 

OS       | Cirros 4                                        
-------- | --------------------------------------
URL      | http://download.cirros-cloud.net/   
TESTED   | cirros-0.4.0-x86_64-disk.img      
LOGIN    | username:cirros  password: gocubsgo 

OS       | Debian 9                                        
-------- | --------------------------------------
URL      | https://cdimage.debian.org/cdimage/openstack/current/
TESTED   | debian-9.9.4-20190703-openstack-amd64.qcow2
LOGIN    | username:debian password:cloud

OS        | Debian 10                                        
--------- | --------------------------------------
URL       | https://cdimage.debian.org/cdimage/openstack/current/
TESTED    | debian-10.0.1-20190708-openstack-amd64.qcow2
LOGIN     | username:debian password:cloud

OS        | Ubuntu 18                                        
--------- | --------------------------------------
URL       | http://cloud-images.ubuntu.com/bionic/current/
TESTED    | bionic-server-cloudimg-amd64.img 
LOGIN     | username:ubuntu password:cloud

OS        | Ubuntu 19                                        
--------- | --------------------------------------
URL       | https://cloud-images.ubuntu.com/disco/current/
TESTED    | disco-server-cloudimg-amd64.img 
LOGIN     | username:ubuntu password:cloud

OS        | CentOS 7                                       
--------- | --------------------------------------
URL       | https://cloud.centos.org/centos/7/images/
TESTED    | CentOS-7-x86_64-GenericCloud-1811.qcow2
LOGIN     | username:centos password:cloud

OS        | Fedora 30                                       
--------- | --------------------------------------
URL       | https://alt.fedoraproject.org/cloud/
TESTED    | Fedora-Cloud-Base-30-1.2.x86_64.qcow2
LOGIN     | username:fedora password:cloud

## Os's I've tested but not gotten to work yet.

OS        | OpenSUSE 15 or 42/43                                       
--------- | --------------------------------------
URL       | https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.0/images/
TESTED    | Cloud-init does not exist on theses images. 
LOGIN     | N/A



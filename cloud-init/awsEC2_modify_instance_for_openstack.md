
![AWS EC2 Openstack Cloud-init Hack](../gh_img/openstack_cloud-init.png)

## Booting Amazon Elastic Cloud Linux 2 on OpenStack


> Image location:

`
https://cdn.amazonlinux.com/os-images/latest/
`

> It will redirect you to the newest version.
> then go to the "kvm" directory.

`
wget https://cdn.amazonlinux.com/os-images/2.0.20190612/kvm/amzn2-kvm-2.0.20190612-x86_64.xfs.gpt.qcow2
`

## Install utility for manipulating qcow2 images
`
sudo yum install qemu-img
`

## Convert AWS To RAW.

> Now we can convert Amazon Linux 2 image from the qcow2 format to the raw format:

`
qemu-img convert -f qcow2 -O raw amzn2-kvm-2.0.20190612-x86_64.xfs.gpt.qcow2 amzn2-kvm.raw
`

## View paritions of the instance. 
`
$ fdisk -l amzn2-kvm.raw
`

## Mount the disk with FS offset found from previous command.

> The Linux filesystem should start at the sector number 4096.
> Which will give you 4096 * 512 = 2097152. 

`
 sudo mount -o loop,offset=2097152 amzn2-kvm.raw /mnt
`

## Edit EC2 cloud-init image configuration. 

`
 sudo vi /mnt/etc/cloud/cloud.cfg
`
## Change file to give Openstack access to boot.
> Make sure to leave end to say "None". 
`
datasource_list: [ NoCloud, AltCloud, ConfigDrive, OVF, None ]

datasource_list: [ OpenStack, NoCloud, AltCloud, ConfigDrive, OVF, None ]
`

## Save and unmount the file system. 
`
sudo umount /mnt
`

## Convert RAW image back to QCOW2
`
qemu-img convert -f raw -O qcow2 amzn2-kvm.raw amzn2-kvm.qcow2
`

## Now the image should be able to load and launch from openstack Glance. 



#!/bin/bash
NAME='c7-ks'
#ISO='/var/lib/libvirt/images/ISO/CentOS-7-x86_64-Minimal-1708.iso'
ISO='http://mirror.centos.org/centos/7/os/x86_64/'
MEM=2048
CPUS=1
DISTRO='centos7.0'
SIZE=20

virt-install \
    --name $NAME \
    --ram $MEM \
    --vcpus=$CPUS \
    --os-type linux \
    --os-variant $DISTRO \
    --virt-type kvm \
    --network bridge=virbr2 \
    --location $ISO \
    --hvm \
    --graphics spice \
    --disk path=/var/lib/libvirt/images/${NAME}.qcow2,size=$SIZE \
    --extra-args "ks=http://10.0.0.1/ks-net.cfg console=tty0 console=ttyS1,115200 ip=dhcp"
#    --initrd-inject=ks-net.cfg --extra-args "ks=file:/ks-net.cfg console=tty0 console=ttyS1,115200"

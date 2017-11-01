#!/bin/bash
MACHINE=$1
virsh destroy $MACHINE
virsh undefine $MACHINE
rm -rf /var/lib/libvirt/images/${MACHINE}.qcow2
sed -i "/$MACHINE/d" /etc/hosts

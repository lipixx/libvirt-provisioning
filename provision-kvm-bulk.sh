#!/bin/bash

if [ $# != 6 ]
then
    echo "Usage: ./provision-kvm-bulk.sh <vm_name_pattern> <memory(MiB)> <vcpus> <hdsize(GB)> <start_private_ip> <nhosts>"
    echo "Example:"
    echo "          #] ./provision-kvm-bulk.sh moll-srv 2048 2 20 172.26.0.20 5"
    exit 1
fi

# Hardcoded variables
mask_virbr0=255.255.0.0
dev_virbr0=eth1
baseks=ks-labmoll.cfg
iso='/var/lib/libvirt/images/ISO/CentOS-7-x86_64-Minimal-1708.iso'

# Passed parameters
namepattern=$1
mem=$2
vcpus=$3
hdsize=$4
start_ip_virbr0=$5
nhosts=$6

# Start
provisiondir=$(date +%s)
mkdir $provisiondir
cp $baseks $provisiondir
cd $provisiondir

first_ip=$(echo $5|cut -d"." -f 4)
last_ip=$((first_ip+nhosts))
base_ip=$(echo $5|cut -d"." -f -3)
curr_ip=$first_ip
i=$curr_ip

while [ $i -lt $last_ip ]
do
    if [ $i -lt 10 ]
    then
	curr_ip=$i
    else
	curr_ip=$(printf "%02d" $i)
    fi
    name="${namepattern}${curr_ip}"
    mkdir ${name}
    cp $baseks ${name}
    cd ${name}

    echo "Creating ${provisiondir}/${name}"
   
    ip=${base_ip}.${curr_ip}

    sed -i "s/__IPVIRBR0__/$ip/g" "$baseks"
    sed -i "s/__HOSTNAME__/$name/g" "$baseks"
    sed -i "s/__DEVVIRBR0__/$dev_virbr0/g" "$baseks"
    sed -i "s/__MASKVIRBR0__/$mask_virbr0/g" "$baseks"

    nohup virt-install \
	--name $name \
	--ram $mem \
	--vcpus=$vcpus \
	--os-type linux \
	--os-variant centos7.0 \
	--virt-type kvm \
	--network bridge=br0 \
	--network bridge=virbr0 \
	--location $iso \
	--hvm \
	--wait=-1 \
	--noautoconsole \
	--graphics spice \
	--disk path=/var/lib/libvirt/images/${name}.qcow2,size=$hdsize \
	--initrd-inject=${baseks} --extra-args "ks=file:/${baseks} console=tty0 console=ttyS1,115200" > $name.log  2>&1 &
    disown
    cd ..
    i=$((i+1))
done

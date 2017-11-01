#!/bin/bash

if [ $# != 7 ]
then
    echo "Usage: ./provision-kvm-bulk.sh <vm_name_pattern> <memory(MiB)> <vcpus> <hdsize(GB)> <start_private_ip> <base_domain> <nhosts>"
    echo "Example:"
    echo "          #] ./provision-kvm-bulk.sh moll-srv 2048 2 20 172.26.0.20 template-vm 5"
    exit 1
fi

# Hardcoded variables
mask_virbr0=255.255.0.0
dev_virbr0=eth1

# Passed parameters
namepattern=$1
mem=$2
vcpus=$3
hdsize=$4
start_ip_virbr0=$5
basedom=$6
nhosts=$7

# Start
provisiondir="$(date +%s)_clone"
mkdir $provisiondir
cp setup.in $provisiondir
cd $provisiondir

first_ip=$(echo $5|cut -d"." -f 4)
last_ip=$((first_ip+nhosts))
base_ip=$(echo $5|cut -d"." -f -3)
curr_ip=$first_ip
i=$curr_ip

function clone_prep(){
    basedom_=$1
    name_=$2 

    cat <<EOF > virt-create.sh
#!/bin/bash
virt-clone --original ${basedom_} --name ${name_} -f /var/lib/libvirt/images/${name_}.qcow2 > ${name_}-clone.log    
virt-sysprep --operations defaults,-ssh-userdir --hostname ${name_} --run setup_${name_}.sh -d ${name_}
virsh start ${name_}
EOF
    chmod +x virt-create.sh
    nohup ./virt-create.sh >> virt-create.log  2>&1 &
}

while [ $i -lt $last_ip ]
do
    echo "Note: virt-clone is not parallelizable, but we use it concurrently. Can give errors on libvirt and machine will not be deployed, just try again."
    if [ $i -lt 10 ]
    then
	curr_ip=$i
    else
	curr_ip=$(printf "%02d" $i)
    fi
    name="${namepattern}"
    mkdir ${name}
    cp setup.in ${name}/setup_${name}.sh
    cd ${name}

    echo "Creating ${provisiondir}/${name}"
   
    ip=${base_ip}.${curr_ip}

    sed -i "s/__IPVIRBR0__/$ip/g" "setup_$name.sh"
    sed -i "s/__DEVVIRBR0__/$dev_virbr0/g" "setup_$name.sh"
    sed -i "s/__MASKVIRBR0__/$mask_virbr0/g" "setup_$name.sh"

    chmod +x setup_$name.sh
    clone_prep $basedom $name
    grep $ip /etc/hosts > /dev/null
    if [  $? -eq 1 ]
    then
	echo "$ip $name" >> /etc/hosts
    fi
    cd ..
    i=$((i+1))
done

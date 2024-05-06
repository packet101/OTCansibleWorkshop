#!/usr/bin/bash

if [[ $# -ne 1 ]]
then
	echo "Usage:"
	echo "setup.sh podname"
	exit -1
fi
podname=$1

csr1ip=`grep "clab-$podname-csr1" /etc/hosts | grep "^172.20" | awk '{print $1}'`
vmx1ip=`grep "clab-$podname-vmx1" /etc/hosts | grep "^172.20" | awk '{print $1}'`
echo "Configuring lab for pod $podname"
echo "CSR1(r1) IPv4 address $csr1ip"
echo "VMX1(r2) IPv4 address $vmx1ip"

cat > lab5/task5.txt <<EOF 
Your hostname for r1 is clab-$podname-csr1.
Your hostname for r2 is clab-$podname-vmx1.
The username and password for r1 is admin/admin
The username and password for r2 is admin/admin@123

Login to one of the devices, your choice, and make a configuration change to the hostname.
For r1:
  config t
  hostname <new hostname>
For r2:
  config
  set system hostname <new hostname>
  commit
EOF

echo "Configuring inventory files"
for i in lab1 lab2 lab3 lab4 lab5 lab6 lab7 lab8 lab9 lab10 lab11 lab12
do
	echo "$i"
	cp configs/ansible.cfg $i/
	rm -rf $i/inventory/host_vars
	mkdir -p $i/inventory/host_vars
	cat > $i/inventory/routers <<EOF
[cisco]
r1
[juniper]
r2
EOF
	cat > $i/inventory/host_vars/r1.yml <<EOF
---
ansible_host: $csr1ip
EOF
	cat > $i/inventory/host_vars/r2.yml <<EOF
---
ansible_host: $vmx1ip
EOF
	cat > $i/inventory/group_vars/cisco.yml <<EOF
---
ansible_connection: ansible.netcommon.network_cli
ansible_network_os: cisco.ios.ios
ansible_user: admin
ansible_password: admin
EOF
	cat > $i/inventory/group_vars/juniper.yml <<EOF
---
ansible_connection: ansible.netcommon.netconf
ansible_network_os: junipernetworks.junos.junos
ansible_user: admin
ansible_password: admin@123
EOF
done

#!/usr/bin/env bash
virsh -c lxc:/// list --all
read -p "Enter LXC VM Name to create: " LXC_NAME
if virsh -c lxc:/// domstate ${LXC_NAME} &>/dev/null; then echo "VM already exists! Exiting..."; exit; fi

#LXC_NAME=c2
LXC_RAM=512
LXC_REL=7
LXC_OSV=centos7.0
LXC_NET=default
LXC_PKG="systemd passwd yum centos-release vim-enhanced openssh-server procps-ng iproute net-tools dhclient sudo rootfiles tcpdump"

ROOT_FS=/var/lib/libvirt/lxc/
LXC_RFS=${ROOT_FS}${LXC_NAME}/
mkdir -p ${LXC_RFS}
yum -y --installroot=${LXC_RFS} --releasever=${LXC_REL} --nogpg install ${LXC_PKG}
sed -i -r -e 's|^root.*|root:$6$TfrIHAnz$xJ2/E5cwAPwMkIblwaFreluGX6TwJ5LNVDLHJbbs6r8AGKYHHvvSwloddKeXQja0gVgeUZTX.aPSuHj6/qaDz1::0:99999:7:::|gi' ${LXC_RFS}etc/shadow
echo pts/0 >> ${LXC_RFS}etc/securetty
echo ${LXC_NAME}-lxc > ${LXC_RFS}etc/hostname
touch ${LXC_RFS}etc/sysconfig/network
echo "DEVICE=eth0"    >  ${LXC_RFS}etc/sysconfig/network-scripts/ifcfg-eth0
echo "ONBOOT=yes"     >> ${LXC_RFS}etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=dhcp" >> ${LXC_RFS}etc/sysconfig/network-scripts/ifcfg-eth0
virt-install --connect lxc:/// --name ${LXC_NAME} --ram ${LXC_RAM} --os-variant=${LXC_OSV} --filesystem ${LXC_RFS},/ --network network=${LXC_NET} --noautoconsole

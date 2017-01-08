#!/usr/bin/env bash
# Creates a new LXC VM
# Name of new VM can be passed as an argument or entered interactively

# Links below were worth reading :)
# http://www.nefigtut.ru/2015/11/18/libvirt-lxc-virtualization-1/
# https://der-linux-admin.de/2014/08/centos-7-centos-7-im-lxc-container/
# https://wiki.centos.org/HowTos/LXC-on-CentOS6
# https://access.redhat.com/articles/1365153
# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/sect-Guest_virtual_machine_installation_overview-Creating_guests_with_virt_install.html

#LXC_NAME=c2
LXC_RAM=512
LXC_REL=7
LXC_OSV=centos7.0
LXC_NET=default
LXC_PKG="systemd passwd yum centos-release vim-enhanced openssh-server procps-ng iproute net-tools dhclient sudo rootfiles tcpdump"

if [ "$#" -gt 0 ]; then
    LXC_NAME=${1}
else
    virsh -c lxc:/// list --all
    read -p "Enter LXC VM Name to create: " LXC_NAME
fi

if virsh -c lxc:/// domstate ${LXC_NAME} &>/dev/null; then echo "VM already exists! Exiting..."; exit; fi

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

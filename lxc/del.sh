#!/usr/bin/env bash

virsh -c lxc:/// list --all
read -p "Enter LXC VM Name to fully delete: " LXC_NAME
echo "Checking state of VM..."
virsh -c lxc:/// domstate ${LXC_NAME} || exit

LXC_RFS=$(virsh -c lxc:/// dumpxml ${LXC_NAME} | grep 'source dir' | grep -o "'.*'" | tr -d \')
echo "rm -rf ${LXC_RFS}"
echo "rm -rf /var/run/libvirt/lxc/${LXC_NAME}*"
read -p "Press 'Enter' to continue or 'CTRL-C' to abort"

echo "Deleting ${LXC_NAME}..."
virsh -c lxc:/// shutdown ${LXC_NAME} && sleep 3 # Wait if shutdown initiated
echo "Checking state of VM... I will exit if not 'shut off'"
virsh -c lxc:/// domstate ${LXC_NAME} | grep "shut off" || exit # Exit if VM is not in shut off state
virsh -c lxc:/// undefine ${LXC_NAME}
echo "Checking state of VM... I will exit if it is still defined"
virsh -c lxc:/// domstate ${LXC_NAME} 2>/dev/null && exit
echo "Undefined successfully"

echo "Deleting ${LXC_RFS}..."
rm -rf ${LXC_RFS}
ls -la ${LXC_RFS} 2>/dev/null && echo "[ERROR] Still exists" || echo "OK"

echo "Deleting /var/run/libvirt/lxc/${LXC_NAME}*..."
rm -rf /var/run/libvirt/lxc/${LXC_NAME}*
ls -la /var/run/libvirt/lxc/${LXC_NAME}* 2>/dev/null && echo "[ERROR] Directory still exists" || echo "OK"

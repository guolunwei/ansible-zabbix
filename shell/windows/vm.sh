#!/bin/bash

# Define constants
BASE_DIR="D:\Virtual Machines"
SRC_VMX="D:\Virtual Machines\Rocky8_nsd\Rocky8_nsd.vmx"
SNAPSHOT="template"
ROOTPASS="123"

# Check if source vmx exists
if [ ! -f "$SRC_VMX" ]; then
    echo "Source vmx does not exist."
    exit 1
fi

# Function to create a linked-clone
clone_vm() {
    local vm_name="$1"
    vmrun -T ws clone "$SRC_VMX" "$BASE_DIR/$vm_name/$vm_name.vmx" linked -snapshot=$SNAPSHOT -cloneName=$vm_name
    vmrun -T ws start "$BASE_DIR/$vm_name/$vm_name.vmx" gui
}

# Function to remove a VM
# Note: Needs to stop the VM and close tabs in Workstation before removing it
remove_vm() {
    local vm_name="$1"
    rm -rf "${BASE_DIR}\${vm_name}"
    #vmrun -T ws deleteVM "$BASE_DIR/$vm_name/$vm_name.vmx"
}

# Function to start a VM
start_vm() {
    local vm_name="$1"
    vmrun -T ws start "$BASE_DIR/$vm_name/$vm_name.vmx" gui
}

# Function to stop a VM
stop_vm() {
    local vm_name="$1"
    vmrun -T ws stop "$BASE_DIR/$vm_name/$vm_name.vmx"
}

# Function to set host IP address of a VM
set_host_ip() {
    local vm_name="$1"
    local ip_addr="$2"
    vmrun -T ws -gu root -gp "$ROOTPASS" runScriptInGuest "$BASE_DIR/$vm_name/$vm_name.vmx" "bin/bash" "hostnamectl set-hostname $vm_name; \
    nmcli connection modify eth0 ipv4.method manual ipv4.addresses $ip_addr/24 ipv4.gateway 192.168.88.254 ipv4.dns 192.168.88.254 autoconnect yes; \
    nmcli connection up eth0"
}

# Function to display usage information
usage() {
    echo "Usage: $0 [command] [vm_name] [ip_addr]"
    echo ""
    echo "Available commands:"
    echo "  clone      Clone one or more VMs from the template"
    echo "  remove     Remove one or more VMs"
    echo "  start      Start one or more VMs"
    echo "  stop       Stop one or more VMs"
    echo "  setip      Set IP address of a VM"
    exit 1
}

# Main script logic
case $1 in
    "clone")
        if [ $# -lt 2 ]; then
            usage
        fi
        shift
        for vm_name in "$@"; do
            clone_vm "$vm_name"
        done
        ;;
    "remove")
        if [ $# -lt 2 ]; then
            usage
        fi
        shift
        for vm_name in "$@"; do
            remove_vm "$vm_name"
        done
        ;;
    "start")
        if [ $# -lt 2 ]; then
            usage
        fi
        shift
        for vm_name in "$@"; do
            start_vm "$vm_name"
        done
        ;;
    "stop")
        if [ $# -lt 2 ]; then
            usage
        fi
        shift
        for vm_name in "$@"; do
            stop_vm "$vm_name"
        done
        ;;
    "setip")
        if [ $# -ne 3 ]; then
            usage
        fi
        set_host_ip "$2" "$3"
        ;;
    *)
        usage
        ;;
esac
exit 0
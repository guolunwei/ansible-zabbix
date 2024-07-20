#!/bin/bash
while read -r name ip
do
    if sudo virsh list --all | grep -qw "$name"; then
        vm remove "$name" &> /dev/null
    fi
    vm clone "$name"
    if [[ "$name" =~ "zabbixserver" ]]; then
        vmmem set "$name" 2
    fi
    vm setip "$name" "$ip"
done < vm.txt

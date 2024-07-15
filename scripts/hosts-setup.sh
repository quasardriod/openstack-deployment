#!/bin/bash

source scripts/constant.sh

[ -z $1 ] && error "\nERROR: Provide inventory file in 1st argument\n" && exit 1
if [ ! -f $1 ];then
    error "\nERROR: Inventory file: $1 not found\n"
    exit 1
fi
HOST_SETUP_FIELS_PATH="hosts-setup"
MACHINES_INVENTORY=$1
PB="$HOST_SETUP_FIELS_PATH/playbooks/system-config.yml"

[ ! -f $MACHINES_INVENTORY ] && echo "ERROR: Inventory file: $MACHINES_INVENTORY not found" && exit 1
ansible-playbook -i $MACHINES_INVENTORY $PB

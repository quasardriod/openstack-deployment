#!/bin/bash

set -eo pipefail

source scripts/constant.sh

[ -z $1 ] && error "\nERROR: Provide inventory file in 1st argument\n" && exit 1
if [ ! -f $1 ];then
    error "\nERROR: Inventory file: $1 not found\n"
    exit 1
fi
KOLLA_FIELS_PATH="openstack-kolla"
MACHINES_INVENTORY=$1
PB=$KOLLA_FIELS_PATH/playbooks/deployer.yml

[ ! -f $MACHINES_INVENTORY ] && echo "ERROR: Inventory file: $MACHINES_INVENTORY not found" && exit 1

function main(){
    if [ $(ansible-inventory -i $MACHINES_INVENTORY --list |jq '._meta.hostvars.localhost|length') == 0 ];then
        ansible-playbook -i $MACHINES_INVENTORY $PB
    else
        ansible-playbook -i $MACHINES_INVENTORY $PB -e WORKDIR=$PWD
    fi
}

main

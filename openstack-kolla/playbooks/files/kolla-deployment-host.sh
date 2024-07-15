#!/bin/bash

PY_VENV=/root/kolla-venv

# Install Required packages on localhost
function install_dependencies(){
    source /etc/os-release
    printf "\nINFO: Installing packages dependencies on Kolla ansible deployment host...\n"    

    if [[ $ID =~ fedora ]];then
        sudo dnf install -y -q \
            git python3-devel libffi-devel gcc openssl-devel python3-libselinux
    fi
}

function py_venv(){
    printf "\nINFO: Create python virtual env\n"
    python3 -m venv $PY_VENV
    source $PY_VENV/bin/activate
    pip install -U pip
    pip install 'ansible-core>=2.15,<2.16.99'
}

function install_kolla_ansible(){
    # source $PY_VENV/bin/activate
    # pip install git+https://opendev.org/openstack/kolla-ansible@master
    git clone --branch master https://opendev.org/openstack/kolla-ansible
    [ ! -d /etc/kolla ] && mkdir -p /etc/kolla
    
    # Copy globals.yml and passwords.yml to /etc/kolla directory.
    cp -r kolla-ansible/etc/kolla/* /etc/kolla
    cp /root/globals.yml /etc/kolla/
}

function install_galaxy_requirements(){
    source $PY_VENV/bin/activate
    kolla-ansible install-deps
}

function prepare_initial_configuration(){
    source $PY_VENV/bin/activate
    cd kolla-ansible/tools && ./generate_passwords.py
}

function main(){
    install_dependencies
    py_venv
    install_kolla_ansible
    install_galaxy_requirements
    prepare_initial_configuration
}

main

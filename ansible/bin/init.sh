#!/usr/bin/env bash

# Install ansible
if ! which ansible > /dev/null
then

    # Update Repositories
    sudo apt-get update

    # Install BC
    if ! type bc > /dev/null 2>&1
    then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y bc
    fi

    # Install add-apt-repository
    if ! which add-apt-repository > /dev/null
    then
        # Determine Ubuntu Version
        . /etc/lsb-release

        # Decide on package to install for `add-apt-repository` command
        #
        # USE_COMMON=1 when using a distribution over 12.04
        # USE_COMMON=0 when using a distribution at 12.04 or older
        USE_COMMON=$(echo "$DISTRIB_RELEASE > 12.04" | bc)

        if [ "$USE_COMMON" -eq "1" ];
        then
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
        else
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python-software-properties
        fi
    fi

    # Add Ansible Repository & Install Ansible
    sudo add-apt-repository -y ppa:ansible/ansible
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ansible

fi

# Setup Ansible for Local Use and Run
sudo cp $1/ansible/inventories/dev /etc/ansible/hosts -f
sudo chmod 666 /etc/ansible/hosts
sudo cat $1/ansible/files/authorized_keys >> /home/vagrant/.ssh/authorized_keys

# Run ansible under normal user
ansible-playbook $1/ansible/playbook.yml -e hostname=$2 --connection=local --extra-vars='{"private_interface": "'$3'", "terminal": "'$4'"}'

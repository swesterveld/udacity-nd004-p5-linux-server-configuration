#!/usr/bin/env bash

# replace default ansible (1.5.4+dfsg-1) with official repo
if ! dpkg-query --show ansible &> /dev/null; then
    sudo apt-add-repository -y ppa:ansible/ansible
    sudo apt-get update
    sudo apt-get install -y ansible
fi

# Disable host key checking in Ansible
sudo sed -i -e 's/^#host_key_checking = False/host_key_checking = False/' /etc/ansible/ansible.cfg

# Add [local] to hosts
if ! sudo grep [[]local[]] /etc/ansible/hosts &> /dev/null; then
    echo -e "\n[local]\n127.0.0.1" | sudo tee --append /etc/ansible/hosts > /dev/null
fi

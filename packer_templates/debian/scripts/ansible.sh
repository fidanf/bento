#!/bin/bash -eux

dos2unix /tmp/ansible_id_rsa_pub

HOME=/home/ansible
ANSIBLE_PUBKEY_CONTENT=$(cat /tmp/ansible_id_rsa_pub)

# create ansible user
useradd -p $(openssl passwd -1 ansible) --create-home -s /bin/bash ansible

# add ansible user to ansible group
usermod -a -G ansible ansible

# add it to sudoers
echo "
Defaults:ansible  !requiretty
ansible   ALL=(ALL)   NOPASSWD: ALL
" > /etc/sudoers.d/ansible

# validate
visudo -cf /etc/sudoers.d/ansible 

# set ssh keys
mkdir $HOME/.ssh/
echo "$ANSIBLE_PUBKEY_CONTENT" | tee -a $HOME/.ssh/authorized_keys > /dev/null
chmod 600 $HOME/.ssh/authorized_keys

# refresh permissions
chown -R ansible:ansible $HOME

# remove pubkey file
rm -f /tmp/ansible_id_rsa_pub

#!/bin/bash -ux

HOME=/home/ansible
FILE=/home/vagrant/id_rsa.pub

dos2unix $FILE

if [ ! $(id -u ansible) ]; then
    # create ansible user
    useradd -p $(openssl passwd -1 ansible) --create-home -s /bin/bash ansible
    # add ansible user to ansible group
    usermod -aG ansible ansible
fi

# add it to sudoers
echo "
Defaults:ansible  !requiretty
ansible   ALL=(ALL)   NOPASSWD: ALL
" > /etc/sudoers.d/ansible

# validate
visudo -cf /etc/sudoers.d/ansible 

# set ssh keys
mkdir $HOME/.ssh/
ANSIBLE_PUBKEY_CONTENT=$(cat $FILE)
echo "$ANSIBLE_PUBKEY_CONTENT" | tee -a $HOME/.ssh/authorized_keys > /dev/null
chmod 600 $HOME/.ssh/authorized_keys

# refresh permissions
chown -R ansible:ansible $HOME

# remove pubkey file
rm -f $FILE

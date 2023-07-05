#! /usr/bin/bash

grep 'Ubuntu' /etc/os-release
m_ubuntu=$?

echo $m_ubuntu
if [ $m_ubuntu == 0 ]
then
    sudo apt install firewalld
    # # sudo firewall-cmd --state                 ## needless
    sudo systemctl enable firewalld
    sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
    # echo "Skipped"
else
    sudo yum install firewalld
    # sudo firewall-cmd --state                 ## needless
    sudo systemctl enable firewalld
    sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
fi

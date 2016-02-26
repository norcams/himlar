#!/bin/bash

user='git.git'
installdir='/var/lib/git'
IFS='-' read -r -a array <<< "$(hostname -s)"
role="${array[1]}-${array[2]}"

cp "/opt/himlar/provision/git/${role}/id_rsa" "${installdir}/.ssh/."
cp "/opt/himlar/provision/git/${role}/id_rsa.pub" "${installdir}/.ssh/."
cp "/opt/himlar/provision/git/ssh_config" "${installdir}/.ssh/config"
chown -R ${user} "${installdir}/.ssh/"
chmod 0600 ${installdir}/.ssh/*

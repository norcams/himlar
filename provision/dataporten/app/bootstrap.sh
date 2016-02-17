#!/bin/bash

installdir='/var/www/dataporten'
packages='gcc python-devel python-virtualenv httpd'

yum install -y ${packages}
mkdir ${installdir}
git clone https://github.com/raykrist/himlar-dp-prep.git ${installdir}/.
cd ${installdir} && git submodule update --init
virtualenv ${installdir}
cd ${installdir} && bin/python setup.py install

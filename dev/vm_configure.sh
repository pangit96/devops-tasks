#!/bin/bash

export USER="monsoon"
export HOME=/home/$USER
gituser="pangit96"
gitpass="utkarshmonsoon123"

#creating working directory
sudo -u $USER mkdir $HOME/repo

#cloning projects
sudo -u $USER git clone https://$gituser:$gitpass@github.com/monsoon-fintech/monsoon-infrastructure.git $HOME/repo/monsoon-infrastructure

if sudo -u $USER bash $HOME/repo/monsoon-infrastructure/vm_configure/vm_cofigure_python-3.6.sh
then
    exit 0
fi

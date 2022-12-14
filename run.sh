#! /bin/bash

echo "
###############
    Playment Task
    Author:  Utkarsh Pandit
    Email:   pandit.utkarsh14@gmail.com
###############
"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
VENV="utkarsh"

checks() {
    #check for python3 
    echo -e "\e[1;34mChecking for Python3 support\e[0m"
    if ! python3 --version > /dev/null
    then
        echo -e "\e[1;31mERROR!! Python3 required for this task. Install python3 and try again. Exiting ..\e[0m]"
        exit 1
    else 
        echo -e "\e[1;32mPython3 detected. Good to go ..\e[0m" 
    fi
    
    #check docker engine
    echo -e "\e[1;34mChecking for Docker engine in the system\e[0m"
    if ! systemctl is-active docker > /dev/null
    then
        echo -e "\e[1;31mERROR!! Docker engine not installed in this system. Exiting ..\e[0m]"
        exit 1
    else 
        echo -e "\e[1;32mDocker-engine is active. Good to go ..\e[0m" 
    fi

    #check docker-compose
    echo -e "\e[1;34mChecking for docker-compose in the system\e[0m"
    if ! docker-compose --version > /dev/null
    then
        echo -e "\e[1;31mERROR!! docker-compose not installed in this system. Exiting ..\e[0m]"
        exit 1
    else 
        echo -e "\e[1;32mdocker-compose is active. Good to go ..\e[0m" 
    fi
    
}
 
setup() {
    echo -e "\n\n
###############
    Setting up Environment
###############
    "
    cd ${SCRIPT_DIR}
    docker-compose up -d
    sleep 5
    if [ "$(docker container inspect -f '{{.State.Running}}' 'playment-localstack')" == "true" ]
    then
        echo -e "\e[1;32m'playment-localstack' container running.\e[0m"
    else
        echo -e "\e[1;31mERROR!! 'playment-localstack' container failed to start. Exiting ..\e[0m]"
        exit 1
    fi

    if [ "$(docker container inspect -f '{{.State.Running}}' 'playment-dynamoDB')" == "true" ]
    then
        echo -e "\e[1;32m'playment-dynamoDB' container running.\e[0m"
    else
        echo -e "\e[1;31mERROR!! 'playment-dynamoDB' container failed to start. Exiting ..\e[0m]"
        exit 1
    fi

    # create a virtualenv
    if ! virtualenv ~/${VENV} > /dev/null
    then
        echo -e "\e[1;31mERROR!! Couldn't create a virtual python environment. Install virtualenv and try again. Exiting ..\e[0m]"
    fi
    
    #install playment-cli python package
    source ~/${VENV}/bin/activate
    if pip install ${SCRIPT_DIR}/playment-cli/. > /dev/null
    then
        echo -e "\e[1;32mPLAYMENT-CLI installed successfuly.\e[0m"
    else
        echo -e "\e[1;31mERROR!! Failed to install PLAYMENT-CLI. Exiting ..\e[0m]"
        exit 1
    fi
    
    #set dummy aws cli creds
    aws configure set aws_access_key_id "dummy"
    aws configure set aws_secret_access_key "dummy"
    aws configure set region "eu-central-1"
    aws configure set output "table"
}


task() {
    echo -e "\n\n
###############
    Assigment Output
###############
    "
    echo -e "\e[1;34mCreating a queue named 'playment' and pushing messages using 'generator.py'\e[0m"
    if ! python ${SCRIPT_DIR}/generator.py
    then
        echo -e "\e[1;31mERROR!! Failed executing generator.py ..\e[0m]"
        exit 1
    fi
    sleep 10
    echo -e "\n\nRunning assgnment steps below:\n\n"
    
    echo -e "\e[1;34m\$ playment -h\e[0m"
    if ! playment -h
    then
        echo -e "\e[1;31mERROR!! Failed at help menu ..\e[0m]"
    fi
    sleep 3
    echo -e "\e[1;34m\$ playment consume --count=5\e[0m"
    if ! playment consume --count=5
    then
        echo -e "\e[1;31mERROR!! Failed consuming messages ..\e[0m]"
    fi
    sleep 3
    echo -e "\e[1;34m\$ playment show\e[0m"
    if ! playment show
    then
        echo -e "\e[1;31mERROR!! Failed reading messages from db ..\e[0m]"
    fi
    sleep 3
    echo -e "\e[1;34m\$ playment clear\e[0m"
    if ! playment clear
    then
        echo -e "\e[1;31mERROR!! Failed truncation messages from db ..\e[0m]"
    fi
    
}

checks
setup
task
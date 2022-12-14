# PLAYMENT-CLI

Python command-line tool to consume SQS message, read from database and delete messages from database.


## Installation

Use the package manager [pip](https://pip.pypa.io/en/stable/) to install **playment-cli** locally.

```bash
pip install {PROJECT_ROOT_DIRECTORY}/playment-cli/.
```

## Usage

```bash
#Help menu
$ playment -h

#Consume n message
$ playment consume --count=n
#Example Output:
[
    {
        "Body": "Test message 94",
        "MessageId": "00646f85-c2c3-4754-9443-8884ccc0c2a0"
    }
]


#Show all received messages
$ playment show
#Example Output:
[
    {
        "Body": "Test message 94",
        "MessageId": "00646f85-c2c3-4754-9443-8884ccc0c2a0"
    }
]

#Clear all messages from database
$ playment clear
#Example Output:
Deleted 5 message(s)
```

## Setup/Configure Environment
1. Pull up localstack and dynamodb containers. (docker-compose file has been updated to configrue dynamo-db server). In project root directory:
```
docker-compose up -d
```
> Localstack: http://localhost:4566

> DynamoDB: http://localhost:8000

2. Create a python virtual environment and install **playment-cli** package
```
virtualenv <venv-name>
source <venv-name>/bin/activate
cd {PROJECT_ROOT_DIRECTORY}/playment-cli/
pip install .
```
>**playment-cli** will install awscli and boto3 as part of it's dependency automatically.
3. Configure dummy credentials for aws-cli
```
aws configure set aws_access_key_id "dummy"
aws configure set aws_secret_access_key "dummy"
aws configure set region "eu-central-1"
aws configure set output "table"
```

## run.sh - setup and test cli tool at one click
This script will :
1. **pre-checks**: docker and docker-compose service is running. Exit script if not.
2. Create a SQS queue 'playment' and pushes messages to it
3. **setup environment**: spin-up containers, setup virtual env, install *playment-cli* tool, setup aws-cli dummy creds
4. **run commands**: 
- *playment count --count=5*
- *playment show*
- *playment clear* 
#### Default Values:
- Python virtual env: **utkarsh**
- SQS queue name: **playment**
- Database Table: **playment**

## Challenges while solving the problem
1. It took some time to figure out python commands for dynamodb boto3 client
2. packaging python script as cli tool was a good challange.
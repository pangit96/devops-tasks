"""
    \r
    Playment CLI v1.0.0
    A commnand line interface for consuming, viewing, clearing messages
    Task Link: https://github.com/crowdflux/sre-interview

    Playment Help Menu

    Usage:
        playment consume [--count=<count>]
        playment show
        playment clear

    Options:
        -h, --help     Show this menu
  
"""

import sys, os, boto3, json
from docopt import docopt, DocoptExit
from botocore.exceptions import ClientError
import logging
logger = logging.getLogger('app.logger')

if sys.version_info[0] < 3:
    sys.stderr.write("Python 3 required\n")
    sys.exit(1)

VERSION = '1.0.0'

#SQS queue name
qName = 'playment'

#SQS server address
sqs_endpoint = "http://localhost:4566"

#DynamoDB server address
dynamodb_endpoint = "http://localhost:8000"


def sqs_client(endpoint):
    """
    Create and initialize SQS client
    
    Args:
        Endpoint/Address of SQS server(string)
        
    Returns:
        SQSClient: Instance of SQS client
    """
    try:
        sqs = boto3.client('sqs',endpoint_url=endpoint)
        return sqs
    except Exception as e:
        logger.error("Error while initializing SQS client \n",e)
        exit(1)
        
def dynamodb_client(endpoint):
    """
    Create and initialize DynamoDB client
    
    Args:
        Endpoint/Address of dynamoDB process(string)
        
    Returns:
        DynanoDBClient: Instance of DynamoDB server
    """
    try:
        dynamodb=boto3.resource('dynamodb',endpoint_url=endpoint)
        return dynamodb
    except Exception as e:
        logger.error("Error while initializing DynamoDB client \n",e)
        exit(1)
        
def all_tables():
    """
    Get all tables in a DB
    
    Returns:
        List of string: all tables in a DB
    """
    _list=[]
    for table in list(dynamodb.tables.all()):
        _list.append(table.name)
    return _list

def truncateTable(tableName):
    """
    Delete all items from a table
    
    Args:
        Table name(string)
    
    Returns:
        int: count of deleted number of items from the table
    """
    try:
        table = dynamodb.Table(tableName)

        #get the table keys
        tableKeyNames = [key.get("AttributeName") for key in table.key_schema]

        #Only retrieve the keys for each item in the table (minimize data transfer)
        projectionExpression = ", ".join('#' + key for key in tableKeyNames)
        expressionAttrNames = {'#'+key: key for key in tableKeyNames}

        counter = 0
        page = table.scan(ProjectionExpression=projectionExpression, ExpressionAttributeNames=expressionAttrNames)
        with table.batch_writer() as batch:
            while page["Count"] > 0:
                counter += page["Count"]
                # Delete items in batches
                for itemKeys in page["Items"]:
                    batch.delete_item(Key=itemKeys)
                # Fetch the next page
                if 'LastEvaluatedKey' in page:
                    page = table.scan(
                        ProjectionExpression=projectionExpression, ExpressionAttributeNames=expressionAttrNames,
                        ExclusiveStartKey=page['LastEvaluatedKey'])
                else:
                    break
        return(counter)
    except ClientError as e:
        logger.error("Error while truncating table",e.response['Error']['Code'])

def delMessage(receipt_handle):
    """
    Delete messaege from the SQS queue
    
    Args:
        Receipt Handle of the message context(string)
    
    Retuns:
        boolean: indicating whether the message was deleted or not
    """
    try:
        response=sqs.delete_message(
            QueueUrl=qUrl,
            ReceiptHandle=receipt_handle
        )
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:
            status=True
        else:
            status=False
    except ClientError as e:
        status=False
        logger.error("Error in deleting message",e.response['Error']['Code'])
    return status

def read_db(tableName):
    """
    Read messaege from the SQS queue
    
    Args:
        Table Name(string)
    
    Retuns:
        list of dictionaries
    """
    try:
        table = dynamodb.Table(tableName)
        response = table.scan()
        data = response['Items']
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            data.extend(response['Items'])
        return(data)
    except ClientError as e:
        logger.error("Error while fetching message from DB \n",e.response['Error']['Code'])

def write_db(tableName, msgId, body):
    """
    Read messaege from the SQS queue
    
    Args:
        Table Name, Message Id, Message Body (string)
    
    Retuns:
        int: of status code (200 if successful)
    """
    try:
        if tableName not in all_tables():
            response = dynamodb.create_table (
                TableName = tableName,
                KeySchema = [
                       {
                           'AttributeName': 'MessageId',
                           'KeyType': 'HASH'
                       },
                       {
                           'AttributeName': 'Body',
                           'KeyType': 'RANGE'
                       }
                   ],
                   AttributeDefinitions = [
                       {
                           'AttributeName': 'MessageId',
                           'AttributeType': 'S'
                       },
                       {
                           'AttributeName':'Body',
                           'AttributeType': 'S'
                       }
                    ],
                    ProvisionedThroughput={
                        'ReadCapacityUnits':1,
                        'WriteCapacityUnits':1
                    }

                )
        table=dynamodb.Table(tableName)
        response=table.put_item(
            TableName = tableName,    
            Item={
                    'MessageId':msgId,
                    'Body':body

                }
            )
    except ClientError as e:
        logger.error("Error in saving message to DB",e.response['Error']['Code'])
    
    return response['ResponseMetadata']['HTTPStatusCode']
        
def consume(count):
    """
    Consumer function: read message from sqs queue, write to db, delete message from sqs queue
    
    Args:
        count(int): 
    
    Retuns:
        int: of status code (200 if successful)
    """
    try:
        response = sqs.receive_message(
            QueueUrl=qUrl,
            MaxNumberOfMessages=int(count),
            MessageAttributeNames=['All'],
            VisibilityTimeout=30,
            WaitTimeSeconds=10
        )
        if "Messages" not in response.keys():
            sys.stdout.write("\n\nQueue is empty. No messages found")
            sys.stdout.write("\n\n")
            exit(0)
        message = response['Messages']
        _dict=[]
        for msg in message:
            _dict.append(
                {
                    "MessageId": msg['MessageId'],
                    "Body": msg['Body']
                }
            )
            if write_db(qName, msg['MessageId'], msg['Body']) == 200:
                delMessage(msg['ReceiptHandle'])
            else:
                exit(1)
        sys.stdout.write(json.dumps(_dict,indent=4, sort_keys=True))
        sys.stdout.write("\n\n")
    except ClientError as e:
        logger.error("Error in consuming message",e.response['Error']['Code'])
            
def main():
    args = docopt(__doc__)
    global sqs, dynamodb, qName, qUrl, tableName
    try:
        sqs = sqs_client(sqs_endpoint)
        dynamodb = dynamodb_client(dynamodb_endpoint)
        qUrl = sqs.get_queue_url(QueueName=qName)['QueueUrl']
    except ClientError as e:
        logger.error("Error while connecting to client",e.response['Error']['Code'])
        exit(1)
    
    #by default table name == queue name. You can set your custom table name here
    #table = <db-table-name>
    tableName = qName
    
    if args['--count']:
        consume(args['--count'])
    elif args['show']:
        sys.stdout.write(json.dumps(read_db(tableName),indent=4, sort_keys=True))
        sys.stdout.write("\n\n")
    elif args['clear']:
        counter=truncateTable(tableName)
        sys.stdout.write("Deleted {} message(s)".format(counter))
        sys.stdout.write("\n\n")

if __name__ == '__main__':
    main()

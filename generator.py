import boto3
import random
qName='playment'
sqs = boto3.client('sqs',endpoint_url="http://localhost:4566")
if sqs.create_queue(QueueName=qName):
    print("SQS queue created: ",qName)
count = random.randint(10, 100)
while count > 0 :
    message_body="Test message {}".format(count)
    sqs.send_message(QueueUrl='http://localhost:4566/000000000000/{}'.format(qName),MessageBody=message_body)
    count-=1
print("Message(s) published to queue")


import json
import boto3
import logging
import json

ec2 = boto3.resource('ec2', region_name='ap-southeast-1')

def lambda_handler(event, context):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    instance_name = event.get('instance-name') 
    logger.info("Stop EC2 "+instance_name+" triggered")
    instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']},{'Name': 'tag:Name','Values':[instance_name]}])
    for instance in instances:
        id=instance.id
        ec2.instances.filter(InstanceIds=[id]).stop()
        logger.info("Instance ID is stopped :- "+id)

    return {
        'statusCode': 200,
        'body': 'Lambda executed successfully!'
    }
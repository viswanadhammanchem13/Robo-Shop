#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-05d301070925037f6"
Instances=("Mongo_DB" "Catalouge" "Reddis" "Users" "Cart" "MySQL" "Shipping" "Rabbit_MQ" "Payment" "Dispatch" "Frontend")
ZONE_ID="Z03584735O3LYRT2Q9HU"
DOMAIN_NAME="manchem.site"

for instances in ${Instances[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-05d301070925037f6 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name, Value=$instance}]' --query 'Instances[0].InstanceId' --output text)
    if [ $instances != "Frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address: $IP"
done
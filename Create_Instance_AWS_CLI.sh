#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-03e454532f3f29b07"
Instances=("MongoDB" "Catalouge" "Reddis" "Users" "Cart" "MySQL" "Shipping" "RabbitMQ" "Payment" "Dispatch" "Frontend")
ZONE_ID="Z03584735O3LYRT2Q9HU"
DOMAIN_NAME="manchem.site"

for instances in ${Instances[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-03e454532f3f29b07 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instances}]" --query "Instances[0].InstanceId" --output text)
    if [ $instances != "Frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instances IP address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \  
    --change-batch '
     { 
        "Comment": "Creating or Updating a record set for cognito endpoint", 
        "Changes": 
        [ 
            { 
                "Action": "UPSET", 
                "ResourceRecordSet": 
                { 
                    "Name": "'$instance'"."'$DOMAIN_NAME'", 
                    "Type": "A", 
                    "TTL": 1, 
                    "ResourceRecords": 
                    [ 
                        { 
                            "Value": $IP
                         } 
                    ] 
                } 
            } 
        ] 
    }'
done
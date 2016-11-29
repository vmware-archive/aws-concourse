#!/bin/bash
instances=$(aws ec2 describe-instances --filters Name=vpc-id,Values=vpc-a2dd28c4 --output=json | jq -r '.[] | .[] | .Instances | .[] | .InstanceId')
aws ec2 terminate-instances --instance-ids $instances

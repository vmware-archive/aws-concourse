#!/bin/bash
set -e
mv /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-prepare-get/terraform/c0-aws-base/
cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .

export AWS_ACCESS_KEY_ID=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^id | awk '{print $3}'`
export AWS_SECRET_ACCESS_KEY=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^secret | awk '{print $3}'`
export AWS_DEFAULT_REGION=${TF_VAR_aws_region}
export VPC_ID=`terraform state show aws_vpc.PcfVpc | grep ^id | awk '{print $3}'`

#Clean AWS instances
pip install awscli

instances=$(aws ec2 describe-instances --filters Name=vpc-id,Values=$VPC_ID --output=json | jq -r '.[] | .[] | .Instances | .[] | .InstanceId')
if [[ "X$instances" -ne "X" ]]
then
  echo "instances: $instances will be deleted......"
  aws ec2 terminate-instances --instance-ids $instances
  aws ec2 wait --instance-ids $instances
fi

#Destroy the plan
terraform plan
terraform destroy -force

cd $CWD/pcfawsops-terraform-state-put
touch terraform.tfstate

#!/bin/bash
set -e

mv /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-prepare-get/terraform/c0-aws-base/
cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .

while read -r line
do
  `echo "$line" | awk '{print "export "$1"="$3}'`
done < <(terraform output)

echo $az1

export AWS_ACCESS_KEY_ID=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^id | awk '{print $3}'`
export AWS_SECRET_ACCESS_KEY=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^secret | awk '{print $3}'`
export RDS_PASSWORD=`terraform state show aws_db_instance.pcf_rds | grep ^password | awk '{print $3}'`

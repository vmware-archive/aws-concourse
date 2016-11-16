#!/bin/bash
mv /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)

if [[ -s pcfawsops-terraform-rds-state-get/rds-terraform.tfstate ]]; then
    cp pcfawsops-terraform-rds-state-get/rds-terraform.tfstate $OUTPUT_DIR/rds-terraform.tfstate
else
    touch $OUTPUT_DIR/rds-terraform.tfstate
fi

cd $OUTPUT_DIR

echo "creating temp instance..."
terraform apply

#get public ip of the temp instance
temp_instance_public_ip=$(terraform state show aws_instance.temp_az1 | grep "\bpublic_ip\b" | awk '{print $3}')
echo "temp instance public ip = $temp_instance_public_ip"

if [ -f rds-terraform.tfstate ]; then
    scp -i temp_instance_key.pem -o StrictHostKeyChecking=no rds-terraform.tfstate ubuntu@$temp_instance_public_ip:terraform.tfstate terraform.tfstate
fi

ssh -i temp_instance_key.pem -o StrictHostKeyChecking=no ubuntu@$temp_instance_public_ip 'chmod a+x create_database.sh && ./create_database.sh'

scp -i temp_instance_key.pem -o StrictHostKeyChecking=no ubuntu@$temp_instance_public_ip:terraform.tfstate rds-terraform.tfstate

cd $CWD
cp $OUTPUT_DIR/rds-terraform.tfstate pcfawsops-terraform-rds-state-put/rds-terraform.tfstate


echo "deleting temp instance..."
cd $OUTPUT_DIR
terraform destroy --force

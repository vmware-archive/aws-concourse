#!/bin/bash

createPrivateKey.sh "$PRIVATE_KEY"
chmod 400 bosh.pem

CWD=$(pwd)

cp aws-prepare-get/terraform/c0-aws-base/*.tf aws-prepare-get/ci
cp -r aws-prepare-get/terraform/c0-aws-base/temp_instance aws-prepare-get/ci

RDS_FILE_NAME="rds_input.txt"
if [[ -s pcfawsops-terraform-state-get/terraform.tfstate ]]; then
    cp pcfawsops-terraform-state-get/terraform.tfstate aws-prepare-get/ci/terraform.tfstate
fi

cd aws-prepare-get/ci
terraform apply

cd $CWD
cp aws-prepare-get/ci/terraform.tfstate pcfawsops-terraform-state-put/terraform.tfstate



cd aws-prepare-get/ci
# get db details
db_host=$(terraform state show aws_db_instance.pcf_rds | grep "\bendpoint\b" | awk '{print $3}')
db_user=$(terraform state show aws_db_instance.pcf_rds | grep "\busername\b" | awk '{print $3}')
db_password=$(terraform state show aws_db_instance.pcf_rds | grep "\bpassword\b" | awk '{print $3}')

rds_subnet_id_1=$(terraform state show aws_subnet.PcfVpcRdsSubnet_az1 | grep "\bid\b" | awk '{print $3}')
rds_subnet_id_2=$(terraform state show aws_subnet.PcfVpcRdsSubnet_az2 | grep "\bid\b" | awk '{print $3}')
rds_subnet_id_3=$(terraform state show aws_subnet.PcfVpcRdsSubnet_az3 | grep "\bid\b" | awk '{print $3}')
rds_sg=$(terraform state show aws_security_group.rdsSG | grep "\bid\b" | awk '{print $3}')

temp_instance_sg_id=$(terraform state show aws_security_group.directorSG | grep "\bid\b" | awk '{print $3}')
temp_instance_subnet_id=$(terraform state show aws_subnet.PcfVpcPublicSubnet_az1 | grep "\bid\b" | awk '{print $3}')

# save for later executions
#mkdir $OUTPUT_DIR
cd $CWD
echo "export db_host=$db_host"
echo "export db_user=$db_user"
echo "export rds_subnet_id_1=$rds_subnet_id_1"
echo "export rds_subnet_id_2=$rds_subnet_id_2"
echo "export rds_subnet_id_2=$rds_subnet_id_2"
echo "export temp_instance_sg_id=$temp_instance_sg_id"
echo "export temp_instance_subnet_id=$temp_instance_subnet_id"
echo "export TF_VAR_rds_db_username=$TF_VAR_rds_db_username"
echo "export TF_VAR_environment=$TF_VAR_environment"


echo "export rds_subnet_id_1=$rds_subnet_id_1" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export rds_subnet_id_2=$rds_subnet_id_2" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export rds_subnet_id_2=$rds_subnet_id_2" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export temp_instance_sg_id=$temp_instance_sg_id" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export temp_instance_subnet_id=$temp_instance_subnet_id" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_aws_access_key=$TF_VAR_aws_access_key" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_aws_secret_key=$TF_VAR_aws_secret_key" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_aws_key_name=$TF_VAR_aws_key_name" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_aws_cert_arn=$TF_VAR_aws_cert_arn" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_rds_db_username=$TF_VAR_rds_db_username" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_rds_db_password=$TF_VAR_rds_db_password" >> $OUTPUT_DIR/$RDS_FILE_NAME
echo "export TF_VAR_environment=$TF_VAR_environment" >> $OUTPUT_DIR/$RDS_FILE_NAME


# copy the files required to create temp instance
cd $CWD
cp bosh.pem $OUTPUT_DIR/temp_instance_key.pem
cp aws-prepare-get/ci/variables.tf $OUTPUT_DIR/variables.tf
cp aws-prepare-get/ci/aws.tf $OUTPUT_DIR/aws.tf
cp aws-prepare-get/ci/temp_instance/temp_instance.tf $OUTPUT_DIR/temp_instance.tf
cp aws-prepare-get/ci/temp_instance/create_databases.tf_move $OUTPUT_DIR/create_databases.tf_move
cp aws-prepare-get/ci/temp_instance/create_database.sh $OUTPUT_DIR/create_database.sh
cp aws-prepare-get/ci/temp_instance/terraform $OUTPUT_DIR/terraform


cd $OUTPUT_DIR
sed -i 's/${aws_security_group.directorSG.id}/'"$temp_instance_sg_id"'/g' temp_instance.tf
sed -i 's/${aws_subnet.PcfVpcPublicSubnet_az1.id}/'"$temp_instance_subnet_id"'/g' temp_instance.tf
sed -i 's/${aws_db_instance.pcf_rds.endpoint}/'"$db_host"'/g' create_databases.tf_move
sed -i 's/${aws_db_instance.pcf_rds.username}/'"$db_user"'/g' create_databases.tf_move
sed -i 's/${aws_db_instance.pcf_rds.password}/'"$db_password"'/g' create_databases.tf_move

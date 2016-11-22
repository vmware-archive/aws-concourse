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

cd $CWD
echo "=============================================================================================="
echo "Deploying Director @ https://opsman.$ERT_DOMAIN ..."
echo "=============================================================================================="

# Set JSON Config Template and inster Concourse Parameter Values
json_file_path="aws-prepare-get/json-opsman/${AWS_TEMPLATE}"
json_file_template="${json_file_path}/opsman-template.json"
json_file="${json_file_path}/opsman.json"

cp ${json_file_template} ${json_file}

perl -pi -e "s/{{aws_vpc_id}}/${vpc_id}/g" ${json_file}
perl -pi -e "s/{{aws_sg_id}}/${pcf_security_group}/g" ${json_file}
perl -pi -e "s/{{aws_keypair_name}}/${TF_VAR_aws_key_name}/g" ${json_file}
perl -pi -e "s/{{aws_region}}/${TF_VAR_aws_region}/g" ${json_file}
perl -pi -e "s/{{s3_endpoint}}/${S3_ENDPOINT}/g" ${json_file}
perl -pi -e "s/{{s3_bucket}}/${s3_pcf_bosh}/g" ${json_file}
perl -pi -e "s/{{rds_host}}/${db_host}/g" ${json_file}
perl -pi -e "s/{{rds_user}}/${db_username}/g" ${json_file}
perl -pi -e "s/{{rds_database}}/${db_database}/g" ${json_file}
perl -pi -e "s/{{aws_az1}}/${az1}/g" ${json_file}
perl -pi -e "s/{{aws_az2}}/${az2}/g" ${json_file}
perl -pi -e "s/{{aws_az3}}/${az3}/g" ${json_file}
perl -pi -e "s/{{deployment_subnet_1}}/${ert_subnet_id_az1}/g" ${json_file}
perl -pi -e "s/{{deployment_subnet_2}}/${ert_subnet_id_az2}/g" ${json_file}
perl -pi -e "s/{{deployment_subnet_3}}/${ert_subnet_id_az3}/g" ${json_file}
perl -pi -e "s/{{services_subnet_1}}/${services_subnet_id_az1}/g" ${json_file}
perl -pi -e "s/{{services_subnet_2}}/${services_subnet_id_az2}/g" ${json_file}
perl -pi -e "s/{{services_subnet_3}}/${services_subnet_id_az3}/g" ${json_file}
perl -pi -e "s/{{ip_prefix}}/${IP_PREFIX}/g" ${json_file}

cat ${json_file}

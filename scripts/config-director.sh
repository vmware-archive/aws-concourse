#!/bin/bash
set -ex

mv /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-concourse/terraform/
cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .

while read -r line
do
  `echo "$line" | awk '{print "export "$1"="$3}'`
done < <(terraform output)

export AWS_ACCESS_KEY_ID=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^id | awk '{print $3}'`
export AWS_SECRET_ACCESS_KEY=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^secret | awk '{print $3}'`
export RDS_PASSWORD=`terraform state show aws_db_instance.pcf_rds | grep ^password | awk '{print $3}'`

cd $CWD

export S3_ESCAPED=${S3_ENDPOINT//\//\\/}


sudo cp tool-om/om-linux /usr/local/bin
sudo chmod 755 /usr/local/bin/om-linux

IAAS_CONFIGURATION=$(cat <<-EOF
{
"access_key_id": "${AWS_ACCESS_KEY_ID}",
"secret_access_key": "${AWS_SECRET_ACCESS_KEY}",
"vpc_id": "${vpc_id}",
"security_group": "${pcf_security_group}",
"key_pair_name": "${AWS_KEY_NAME}",
"ssh_private_key": "$PEM",
"region": "${AWS_REGION}",
"encrypted": false
}
EOF
)

NETWORK_CONFIGURATION=$(cat <<-EOF
{
  "icmp_checks_enabled": false,
  "networks": [
      {
      "name": "deployment",
      "subnets": [
        {
          "iaas_identifier": "${ert_subnet_id_az1}",
          "cidr": "${ert_subnet_cidr_az1}",
          "reserved_ip_ranges": "${ert_subnet_reserved_ranges_z1}",
          "dns": "${dns}",
          "gateway": "${ert_subnet_gw_az1}",
          "availability_zones": [  "${az1}"  ]
        },
        {
          "iaas_identifier": "${ert_subnet_id_az2}",
          "cidr": "${ert_subnet_cidr_az2}",
          "reserved_ip_ranges": "${ert_subnet_reserved_ranges_z2}",
          "dns": "${dns}",
          "gateway": "${ert_subnet_gw_az2}",
          "availability_zones": [  "${az2}"  ]
        },
        {
          "iaas_identifier": "${ert_subnet_id_az3}",
          "cidr": "${ert_subnet_cidr_az3}",
          "reserved_ip_ranges": "${ert_subnet_reserved_ranges_z3}",
          "dns": "${dns}",
          "gateway": "${ert_subnet_gw_az3}",
          "availability_zones": [  "${az3}"  ]
        }
      ]
    },
    {
      "name": "infrastructure",
      "subnets": [
        {
          "iaas_identifier": "${infra_subnet_id_az1}",
          "cidr": "${infra_subnet_cidr_az1}",
          "reserved_ip_ranges": "${infra_subnet_reserved_ranges_z1}",
          "dns": "${dns}",
          "gateway": "${infra_subnet_gw_az1}",
          "availability_zones": [   "${az1}"   ]
        }
      ]
    },
    {
      "name": "services",
      "subnets": [
        {
          "iaas_identifier": "${services_subnet_id_az1}",
          "cidr": "${services_subnet_cidr_az1}",
          "reserved_ip_ranges": "${services_subnet_reserved_ranges_z1}",
          "dns": "${dns}",
          "gateway": "${services_subnet_gw_az1}",
          "availability_zones": [   "${az1}"   ]
        },
        {
          "iaas_identifier": "${services_subnet_id_az2}",
          "cidr": "${services_subnet_cidr_az2}",
          "reserved_ip_ranges": "${services_subnet_reserved_ranges_z2}",
          "dns": "${dns}",
          "gateway": "${services_subnet_gw_az2}",
          "availability_zones": [   "${az2}"   ]
        },
        {
          "iaas_identifier": "${services_subnet_id_az3}",
          "cidr": "${services_subnet_cidr_az3}",
          "reserved_ip_ranges": "${services_subnet_reserved_ranges_z3}",
          "dns": "${dns}",
          "gateway": "${services_subnet_gw_az3}",
          "availability_zones": [   "${az3}"   ]
        }
      ]
    }
  ]
}
EOF
)


NETWORK_ASSIGNMENT=$(cat <<-EOF
{
  "singleton_availability_zone": "${az1}",
  "network": "infrastructure"
}
EOF
)

echo "=============================================================================================="
echo "Configuring Director Infrastructure @ https://opsman.$ERT_DOMAIN ..."
echo "=============================================================================================="

om-linux -t https://opsman.$ERT_DOMAIN -u "$OPSMAN_USER" -p "$OPSMAN_PASSWORD" -k configure-bosh -i "$IAAS_CONFIGURATION"

echo "=============================================================================================="
echo "Configuring Director Networks @ https://opsman.$ERT_DOMAIN ..."
echo "=============================================================================================="

om-linux -t https://opsman.$ERT_DOMAIN -u "$OPSMAN_USER" -p "$OPSMAN_PASSWORD" -k configure-bosh -n "$NETWORK_CONFIGURATION"

echo "=============================================================================================="
echo "Configuring Director Network Assignments @ https://opsman.$ERT_DOMAIN ..."
echo "=============================================================================================="

om-linux -t https://opsman.$ERT_DOMAIN -u "$OPSMAN_USER" -p "$OPSMAN_PASSWORD" -k configure-bosh -na "$NETWORK_ASSIGNMENT"

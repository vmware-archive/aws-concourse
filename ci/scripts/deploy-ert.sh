#!/bin/bash
set -ex

sudo cp tool-om/om-linux /usr/local/bin
sudo chmod 755 /usr/local/bin/om-linux

mv /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-prepare-get/terraform/c0-aws-base/
cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .

while read -r line
do
  `echo "$line" | awk '{print "export "$1"="$3}'`
done < <(terraform output)

export AWS_ACCESS_KEY_ID=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^id | awk '{print $3}'`
export AWS_SECRET_ACCESS_KEY=`terraform state show aws_iam_access_key.pcf_iam_user_access_key | grep ^secret | awk '{print $3}'`
export RDS_PASSWORD=`terraform state show aws_db_instance.pcf_rds | grep ^password | awk '{print $3}'`

cd $CWD
# Set JSON Config Template and inster Concourse Parameter Values
json_file_path="aws-prepare-get/json-opsman/${AWS_TEMPLATE}"
json_file_template="${json_file_path}/ert-template.json"
json_file="${json_file_path}/ert.json"

cp ${json_file_template} ${json_file}

# Test if the ssl cert var from concourse is set to 'genrate'.  If so, script will gen a self signed, otherwise will assume its a cert
if [[ ${ERT_SSL_CERT} == "generate" ]]; then
  echo "=============================================================================================="
  echo "Generating Self Signed Certs for sys.${ERT_DOMAIN} & cfapps.${ERT_DOMAIN} ..."
  echo "=============================================================================================="
  aws-prepare-get/scripts/ssl/gen_ssl_certs.sh "sys.${ERT_DOMAIN}" "apps.${ERT_DOMAIN}"
  ERT_SSL_CERT=$(cat sys.${ERT_DOMAIN}.crt)
  ERT_SSL_KEY=$(cat sys.${ERT_DOMAIN}.key)
fi

my_pcf_ert_ssl_cert=$(echo ${ERT_SSL_CERT} | sed 's/\s\+/\\\\r\\\\n/g' | sed 's/\\\\r\\\\nCERTIFICATE/ CERTIFICATE/g')
my_pcf_ert_ssl_key=$(echo ${ERT_SSL_KEY} | sed 's/\s\+/\\\\r\\\\n/g' | sed 's/\\\\r\\\\nRSA\\\\r\\\\nPRIVATE\\\\r\\\\nKEY/ RSA PRIVATE KEY/g')

export S3_ESCAPED=${S3_ENDPOINT//\//\\/}

perl -pi -e "s|{{pcf_ert_ssl_cert}}|${my_pcf_ert_ssl_cert}|g" ${json_file}
perl -pi -e "s|{{pcf_ert_ssl_key}}|${my_pcf_ert_ssl_key}|g" ${json_file}
perl -pi -e "s/{{pcf_ert_domain}}/${ERT_DOMAIN}/g" ${json_file}
perl -pi -e "s/{{aws_zone_1}}/${az1}/g" ${json_file}
perl -pi -e "s/{{aws_zone_2}}/${az2}/g" ${json_file}
perl -pi -e "s/{{aws_zone_3}}/${az3}/g" ${json_file}
perl -pi -e "s/{{rds_host}}/${db_host}/g" ${json_file}
perl -pi -e "s/{{rds_user}}/${db_username}/g" ${json_file}
perl -pi -e "s/{{rds_password}}/${RDS_PASSWORD}/g" ${json_file}
perl -pi -e "s/{{pcf_ert_domain}}/${ERT_DOMAIN}/g" ${json_file}
perl -pi -e "s/{{pcf_environment}}/${environment}/g" ${json_file}
perl -pi -e "s/{{aws_access_key}}/${AWS_ACCESS_KEY_ID}/g" ${json_file}
perl -pi -e "s/{{aws_secret_key}}/${AWS_SECRET_ACCESS_KEY}/g" ${json_file}
perl -pi -e "s/{{aws_region}}/${region}/g" ${json_file}
perl -pi -e "s/{{s3_endpoint}}/${S3_ESCAPED}/g" ${json_file}
perl -pi -e "s/{{syslog_host}}/${SYSLOG_HOST}/g" ${json_file}

if [[ ! -f ${json_file} ]]; then
  echo "Error: cant find file=[${json_file}]"
  exit 1
fi

function fn_om_linux_curl {

    local curl_method=${1}
    local curl_path=${2}
    local curl_data=${3}

     curl_cmd="om-linux --target https://opsman.$ERT_DOMAIN -k \
            --username \"$OPSMAN_USER\" \
            --password \"$OPSMAN_PASSWORD\"  \
            curl \
            --request ${curl_method} \
            --path ${curl_path}"

    if [[ ! -z ${curl_data} ]]; then
       curl_cmd="${curl_cmd} \
            --data '${curl_data}'"
    fi

    echo ${curl_cmd} > /tmp/rqst_cmd.log
    exec_out=$(((eval $curl_cmd | tee /tmp/rqst_stdout.log) 3>&1 1>&2 2>&3 | tee /tmp/rqst_stderr.log) &>/dev/null)

    if [[ $(cat /tmp/rqst_stderr.log | grep "Status:" | awk '{print$2}') != "200" ]]; then
      echo "Error Call Failed ...."
      echo $(cat /tmp/rqst_stderr.log)
      exit 1
    else
      echo $(cat /tmp/rqst_stdout.log)
    fi
}



echo "=============================================================================================="
echo "Deploying ERT @ https://opsman.$ERT_DOMAIN ..."
echo "=============================================================================================="
# Get cf Product Guid
guid_cf=$(fn_om_linux_curl "GET" "/api/v0/staged/products" \
            | jq '.[] | select(.type == "cf") | .guid' | tr -d '"' | grep "cf-.*")

echo "=============================================================================================="
echo "Found ERT Deployment with guid of ${guid_cf}"
echo "=============================================================================================="

# Set Networks & AZs
echo "=============================================================================================="
echo "Setting Availability Zones & Networks for: ${guid_cf}"
echo "=============================================================================================="

json_net_and_az=$(cat ${json_file} | jq .networks_and_azs)
fn_om_linux_curl "PUT" "/api/v0/staged/products/${guid_cf}/networks_and_azs" "${json_net_and_az}"

# Set ERT Properties
echo "=============================================================================================="
echo "Setting Properties for: ${guid_cf}"
echo "=============================================================================================="

json_properties=$(cat ${json_file} | jq .properties)
fn_om_linux_curl "PUT" "/api/v0/staged/products/${guid_cf}/properties" "${json_properties}"

# Set Resource Configs
echo "=============================================================================================="
echo "Setting Resource Job Properties for: ${guid_cf}"
echo "=============================================================================================="
json_jobs_configs=$(cat ${json_file} | jq .jobs )
json_job_guids=$(fn_om_linux_curl "GET" "/api/v0/staged/products/${guid_cf}/jobs" | jq .)

for job in $(echo ${json_jobs_configs} | jq . | jq 'keys' | jq .[] | tr -d '"'); do

 json_job_guid_cmd="echo \${json_job_guids} | jq '.jobs[] | select(.name == \"${job}\") | .guid' | tr -d '\"'"
 json_job_guid=$(eval ${json_job_guid_cmd})
 json_job_config_cmd="echo \${json_jobs_configs} | jq '.[\"${job}\"]' "
 json_job_config=$(eval ${json_job_config_cmd})
 echo "---------------------------------------------------------------------------------------------"
 echo "Setting ${json_job_guid} with --data=${json_job_config}..."
 fn_om_linux_curl "PUT" "/api/v0/staged/products/${guid_cf}/jobs/${json_job_guid}/resource_config" "${json_job_config}"

done


# Apply Changes in Opsman
echo "=============================================================================================="
echo "Applying OpsMan Changes to Deploy: ${guid_cf}"
echo "=============================================================================================="
om-linux --target https://opsman.$ERT_DOMAIN -k \
       --username "$OPSMAN_USER" \
       --password "$OPSMAN_PASSWORD" \
  apply-changes

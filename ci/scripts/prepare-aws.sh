#!/bin/bash
set -ex
cp /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-prepare-get/terraform/c0-aws-base/

# Either Generate a certificate or load a customer based certificate. Look at load_balancers.tf
if [[ ${ert_ssl_cert} == "generate" ]]; then
  echo "=============================================================================================="
  echo "Generating Self Signed Certs for sys.${pcf_ert_domain} & cfapps.${pcf_ert_domain} ..."
  echo "=============================================================================================="
  $CWD/ert-concourse/scripts/ssl/gen_ssl_certs.sh "sys.${pcf_ert_domain}" "cfapps.${pcf_ert_domain}"
  cp sys.${pcf_ert_domain}.crt cert.pem
  cp sys.${pcf_ert_domain}.key cert.key
else
  echo ${ert_ssl_cert} > cert.pem
  echo ${ert_ssl_key} > cert.key
fi

if [[ $(cat $CWD/pcfawsops-terraform-state-get/terraform.tfstate | wc -l) -gt 0 ]]; then
  cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .
fi
terraform plan
terraform apply
cp terraform.tfstate $CWD/pcfawsops-terraform-state-put/terraform.tfstate

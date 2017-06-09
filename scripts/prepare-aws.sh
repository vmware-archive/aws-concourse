#!/bin/bash
set -ex
cp /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-concourse/terraform/

if [[ ${OPSMAN_ALLOW_ACCESS} == true ]]; then
  cp overrides/security_group_opsman_allow_override.tf .
fi

terraform plan

set +e
terraform apply
ret_code=$?

cp terraform.tfstate $CWD/pcfawsops-terraform-state-put/terraform.tfstate
exit $ret_code

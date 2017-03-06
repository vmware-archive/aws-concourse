#!/bin/bash
set -ex
cp /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-concourse/terraform/c0-aws-base/

if [[ $(cat $CWD/pcfawsops-terraform-state-get/terraform.tfstate | wc -l) -gt 0 ]]; then
  cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .
fi
terraform plan

set +e
terraform apply
ret_code=$?

cp terraform.tfstate $CWD/pcfawsops-terraform-state-put/terraform.tfstate
exit $ret_code

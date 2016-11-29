#!/bin/bash
set -ex
mv /opt/terraform/terraform /usr/local/bin
CWD=$(pwd)
cd aws-prepare-get/terraform/c0-aws-base/

if [[ $(cat $CWD/pcfawsops-terraform-state-get/terraform.tfstate | wc -l) gt 0 ]]; then
  cp $CWD/pcfawsops-terraform-state-get/terraform.tfstate .
fi
terraform plan
terraform apply
cp terraform.tfstate $CWD/pcfawsops-terraform-state-put/terraform.tfstate

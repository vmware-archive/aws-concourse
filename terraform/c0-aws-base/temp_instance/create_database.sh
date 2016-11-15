#!/bin/bash

#sudo apt-get update
#sudo apt-get install -y unzip
#wget https://releases.hashicorp.com/terraform/0.7.9/terraform_0.7.9_linux_amd64.zip
#unzip terraform_0.7.9_linux_amd64.zip
# if terraform.tfstate file is empty remove the file
if [[ ! -s terraform.tfstate ]]; then
    echo "Removing the terraform.tfstate..."
    rm terraform.tfstate    
fi
chmod a+x terraform
sudo ln terraform /usr/local/bin/terraform

source rds_input.txt

terraform apply


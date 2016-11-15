variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_name" {}
variable "aws_cert_arn" {}
variable "rds_db_username" {}
variable "rds_db_password" {}
variable "environment" {}
variable "client" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-1 = "ami-52c5e145" # pcf opsman 1.8.10
    }
}

variable "amis_nat" {
    description = "NAT AMIs by region"
    default = {
        us-east-1 = "ami-303b1458",
        us-west-2 = "ami-69ae8259"
    }
}
variable "amis_temp_instance" {
    description = "temp instance to run create db scripts"
    default = {
        us-east-1 = "ami-c8580bdf"
    }
}
variable "nat_instance_type" {
    description = "Instance Type for NAT instances"
    default = "t2.medium"
}
variable "temp_instance_type" {
    description = "Instance Type for Temp instances"
    default = "t2.medium"
}

variable "db_instance_type" {
    description = "Instance Type for RDS instance"
    default = "db.m3.large"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}
/*
  Availability Zone 1
*/
variable "az1" {
    description = "EC2 Availability zone for the region 1"
    default = "us-east-1a"
}
# public subnet
variable "public_subnet_cidr_az1" {
    description = "CIDR for the Public Subnet 1"
    default = "10.0.0.0/24"
}
# ERT subnet
variable "ert_subnet_cidr_az1" {
    description = "CIDR for the Private Subnet 1"
    default = "10.0.16.0/20"
}
# RDS subnet
variable "rds_subnet_cidr_az1" {
    description = "CIDR for the RDS Subnet 1"
    default = "10.0.3.0/24"
}
# Services subnet
variable "services_subnet_cidr_az1" {
    description = "CIDR for the Services Subnet 1"
    default = "10.0.64.0/20"
}

variable "nat_ip_az1" {
    default = "10.0.0.6"
}

/*
  Availability Zone 2
*/

variable "az2" {
    description = "EC2 Availability zone for the region 2"
    default = "us-east-1b"
}
variable "public_subnet_cidr_az2" {
    description = "CIDR for the Public Subnet 2"
    default = "10.0.1.0/24"
}
variable "ert_subnet_cidr_az2" {
    description = "CIDR for the Private Subnet 2"
    default = "10.0.32.0/20"
}
# RDS subnet
variable "rds_subnet_cidr_az2" {
    description = "CIDR for the RDS Subnet 2"
    default = "10.0.4.0/24"
}
# Services subnet
variable "services_subnet_cidr_az2" {
    description = "CIDR for the Services Subnet 2"
    default = "10.0.80.0/20"
}

variable "nat_ip_az2" {
    default = "10.0.1.6"
}

/*
  Availability Zone 3
*/

variable "az3" {
    description = "EC2 Availability zone for the region 3"
    default = "us-east-1c"
}
variable "public_subnet_cidr_az3" {
    description = "CIDR for the Public Subnet 3"
    default = "10.0.2.0/24"
}
variable "ert_subnet_cidr_az3" {
    description = "CIDR for the Private Subnet 3"
    default = "10.0.48.0/20"
}
# RDS subnet
variable "rds_subnet_cidr_az3" {
    description = "CIDR for the RDS Subnet 3"
    default = "10.0.5.0/24"
}
# Services subnet
variable "services_subnet_cidr_az3" {
    description = "CIDR for the Services Subnet 3"
    default = "10.0.96.0/20"
}

variable "nat_ip_az3" {
    default = "10.0.2.6"
}

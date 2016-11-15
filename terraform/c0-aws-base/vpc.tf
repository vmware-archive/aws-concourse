/*
  For Region
*/
resource "aws_vpc" "PcfVpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.environment}-terraform-pcf-vpc"
    }
}
resource "aws_internet_gateway" "internetGw" {
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-internet-gateway"
    }
}



/*
  For First availability zone
*/

# 1. Create Public Subnet
resource "aws_subnet" "PcfVpcPublicSubnet_az1" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.public_subnet_cidr_az1}"
    availability_zone = "${var.az1}"

    tags {
        Name = "${var.environment}-PcfVpc Public Subnet AZ1"
    }
}

# 2. Create Private Subnets
# 2.1 ERT
resource "aws_subnet" "PcfVpcErtSubnet_az1" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.ert_subnet_cidr_az1}"
    availability_zone = "${var.az1}"

    tags {
        Name = "${var.environment}-PcfVpc Ert Subnet AZ1"
    }
}
# 2.2 RDS
resource "aws_subnet" "PcfVpcRdsSubnet_az1" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.rds_subnet_cidr_az1}"
    availability_zone = "${var.az1}"

    tags {
        Name = "${var.environment}-PcfVpc Rds Subnet AZ1"
    }
}
# 2.3 Services
resource "aws_subnet" "PcfVpcServicesSubnet_az1" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.services_subnet_cidr_az1}"
    availability_zone = "${var.az1}"

    tags {
        Name = "${var.environment}-PcfVpc Services Subnet AZ1"
    }
}

# 3. NAT instance setup
# 3.1 Security Group for NAT
resource "aws_security_group" "nat_instance_sg" {
    name = "${var.environment}-nat_instance_sg"
    description = "${var.environment} NAT Instance Security Group"
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.environment}-NAT intance security group"
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# 3.2 Create NAT instance
resource "aws_instance" "nat_az1" {
    ami = "${var.amis_nat["${var.aws_region}"]}"
    availability_zone = "${var.az1}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az1.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip_az1}"

    tags {
        Name = "${var.environment}-Nat Instance az1"
    }
}

/*
  For Second availability zone. There will not be modification to main routing table as it was already
  done while setting up
*/


resource "aws_subnet" "PcfVpcPublicSubnet_az2" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.public_subnet_cidr_az2}"
    availability_zone = "${var.az2}"

    tags {
        Name = "${var.environment}-PcfVpc Public Subnet AZ2"
    }
}
resource "aws_subnet" "PcfVpcErtSubnet_az2" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.ert_subnet_cidr_az2}"
    availability_zone = "${var.az2}"

    tags {
        Name = "${var.environment}-PcfVpc Ert Subnet AZ2"
    }
}
resource "aws_subnet" "PcfVpcRdsSubnet_az2" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.rds_subnet_cidr_az2}"
    availability_zone = "${var.az2}"

    tags {
        Name = "${var.environment}-PcfVpc Rds Subnet AZ2"
    }
}
resource "aws_subnet" "PcfVpcServicesSubnet_az2" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.services_subnet_cidr_az2}"
    availability_zone = "${var.az2}"

    tags {
        Name = "${var.environment}-PcfVpc Services Subnet AZ2"
    }
}

resource "aws_instance" "nat_az2" {
    ami = "${var.amis_nat["${var.aws_region}"]}"
    availability_zone = "${var.az2}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az2.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip_az2}"

    tags {
        Name = "${var.environment}-Nat Instance az2"
    }
}


/*
  For Third availability zone.  There will not be modification to main routing table as it was already
  done while setting up

*/
resource "aws_subnet" "PcfVpcPublicSubnet_az3" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.public_subnet_cidr_az3}"
    availability_zone = "${var.az3}"

    tags {
        Name = "${var.environment}-PcfVpc Public Subnet AZ3"
    }
}
resource "aws_subnet" "PcfVpcErtSubnet_az3" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.ert_subnet_cidr_az3}"
    availability_zone = "${var.az3}"

    tags {
        Name = "${var.environment}-PcfVpc Ert Subnet AZ3"
    }
}

resource "aws_subnet" "PcfVpcRdsSubnet_az3" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.rds_subnet_cidr_az3}"
    availability_zone = "${var.az3}"

    tags {
        Name = "${var.environment}-PcfVpc Rds Subnet AZ3"
    }
}
resource "aws_subnet" "PcfVpcServicesSubnet_az3" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    cidr_block = "${var.services_subnet_cidr_az3}"
    availability_zone = "${var.az3}"

    tags {
        Name = "${var.environment}-PcfVpc Services Subnet AZ3"
    }
}

# NAT Insance
resource "aws_instance" "nat_az3" {
    ami = "${var.amis_nat["${var.aws_region}"]}"
    availability_zone = "${var.az3}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az3.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip_az3}"

    tags {
        Name = "${var.environment}-Nat Instance az3"
    }
}

# Routing Tables for all subnets

resource "aws_route_table" "PublicSubnetRouteTable" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internetGw.id}"
    }

    tags {
        Name = "${var.environment}-Public Subnet Route Table"
    }
}

# subnet associations for public subnet
resource "aws_route_table_association" "a_az1" {
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az1.id}"
    route_table_id = "${aws_route_table.PublicSubnetRouteTable.id}"
}
resource "aws_route_table_association" "a_az2" {
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az2.id}"
    route_table_id = "${aws_route_table.PublicSubnetRouteTable.id}"
}
resource "aws_route_table_association" "a_az3" {
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az3.id}"
    route_table_id = "${aws_route_table.PublicSubnetRouteTable.id}"
}

# AZ1 Routing table
resource "aws_route_table" "PrivateSubnetRouteTable_az1" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat_az1.id}"
    }

    tags {
        Name = "${var.environment}-Private Subnet Route Table AZ1"
    }
}
resource "aws_route_table_association" "b_az1" {
    subnet_id = "${aws_subnet.PcfVpcErtSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}
resource "aws_route_table_association" "c_az1" {
    subnet_id = "${aws_subnet.PcfVpcRdsSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}
resource "aws_route_table_association" "d_az1" {
    subnet_id = "${aws_subnet.PcfVpcServicesSubnet_az1.id}"
    route_table_id = "${aws_route_table.PrivateSubnetRouteTable_az1.id}"
}

# AZ2 Routing table
resource "aws_route_table" "SubnetRouteTable_az2" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat_az2.id}"
    }

    tags {
        Name = "${var.environment}-Private Subnet Route Table AZ2"
    }
}

resource "aws_route_table_association" "x_az2" {
    subnet_id = "${aws_subnet.PcfVpcErtSubnet_az2.id}"
    route_table_id = "${aws_route_table.SubnetRouteTable_az2.id}"
}
resource "aws_route_table_association" "y_az2" {
    subnet_id = "${aws_subnet.PcfVpcRdsSubnet_az2.id}"
    route_table_id = "${aws_route_table.SubnetRouteTable_az2.id}"
}
resource "aws_route_table_association" "z_az2" {
    subnet_id = "${aws_subnet.PcfVpcServicesSubnet_az2.id}"
    route_table_id = "${aws_route_table.SubnetRouteTable_az2.id}"
}

# AZ3 Routing table
resource "aws_route_table" "SubnetRouteTable_az3" {
    vpc_id = "${aws_vpc.PcfVpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat_az3.id}"
    }

    tags {
        Name = "${var.environment}-Private Subnet Route Table AZ3"
    }
}
resource "aws_route_table_association" "x_az3" {
    subnet_id = "${aws_subnet.PcfVpcErtSubnet_az3.id}"
    route_table_id = "${aws_route_table.SubnetRouteTable_az3.id}"
}
resource "aws_route_table_association" "y_az3" {
    subnet_id = "${aws_subnet.PcfVpcRdsSubnet_az3.id}"
    route_table_id = "${aws_route_table.SubnetRouteTable_az3.id}"
}
resource "aws_route_table_association" "z_az3" {
    subnet_id = "${aws_subnet.PcfVpcServicesSubnet_az3.id}"
    route_table_id = "${aws_route_table.SubnetRouteTable_az3.id}"
}

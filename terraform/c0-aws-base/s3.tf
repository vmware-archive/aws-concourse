resource "random_id" "bucket_id" {
    keepers = {
        hex = "test"
    }
    byte_length = 8
}
resource "aws_s3_bucket" "pcf-bosh" {
    bucket = "${var.environment}-pcf-bosh-${random_id.bucket_id.hex}"
    acl = "private"

    tags {
        Name = "${var.environment}-pcf-bosh"
        Environment = "${var.environment}-${var.environment}"
    }
}

resource "aws_s3_bucket" "pcf-buildpacks" {
    bucket = "${var.environment}-pcf-buildpacks-${random_id.bucket_id.hex}"
    acl = "private"

    tags {
        Name = "${var.environment}-pcf-buildpacks"
        Environment = "${var.environment}"
    }
}

resource "aws_s3_bucket" "pcf-droplets" {
    bucket = "${var.environment}-pcf-droplets-${random_id.bucket_id.hex}"
    acl = "private"

    tags {
        Name = "${var.environment}-pcf-droplets"
        Environment = "${var.environment}"
    }
}

resource "aws_s3_bucket" "pcf-packages" {
    bucket = "${var.environment}-pcf-packages-${random_id.bucket_id.hex}"
    acl = "private"

    tags {
        Name = "${var.environment}-pcf-packages"
        Environment = "${var.environment}"
    }
}

resource "aws_s3_bucket" "pcf-resources" {
    bucket = "${var.environment}-pcf-resources-${random_id.bucket_id.hex}"
    acl = "private"

    tags {
        Name = "${var.environment}-pcf-resources"
        Environment = "${var.environment}"
    }
}

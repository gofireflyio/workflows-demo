provider "aws" {
  region = var.aws_region
}

# VPC and Networking
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "main" {
  ami           = var.instance_ami
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids     = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-instance"
  }
}

# EBS Volume
resource "aws_ebs_volume" "data" {
  availability_zone = "${var.aws_region}a"
  size             = 1
  type             = "gp3"

  tags = {
    Name = "${var.project_name}-ebs"
  }
}

resource "aws_volume_attachment" "data_att" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.main.id
}

# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-data-${random_string.suffix.result}"
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "data" {
  depends_on = [aws_s3_bucket_public_access_block.data]

  bucket = aws_s3_bucket.data.id
  acl    = "private"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
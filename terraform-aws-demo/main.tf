provider "aws" {
  region = var.aws_region
}

# VPC and Networking
data "aws_vpc" "main" {
  default = true
}

# Security Group
resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.main.id

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

resource "aws_subnet" "main" {
  vpc_id            = data.aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "main-instance"

  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  subnet_id              = aws_subnet.main.id

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
  instance_id = module.ec2_instance.id
}

# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-data-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
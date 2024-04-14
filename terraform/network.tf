# Define region
provider "aws" {
	region = "us-east-2"
}

# Create VPC
resource "aws_vpc" "xz_lab_vpc" {
	cidr_block = var.vpc_cidr
	enable_dns_hostnames = true
	enable_dns_support = true
	
	tags = {
		Name = "XZ Lab VPC"
		ManagedBy = "Terraform"
	}
}

# Create public subnet
resource "aws_subnet" "xz_lab_public_subnet" {
	vpc_id = aws_vpc.xz_lab_vpc.id
	cidr_block = var.public_subnet_cidr

	tags = {
		Name = "XZ Lab Public Subnet"
		ManagedBy = "Terraform"
	}
}

# Create private subnet
resource "aws_subnet" "xz_lab_private_subnet" {
	vpc_id = aws_vpc.xz_lab_vpc.id
	cidr_block = var.private_subnet_cidr

	tags = {
		Name = "XZ Lab Private Subnet"
		ManagedBy = "Terraform"
	}
}

# Create gateway
resource "aws_internet_gateway" "xz_lab_gateway" {
	vpc_id = aws_vpc.xz_lab_vpc.id

	tags = {
		Name = "XZ Lab Gateway"
		ManagedBy = "Terraform"
	}
}

# Modify route table
resource "aws_default_route_table" "xz_lab_default_route_table" {
	default_route_table_id = aws_vpc.xz_lab_vpc.default_route_table_id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.xz_lab_gateway.id
	}

	tags = {
		Name = "XZ Lab Route Table"
		ManagedBy = "Terraform"
	}
}

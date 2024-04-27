#variable "controller_ami" {
#	type = string
#	description = "ami for controller instance"
#}

variable "jumpbox_ami" {
	type = string
	description = "ami for jumpbox instance"
}

variable "jumpbox_user" {
	type = string
	description = "default initialization user on jumpbox AMI"
}

variable "target_ami" {
	type = string
	description = "ami for target instances"
}

variable "target_user" {
	type = string
	description = "default initialization user on target AMI"
}

variable "vpc_cidr" {
	type = string
	description = "VPC CIDR block for lab network"
}

variable "public_subnet_cidr" {
	type = string
	description = "VPC CIDR block for public subnet"
}

variable "private_subnet_cidr" {
	type = string
	description = "VPC CIDR block for private subnet"
}

variable "num_targets" {
	type = number
	description = "number of target machines to deploy"
}

variable "allowed_IPs" {
	type = list(string)
	description = "IPs allowed to access instances in the public subnet"
}

#variable "controller_key_name" {
#	type = string
#	description = "key that the controller is deployed with"
#}

variable "jumpbox_key_name" {
	type = string
	description = "key that the jumpbox was deployed with (provided to lab participants)"
}

variable "target_key_name" {
	type = string
	description = "key that targets were deployed with (used for troubleshooting)"
}

variable "key_path" {
	type = string
	description = "local path to private keys for deployed hosts"
}


#variable "ansible_expression" {
#	type = string
#	description = "string that will be appended to private addresses in inventory file for ansible playbook execution"
#}

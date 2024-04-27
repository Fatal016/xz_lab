resource "aws_security_group" "xz_lab_public_subnet" {
	vpc_id = aws_vpc.xz_lab_vpc.id
	name = "xz_lab_public_subnet"
	
	#####################
	### Inbound Rules ###
	#####################

	# Allow SSH from external network
	ingress {
		from_port 	= 22
		to_port 	= 22
		protocol 	= "tcp"
		cidr_blocks = var.allowed_IPs
	}

	# Allow SSH from within public subnet
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = [var.public_subnet_cidr]
	}


	# Allow ICMP from anywhere
	ingress {
		from_port 	= -1
		to_port 	= -1
		protocol 	= "icmp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	# TEMP allow all SSH
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	######################
	### Outbound Rules ###
	######################
	
	# Allow all outbound traffic IPv4
	egress {
		from_port	= 0
		to_port 	= 0
		protocol 	= "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "xz_lab_public_subnet"
		ManagedBy = "Terraform"
	}
}

resource "aws_security_group" "xz_lab_private_subnet" {
	vpc_id = aws_vpc.xz_lab_vpc.id
	name = "xz_lab_private_subnet"

	#####################
	### Inbound Rules ###
	#####################

	# Allow SSH from Ansible Controller
	#ingress {
	#	from_port = 22
	#	to_port = 22
	#	protocol = "tcp"
	#	cidr_blocks = ["${aws_instance.controller.private_ip}/32"]
	#}

	# Allow all traffic from jumpbox
	# Intentionally leaving all ports accessible to allow for other methods of persistence
	ingress {
		from_port 	= 0
		to_port 	= 0
		protocol 	= "-1"
		cidr_blocks = ["${aws_instance.jumpbox.private_ip}/32"]
	}

	# Allow traffic from other targets
	ingress {
		from_port 	= 0
		to_port 	= 0
		protocol 	= "-1"
		cidr_blocks = [var.private_subnet_cidr]
	}


	# Allow all traffic from all hosts (for testing)
	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}



	######################
	### Outbound Rules ###
	######################

	# Allow all outbound traffic IPv4
	egress {
		from_port 	= 0
		to_port 	= 0
		protocol 	= "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "xz_lab_private_subnet"
		ManagedBy = "Terraform"
	}
}

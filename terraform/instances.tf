# User jumpbox
resource "aws_instance" "jumpbox" {
	ami = var.jumpbox_ami
	instance_type = "t3a.micro"

	# Putting jumpbox in public subnet -> defined as allowed_IPs in terraform.tvars
	subnet_id = aws_subnet.xz_lab_public_subnet.id

	# Rules defined in `security.tf`
	vpc_security_group_ids = [aws_security_group.xz_lab_public_subnet.id]

	key_name = var.jumpbox_key_name

	root_block_device = {
		volume_type = "gp2"
		# Will probably need to make this dynamic depending on number of containers/users
		volume_size = 50 
	}


	tags = {
		Name = "jumpbox"
		ManagedBy = "Terraform"
	}
}

resource "aws_instance" "target" {
	ami = var.target_ami
	instance_type = "t3a.micro"

	# Putting targets in private subnet
	subnet_id = aws_subnet.xz_lab_private_subnet.id
	
	vpc_security_group_ids = [aws_security_group.xz_lab_private_subnet.id]

	key_name = var.target_key_name

	associate_public_ip_address = false
	
	# Building copies of target host
	count = var.num_targets

	tags = {
		Name = "target_${count.index}"
		ManagedBy = "Terraform"
	}
}

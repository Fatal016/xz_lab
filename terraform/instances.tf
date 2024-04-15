# Administration and Ansible Controller
#resource "aws_instance" "controller" {
#	ami = var.controller_ami
#	instance_type = "t3a.micro"
#
#	# Putting controller in public subnet
#	subnet_id = aws_subnet.xz_lab_public_subnet.id
#	
#	# Attaching port groups
#	vpc_security_group_ids = [aws_security_group.xz_lab_public_subnet.id]
#
#	key_name = var.controller_key_name
#
#	associate_public_ip_address = true
#
#	tags = {
#		Name = "XZ Lab Ansible Controller"
#		ManagedBy = "Terraform"
#	}
#}

# User jumpbox
resource "aws_instance" "jumpbox" {
	ami = var.jumpbox_ami
	instance_type = "t3a.micro"

	# Putting jumpbox in public subnet
	subnet_id = aws_subnet.xz_lab_public_subnet.id

	# Attaching port groups
	vpc_security_group_ids = [aws_security_group.xz_lab_public_subnet.id]

	key_name = var.jumpbox_key_name

	associate_public_ip_address = true

	tags = {
		Name = "XZ Lab Jumpbox"
		ManagedBy = "Terraform"
	}
}

resource "aws_instance" "target" {
	ami = var.target_ami
	instance_type = "t3a.micro"

	# Putting targets in private subnet
	subnet_id = aws_subnet.xz_lab_private_subnet.id
	
	# Assigning security group to restrict remote access to jumpbox
	vpc_security_group_ids = [aws_security_group.xz_lab_private_subnet.id]

	key_name = var.target_key_name

	# Don't want vulnerable hosts accessible from the open internet
	associate_public_ip_address = false
	
	# Building copies of target host
	count = var.num_targets

	tags = {
		Name = "XZ Lab Target #${count.index}"
		ManagedBy = "Terraform"
	}
}

resource "local_file" "private_addresses" {
	filename = "../ansible/inventory.ini"
	content = "${join("", formatlist("%s %s\n", aws_instance.target.*.private_ip, var.ansible_expression))}"
	file_permission = "0660"
}

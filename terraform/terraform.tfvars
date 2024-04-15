controller_ami 	= "ami-0b8b44ec9a8f90422" # Ubuntu Server 22.04 LTS
jumpbox_ami 	= "ami-0b8b44ec9a8f90422" # Ubuntu Server 22.04 LTS
target_ami 		= "ami-0b8b44ec9a8f90422" # Ubuntu Server 22.04 LTS

vpc_cidr = "10.110.0.0/16"
public_subnet_cidr = "10.110.1.0/24"
private_subnet_cidr = "10.110.2.0/24"


num_targets = 3 # Number of hosts to target


allowed_IPs = 	[
				"130.111.218.0/23",	# Barrows
				"68.234.239.248/32" # The Reserve	
				]

controller_key_name = "xz_lab_controller"

ansible_expression = "ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/xz_lab_target"

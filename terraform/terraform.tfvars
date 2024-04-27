jumpbox_ami 	= "ami-0b8b44ec9a8f90422" # Ubuntu Server 22.04 LTS
jumpbox_user	= "ubuntu"

target_ami 		= "ami-0b8b44ec9a8f90422" # Ubuntu Server 22.04 LTS
target_user		= "ubuntu"

vpc_cidr = "10.110.0.0/16"
public_subnet_cidr = "10.110.1.0/24"
private_subnet_cidr = "10.110.2.0/24"


num_targets = 3 # Number of hosts to target


allowed_IPs = 	[
				"130.111.218.0/23",		# Barrows
				"68.234.239.248/32", 	# The Reserve	
				"0.0.0.0/0" 			# Allowing all for testing
				]

jumpbox_key_name = "xz_lab_jumpbox"
target_key_name = "xz_lab_target"

key_path = "~/.ssh/"

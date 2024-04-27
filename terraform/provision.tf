terraform {
  required_providers {
    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
  }
}

resource "local_file" "host_inventory" {
	filename = "../ansible/inventory.ini"
	content = <<-EOT
				[jumpbox]
				${aws_instance.jumpbox.public_ip}
				
				[target]
				${join("\n",aws_instance.target.*.private_ip)}
				
				[jumpbox:vars]
				ansible_user=${var.jumpbox_user}
				ansible_ssh_private_key_file=${var.key_path}${var.jumpbox_key_name}
				
				[target:vars]
				ansible_user=${var.target_user}
				ansible_ssh_private_key_file=${var.key_path}${var.target_key_name}
				EOT
	file_permission = "0660"
}

#resource "ansible_group" "target" {
#
#	name = "target"
#	children = [join(",",aws_instance.target.*.private_ip)]
#}

#resource "ansible_playbook" "test_connectivity" {
#	depends_on = [aws_instance.target]	
#
#	playbook = "../ansible/ping.yml"
#	name = "localhost"
#	groups = ["target"]
#	replayable = true
#
#	extra_vars = {
#		ansible_user="ubuntu"
#		ansible_ssh_private_key="~/.ssh/xz_lab_target.pem"
#		ssh-common-args="-o ProxyJump=${aws_instance.jumpbox.public_ip}"
#	}
#}

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

resource "local_file" "ssh_config" {
	depends_on = [ansible_playbook.ansible_controller]

	filename = "../admin/ssh_config"
	content = <<-EOT
				Host jumpbox
					HostName ${aws_instance.jumpbox.public_dns}
					IdentityFile ${var.key_path}${var.jumpbox_key_name}
				EOT
}

resource "ansible_group" "target" {
	depends_on = [local_file.ssh_config]

	name = "target"
	children = [join(",",aws_instance.target.*.private_ip)]
}

resource "ansible_playbook" "ansible_controller" {
	playbook = "../ansible/controller/controller.yml"
	name = "localhost"
	replayable = true
	verbosity = 2

	extra_vars = {
		num_users=length(aws_instance.target)
		root_dir="${path.cwd}/.."
	}
}





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

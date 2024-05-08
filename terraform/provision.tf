terraform {
  required_providers {
    ansible = {
      version = "~> 1.2.0"
      source  = "ansible/ansible"
    }
  }
}

# Generate Ansible inventory file for use by playbooks
resource "local_file" "host_inventory" {
	filename = "../ansible/inventory.ini"

	content = <<-EOT
		[jumpbox]
		${aws_instance.jumpbox.public_ip}
				
		[target]
		${join("\n",aws_instance.target.*.private_ip)}
				
		[jumpbox:vars]
		ansible_user=${var.jumpbox_user}
		
		[target:vars]
		ansible_user=${var.target_user}
		ansible_ssh_common_args="-o StrictHostKeyChecking=no ProxyJump=${var.jumpbox_user}@${aws_instance.jumpbox.public_ip} -F ${path.cwd}/../admin/ssh_config"
	EOT
	
	file_permission = "0660"
}

# Generate local ssh config file for accessing targets
# This is necessary as both the jumpbox and targets require ssh key access
resource "local_file" "ssh_config" {
	depends_on = [ansible_playbook.ansible_controller]

	filename = "../admin/ssh_config"

	content = join("\n", [
        
		# SSH config entry for jumpbox instance
        format(
            "#${aws_instance.jumpbox.tags["Name"]}\nHost %s\n\tHostName %s\n\tIdentityFile %s%s\n",
            aws_instance.jumpbox.public_ip,
            aws_instance.jumpbox.public_ip,
            var.key_path,
            var.jumpbox_key_name
        ),

        # SSH config entries for target instances
        join("\n", [
			for instance in aws_instance.target :
        	format(
            	"#${instance.tags["Name"]}\nHost %s\n\tHostName %s\n\tIdentityFile %s%s\n",
            	instance.private_ip,
            	instance.private_ip,
				var.key_path,
            	var.target_key_name
        	)
		])
    ])
}

#resource "ansible_host" "controller" {
#	name = "controller"
#	groups = [""]
#}

#resource "ansible_host" "localhost" {
#	name = "localhost"
#	
#	variables = {
#		ansible_ssh_common_args = "-i ~/.ssh/id_rsa"
#	}
#}




resource "ansible_host" "jumpbox" {
	depends_on = [local_file.ssh_config]

	name = "${aws_instance.jumpbox.public_ip}"
	groups = ["jumpbox"]

	variables = {
		ansible_user = "ubuntu"
	}
}


resource "ansible_group" "targets" {
	depends_on = [local_file.ssh_config]

	name = "targets"
	children = [join(",",aws_instance.target.*.private_ip)]

	variables = {
		ansible_user = "ubuntu"
		ansible_ssh_common_args = "-o StrictHostKeyChecking=no ProxyJump=ubuntu@3.140.193.44 -F /home/couriersix/Git/xz_lab/terraform/../admin/ssh_config"
	}
}

resource "ansible_host" "test_target" {
	depends_on = [local_file.ssh_config]

    name = "${element(aws_instance.target.*.private_ip, 1)}"

    variables = {
        ansible_user = "ubuntu"
        ansible_ssh_common_args = "-o StrictHostKeyChecking=no ProxyJump=ubuntu@${aws_instance.jumpbox.public_ip} -F /home/couriersix/Git/xz_lab/admin/ssh_config"
    }
}

resource "ansible_playbook" "ansible_controller" {
    playbook = "../ansible/controller/controller.yml"
	name = "localhost"
	replayable = true
	verbosity = 2

	extra_vars = {
		num_users=length(aws_instance.target)
		admin_path=abspath("../admin")
	}
}

resource "ansible_playbook" "ansible_target" {

	playbook = "../ansible/target/target.yml"
	name = "test_target"
#	groups = ["targets"]
	replayable = true
	verbosity = 6
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

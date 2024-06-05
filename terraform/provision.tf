terraform {
  required_providers {
    ansible = {
      version = "~> 1.3.0"
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
		ansible_ssh_common_args="-o ProxyJump=${var.jumpbox_user}@${aws_instance.jumpbox.public_ip}"
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

resource "ansible_playbook" "ansible_controller" {
    playbook = "../ansible/controller/controller.yml"
	name = "localhost"
	replayable = true

	extra_vars = {
		num_users=length(aws_instance.target)
		admin_path=abspath("../admin")
	}
}

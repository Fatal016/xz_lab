resource "null_resource" "destroy" {
	provisioner "local-exec" {
		when = destroy
		command = "rm -rf ${abspath("../admin")}"
	}
}

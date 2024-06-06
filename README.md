# XZ Utils Vulnerability Exploitation Lab

This lab was built to give people the opportunity to have a ready-to-go lab deployment for exploiting the xz vulnerability as outlined in CVE-2024-3094 which you can learn more about [here](https://www.uptycs.com/blog/xz-utils-backdoor-vulnerability-cve-2024-3094). The steps to run and administrate this lab are outlined below. 

If you have any questions or run into any issues/bugs with this lab, please feel free to reach out to [my email](016erw@gmail.com) and I'll be sure to get them resolved.

## Prerequisites
**Disclaimer:** These steps are for deploying the lab on Linux, though Windows/Mac should be relatively similar

* Ensure that you have the following packages installed
  * [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
  * [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
  * [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#pip-install) (must be 2.16 or above)
  * [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (I'll make a more in-depth guide for this in the future)
    
    * For now, this [Reddit thread](https://www.reddit.com/r/aws/comments/13ly023/help_me_get_credentials_for_cli/) outlines some of your options for authentication, SSO is preferred, but generating local credentials in IAM also isn't that big of a deal for something like this
    * Once installed, `aws sts get-caller-identity` should print out your account information. If it doesn't then try again

## Deploying the Lab
1. Either through the cli if you're really cool or through the AWS GUI, navigate to EC2 and generate key-pairs with the following names:
   
   * xz_lab_jumpbox
   * xz_lab_target
 
   **Note**: Make sure that you put these keys into the proper region and that your AWS CLI is also set to the same region because keys are region-locked

2. Pull down this repo with `git clone git@github.com:Fatal016/xz_lab.git`
3. Navigate to xz_lab/terraform and open up the file terraform.tfvars. Here, you will need to configure various parameters for this lab. Each is explained below:
  
   * **jumpbox_ami/target_ami** - While you *can* change this to a non-debian distro, that flexibility is only really half-implemented. All of the ansible is running apt/apt-get, so if you really wanted to do RHEL or something else, you're going to have to change the ansible playbooks yourself until I get around to adding the necessary functionality
   * **jumpbox_user/target_user** - Needs to be in accordance with the AMI (OS image)
   * **vpc_cidr** - The subnet that the lab environment is going to operate in. You only really have to change this if you have existing infra. that interferes with this IP space
   * **public_subnet_cidr/private_subnet_cidr** - Same deal as for vpc_cidr
   * **num_targets** - The number of hosts you want available to be attacked. This is entirely up to you
   * **allowed_IPs** - Subnet ranges that are allowed to touch the lab environment. Make sure to include your necessary addresses here. If you're just doing this by yourself, put your public address + /32
   * **jumpbox_key_name/target_key_name** - Make sure these coincide with the names of the keys you created in AWS
   * **key_path** - Path to where you're locally storing the keys generated in AWS
   * **admin_path** - Set this to be in the root directory of the xz_lab repo you cloned. This will be configurable in the future
4. Once all of your settings are correct, run `terraform apply` and then `yes` if there are no errors
5. After Terraform is done deploying, navigate to ../ansible and run the following:
   * ansible-playbook jumpbox/jumpbox.yml -i inventory.ini
   * ansible-playbook target/target.yml -i inventory.ini
6. Now the lab environment should be all set up! Distribute the lab and admin guides to the respective participants (xz_lab/guides to be created). The steps to run through the lab are included there. Otherwise, if you're just doing the lab yourself, refer to both of the guides to make sure that you're able to run through everything smoothly.

## Taking Down the Lab
Simply navigate to xz_lab/terraform and run a `terraform destroy`.

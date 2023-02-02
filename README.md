# Deploy WordPress Environment

<p align='center'>
    <img src="./images/devops_wordpress_project_overview.png" width=800, height=450>
</p>

## Project Goal:

Using configuration management tools like Terraform and Ansible, automate setting up wordpress and all of its dependencies. This exercise demonstrates the benefits of DevOps tools by standardizing the installation procedure, making complex manual tasks reproducible and less prone to error, speeding up overall development time.

Required Tools:

1.  AWS (EC2)
2.  Terraform
3.  Ansible

## Steps:

1.  [Install pre-requisite software on host machine](#Install-pre-requisite-software-on-host-machine)
2.  [Set up Terraform to provision target server](#Set-up-Terraform-to-provision-target-server)
3.  [Set up Ansible to install WordPress dependencies on target server](#Set-up-Ansible-to-install-WordPress-dependencies-on-target-server)
4.  [Execute scripts to perform installation](#Execute-scripts-to-perform-installation)
5.  [Validate installation of Wordpress](#Validate-installation-of-Wordpress)

### Install pre-requisite software on host machine

1.  Installing Terraform from APT repository

```bash
# Update the system & install software-properties-common
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# Download signing key
wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Verify key fingerprint - should match E8A0 32E0 94D8 EB4E A189 D270 DA41 8C88 A321 9F7B
gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint

# Add official Hashicorp repository to system
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update package
sudo apt update

# Install terraform from the new repository
sudo apt-get install terraform

# Verify Installation
terraform -version
```

2.  Installing Ansible

```bash
sudo apt-get update
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get install ansible
ansible --version  # Check installation
```

### Set up Terraform to provision target WordPress server

1.  Create project repository on host machine

```bash
mkdir wordpress_server && cd wordpress_server
```

2.  Create an aws access key and secret key
    1.  Navigate to <https://us-east-1.console.aws.amazon.com/iamv2/home>
    2.  On the navigation menu, choose **Users**.
    3.  Choose your IAM user name, or create a IAM user.
        <p align='center'>
            <img src="./images/choose_iam_user_or_create.png" width=700, height=180>
        </p>
    4.  Open the **security credentials** tab, and then choose **create access key**.
        <p align='center'>
            <img src="./images/retrieve_access_key.png" width=700, height=400>
        </p>
    5.  Choose show to see the new access key
    6.  Download the key pair, choose Download `.csv` file
3.  Create an pem key
    1.  Navigate to <https://us-east-1.console.aws.amazon.com/ec2/home>
    2.  On the navigation menu, under **Network & Security**, click on **Key Pairs**
    3.  Create an AWS keypair
        <p align='center'>
            <img src="./images/create_key_pair.png" width=700, height=200>
        </p>
    4.  Download the keypair and add it to the host machine
    5.  Change the permissions to read only `chmod 400 key_pair_file.pem`
4.  Get an AMI ID for Ubuntu
    1.  Navigate to <https://us-east-1.console.aws.amazon.com/ec2/home>
    2.  On the navigation menu, under **Images**, click on **AMI Catalog**
    3.  Click on search and type Ubuntu
    4.  Copy the ami_id of the desired configuration
        <p align='center'>
            <img src="./images/select_ami_id.png" width=750, height=300>
        </p>
5.  Get an VPC ID
    1.  Navigate to <https://us-east-1.console.aws.amazon.com/vpc/home>
    2.  Click on VPCs and copy the VPC ID string
6.  Create the terraform `variables.tf` file

    ```terraform
    variable "aws_access_key" {
        description = "Access key to AWS console"
        type = string
        default = "<insert here>"
    }

    variable "aws_secret_key" {
        description = "Secret key to AWS console"
        type = string
        default = "<insert here>"
    }

    variable "instance_type" {
        description = "Name of instance type"
        type = string
        default = "t2.micro"
    }

    variable "availability_zone" {
        description = "Availability zone for the EC2 server"
        type = string
        default = "us-east-1"
    }

    variable "number_of_instances" {
        description = "number of instances to be created"
        type = number
        default = 1
    }

    variable "ami_id" {
        type = string
        default = "<insert here>"
    }

    variable "vpc_id" {
        type string
        default = "<insert here>"
    }

    variable "key_name" {
        description = "Name of pem key"
        type = string
        default = "<insert here>"
    }

    variable "private_key_path" {
        type = string
        default = "<file_name>.pem"
    }

    variable "ssh_user" {
        type = string
        default = "ubuntu"
    }
    ```

7.  Create the `security.tf` file

    ```terraform
    resource "aws_security_group" "demoaccess" {
        name = "demoaccess"
        vpc_id = var.vpc_id
        egress = [
            {
              cidr_blocks      = ["0.0.0.0/0",]
              description      = "Allow all outbound traffic"
              from_port        = 0
              ipv6_cidr_blocks = []
              prefix_list_ids  = []
              protocol         = "-1"
              security_groups  = []
              self             = false
              to_port          = 0
            }
        ]
        ingress = [
            {
              cidr_blocks      = ["0.0.0.0/0",]
              description      = "Port 22 - allow SSH"
              from_port        = 22
              ipv6_cidr_blocks = []
              prefix_list_ids  = []
              protocol         = "tcp"
              security_groups  = []
              self             = false
              to_port          = 22
            },
            {
              cidr_blocks      = ["0.0.0.0/0",]
              description      = "Port 80 - allow HTTP"
              from_port        = 80
              ipv6_cidr_blocks = []
              prefix_list_ids  = []
              protocol         = "tcp"
              security_groups  = []
              self             = false
              to_port          = 80
            },
        ]
    }
    ```

8.  Create the `main.tf` file

    ```terraform
    provider "aws" {
        region = var.ava
        access_key = var.aws_access_key
        secret_key = var.aws_secret_key
    }

    resource "aws_instance" "web" {
        ami = var.ami_id
        count = var.number_of_instances
        instance_type = var.instance_type
        associate_public_ip_address = true
        vpc_security_group_ids = [aws_security_group.demoaccess.id]
        key_name = var.key_name

        tags = {
            Name = "Wordpress Server"
        }

        connection {
            type = "ssh"
            host = self.public_ip
            user = var.ssh_user
            private_key = file(var.private_key_path)
            timeout = "4m"
        }


    }
    ```

9.  Create the `outputs.tf` file
    ```terraform
    output "instance_public_ip" {
        description = "Public IP of target EC2 instance for Wordpress Server"
        value = aws_instance.web.public_ip
    }
    ```

### Set up Ansible to install WordPress dependencies on target server

### Execute scripts to perform installation

### Validate installation of Wordpress

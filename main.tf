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

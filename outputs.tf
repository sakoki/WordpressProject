output "instance_public_ip" {
    description = "Public IP of target EC2 instance for Wordpress Server"
    value = aws_instance.web.public_ip
}

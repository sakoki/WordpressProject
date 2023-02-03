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
    type = string
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

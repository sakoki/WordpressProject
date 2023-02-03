resource "aws_security_group" "demoaccess" {
    name = "demoaccess"
    vpc_id = var.vpc_id
    tags = {
        name = "allow ssh, http, https"
    }
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
        {
          cidr_blocks      = ["0.0.0.0/0",]
          description      = "Port 443 - allow HTTPS"
          from_port        = 443
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "tcp"
          security_groups  = []
          self             = false
          to_port          = 443
        }
    ]
}

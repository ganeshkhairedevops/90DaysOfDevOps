resource "aws_security_group" "sg" {
    name = var.sg_name
    vpc_id = var.vpc_id
    tags = var.tags
    description = "Security group with dynamic allowed ports"

    dynamic "ingress" {
      for_each = var.ingress_ports
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow incoming traffic on port ${ingress.value}"
      }
    }

    egress = {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    tags = merge({
        Name = var.sg_name
    }, var.tags)
  
}
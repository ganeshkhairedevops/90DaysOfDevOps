variable "vpc_id" {
    description = "The ID of the VPC to which the security group belongs."
    type = string
}

variable "sg_name" {
    description = "security group name."
    type = string
}

variable "ingress_ports" {
    description = "List of allow incoming traffic."
    type = list(number)
    default = [22, 80, 443]
}

variable "tags" {
    description = "Additional tags for the security group."
    type = map(string)
    default = {}
}
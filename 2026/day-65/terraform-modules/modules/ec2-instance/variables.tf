variable "ami_id" {
    description = "The ID of the Amazon Machine Image (AMI) to use for the instance."
    type = string
}
variable "instance_type" {
    description = "instance type to use for the instance."
    type = string
    default = "t3.micro"
}
variable "subnet_id" {
    description = "Subnet ID."
    type = string
}
variable "security_group_ids" {
    description = "List of security group IDs to associate with the instance."
    type = list(string)
}
variable "instance_name" {
    description = "Name of the instance."
    type = string
}
variable "tags" {
    description = "Additional tags."
    type = map(string)
    default = {}
}
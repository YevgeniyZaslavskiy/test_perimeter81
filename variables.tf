//variable "cidr_vpc" {
//  description = "CIDR block for the VPC"
//  default = "172.31.80.0/20"
//}
//variable "cidr_subnet" {
//  description = "CIDR block for the subnet"
//  default = "172.31.80.0/20"
//}
//variable "availability_zone" {
//  description = "availability zone to create subnet"
//  default = "us-east-1a"
//}
variable "public_key_path" {
  description = "Public key path"
  default = "~/.ssh/id_rsa_test"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default = "ami-04505e74c0741db8d"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default = "Test"
}

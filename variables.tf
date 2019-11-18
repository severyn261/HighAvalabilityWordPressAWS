variable "vpc-id" {
  description = "description"
  default = "VPC-ID"
}
variable "igw-id" {
  description = "description"
  default = "Internet gateway id"
}

variable "VPC-CIDR" {
  description = "New VPC CIDR block"
  default = "10.212.0.0/16"
}
variable "tag-Name-name" {
  description = "Name"
  default = "Name"
}
variable "tag-Name-value" {
  description = "Value"
  default = "task_one"
}
variable "tag-Owner-name" {
  description = "Owner"
  default = "Owner"
}
variable "tag-Owner-value" {
  description = "value"
  default = "email or nickname"
}
variable "AZ1" {
  description = "Az1"
  default = "eu-central-1a"
}
variable "AZ2" {
  description = "Az2"
  default = "eu-central-1b"
}
variable "ami" {
  description = "description"
  default = "AMI instance"
}
variable "instance_type" {
  description = "description"
  default = "t2.medium"
}
variable "key_acc" {
  description = "description"
  default = "access key name"
}
variable "region" {
  description = "description"
  default = "eu-central-1"
}
variable "availability_zones" {
  description = "List of availability zones, use AWS CLI to find your "
  default     = "eu-central-1a,eu-central-1b"
}
variable "dbuser" {
  description = "description"
  default = "database user"
}
variable "dbpass" {
  description = "description"
  default = "data base pass"
}

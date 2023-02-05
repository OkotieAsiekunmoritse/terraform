#variable for profile
variable "profile" {
  default = "myprofile"
}


variable "ssh_key" {
  default = "project_key"
}


#variable for route53
variable "domain_name" {
  default    = "asiekunmoritse.me"
  type        = string
  description = "Domain name"
}
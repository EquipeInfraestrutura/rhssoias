variable "region" {
  default     = "us-east-2"
  type        = string
  description = "Region of the VPC"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-0b97505ab47807e80"
  description = "vpc_keycloak"
}

variable "ami_id" {
  type        = string
  default     = "ami-0f08721e5f546d256"
  description = "ami_id"
}

variable "sg_keycloak" {
  type        = list
  default     = ["sg-0f6a68253d49d98ae"]
  description = "sg_keycloak"
}

variable "sg_alb_keycloak" {
  type        = list
  default     = ["sg-005fa7b45237fe42e"]
  description = "sg_alb_keycloak"
}

variable "subnets" {
  default     = ["subnet-0611591f91df44592", "subnet-009db7304cb9c1747", "subnet-00aed7fc8d3513a07"]
  type        = list
  description = "List of subnets"
}

variable "instance" {
  type        = string
  default     = "t3a.micro"
  description = "instance_keycloak"
}

variable "keyname" {
  type        = string
  default     = "Key_Keycloak"
  description = "instance_keycloak"
}

variable "availability_zones" {
  default     = ["us-east-2a", "us-east-2b","us-east-2c"]
  type        = list
  description = "List of availability zones"
}

variable "certificate" {
  type        = string
  default     = "arn:aws:acm:us-east-2:906520347629:certificate/12094694-07df-47d7-bc2d-35c1ddec160c"
  description = "certificate_keycloak"
}

variable "hostedzone" {
  type        = string
  default     = "Z3FOUYFF65CU70"
  description = "hosted zone"
}

variable "health_check" {
   type = map(string)
   default = {
      "protocol" = "https"
      "timeout"  = "10"
      "interval" = "30"
      "path"     = "/"
      "port"     = "8443"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "5"
    }
}
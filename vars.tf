variable "AWS_REGION" {
  default = "ap-southeast-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}

variable "AMIS" {
  type = map(string)
  default = {
    ap-southeast-1 = "ami-0df7a207adb9748c7"
  }
}

variable "RDS_PASSWORD" {
   default = "ChangeIt"
}

variable "guacamole_version" {
   default = "1.5.2"
}
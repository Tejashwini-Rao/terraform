data "aws_ami" "ami" {

  most_recent      = true
  name_regex       = "ansible AMI"
  owners           = ["self"]

}
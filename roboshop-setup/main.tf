resource "aws_instance" "app" {
  count= length(var.components)
  ami           = data.aws_ami.ami.image_id
  instance_type = "t3.micro"
  iam_instance_profile = "SecretManager_Role_for_RoboShop_Nodes"
  vpc_security_group_ids = ["sg-08a62f5105434364a"]

  tags = {
    Name ="${var.components["${count.index}"]}-dev"
  }
}

resource "aws_route53_record" "route" {
  count= length(var.components)
  zone_id = Z005396725ZQYS9AQ6CZX
  name    ="${var.components["${count.index}"]}-dev"
  type    = "A"
  ttl     = 300
  records = [aws_instance.app.*.private_ip[count.index]]
}

resource "null_resource" "ansible-apply" {
  depends_on = [aws_route53_record.route]
  triggers = {
    abc=timestamp()
  }
  count= length(var.components)
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "root"
      password = DevOps321
      host     = [aws_instance.app.*.public_ip[count.index]]
    }


    inline = [

      "ansible-pull ,-U  https://github.com/Tejashwini-Rao/roboshop-mutable roboshop.yml -e HOSTS=localhost -e APP_COMPONENT_ROLE=${var.components[{count.index}]}-dev -e ENV=dev"


    ]
  }
}

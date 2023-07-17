resource "aws_instance" "guacamole-app" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.main-private-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.app-sg.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  # user data
  user_data = data.cloudinit_config.cloudinit-app.rendered

  iam_instance_profile = aws_iam_instance_profile.app_ec2_profile.name

  tags = {
    Name = "guacamole-app"
  }

}
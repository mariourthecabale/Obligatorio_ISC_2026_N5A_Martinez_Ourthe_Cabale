data "aws_ami" "al2023_x86" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
resource "aws_instance" "ac1-instance" {
  ami                         = data.aws_ami.al2023_x86.id
  iam_instance_profile        = "LabInstanceProfile"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.ac1-sg.id]
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.ac1-private-subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "ac1-instance"
  }
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("/home/mario/actuacion_2/ac2-terraform/credentials/key.pem")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y httpd git curl",
      "git clone https://github.com/mauricioamendola/chaos-monkey-app.git",
      "sudo mv chaos-monkey-app/website/* /var/www/html/",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",
    ]
  }
}

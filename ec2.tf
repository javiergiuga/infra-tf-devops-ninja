resource "aws_key_pair" "server_key" {
  key_name = "${var.app}_key"
  public_key = file("keys/app-key.pub")
}

resource "aws_instance" "server1" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = data.aws_subnet.az_a.id
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  key_name = aws_key_pair.server_key.key_name
  tags = {
    Name = "${var.app}"
  }
  user_data = "${file("script-al2.sh")}"
}


resource "aws_instance" "server2" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = data.aws_subnet.az_a.id
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  key_name = aws_key_pair.server_key.key_name
  tags = {
    Name = "${var.app}-${var.prod}"
  }
  user_data = "${file("install-docker.sh")}"
}

resource "aws_instance" "server3" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = data.aws_subnet.az_a.id
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  key_name = aws_key_pair.server_key.key_name
  tags = {
    Name = "${var.app}-${var.develop}"
  }
  user_data = "${file("install-docker.sh")}"
}

resource "aws_instance" "server4" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = data.aws_subnet.az_a.id
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  key_name = aws_key_pair.server_key.key_name
  tags = {
    Name = "${var.app}-${var.testing}"
  }
  user_data = "${file("install-docker.sh")}"
}
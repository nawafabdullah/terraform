resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "Nawaf_VPC"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "me-south-1a"
}

resource "aws_route_table" "default" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "main" {
    subnet_id = aws_subnet.main.id
    route_table_id = aws_route_table.default.id
}

resource "aws_network_acl" "allowall" {
    vpc_id = aws_vpc.main.id

    egress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    ingress {
        protocol = "-1"
        rule_no = 200
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}

resource "aws_security_group" "allowall" {
    name = "Nawaf AllowAll"
    description = "Allow all traffic -BAD PRACTICE-"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_eip" "Nawaf-WebServer" {
    instance = aws_instance.Nawaf-WebServer.id 
    vpc = true
    depends_on = [aws_internet_gateway.main]
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
    key_name = "Nawaf_KeyPair"
    public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_instance" "Nawaf-WebServer" {
    ami = data.aws_ami.ubuntu.id
    availability_zone = "me-south-1a"
    instance_type = "t3.2xlarge"
    key_name = aws_key_pair.default.key_name
    vpc_security_group_ids = [aws_security_group.allowall.id]
    subnet_id = aws_subnet.main.id
    tags = {
        Name = "Nawaf_EC2"
    }
}

output "instance_ip" {
    value = aws_eip.Nawaf-WebServer.public_ip
}

output "sshKey" {
    value = tls_private_key.example.public_key_openssh    
}
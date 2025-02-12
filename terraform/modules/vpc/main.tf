resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
  depends_on = [aws_vpc.main ]
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "public subnet ${count.index + 1}"
  }
  depends_on = [aws_vpc.main ]
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private subnet ${count.index + 1}"
  }
  depends_on = [aws_vpc.main]
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.routetable_cidr
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = var.public_route_table_name
  }
  depends_on = [aws_vpc.main ]

}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.routetable_cidr
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  
  tags = {
    Name = var.private_route_table_name
  }
  depends_on = [aws_vpc.main ]
  
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
  depends_on = [ aws_route_table.public_rt, aws_nat_gateway.nat_gateway ]
}


resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
  depends_on = [ aws_route_table.private_rt ]
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.allocation_id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = var.nat_name
  }
  depends_on = [aws_eip.elastic_ip]
}

resource "aws_eip" "elastic_ip" {
  
  domain   = var.eip_domain
}


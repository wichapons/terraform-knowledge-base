resource "aws_vpc" "this" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = merge(var.tags, {
        Name = "${var.project}-${var.environment}-vpc"
    })
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags   = var.tags
}

resource "aws_subnet" "public" {
    for_each = { for index, cidr in var.public_subnet_cidrs : index => cidr }

    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value
    availability_zone       = element(var.azs, each.key)
    map_public_ip_on_launch = true

    tags = merge(var.tags, {
        Name = "${var.project}-${var.environment}-public-${each.key}"
    })
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id
    tags   = var.tags
}

resource "aws_route" "public_igw" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
    for_each       = aws_subnet.public
    subnet_id      = each.value.id
    route_table_id = aws_route_table.public.id
}

# Private subnets, NAT Gateway, and route table setup
locals {
  # Calculate how many NAT gateways we need based on our configuration
  nat_gateway_count = var.create_nat_gateway && length(var.private_subnet_cidrs) > 0 ? (
    var.single_nat_gateway ? 1 : min(length(var.public_subnet_cidrs), length(var.azs))
  ) : 0
}

resource "aws_eip" "nat" {
    count  = local.nat_gateway_count
    domain = "vpc"
    tags = merge(var.tags, {
        Name = "${var.project}-${var.environment}-nat-eip-${count.index}"
    })
}

resource "aws_nat_gateway" "this" {
    count         = local.nat_gateway_count
    allocation_id = aws_eip.nat[count.index].id
    
    # If single NAT gateway, put in first public subnet, otherwise distribute across public subnets
    subnet_id     = values(aws_subnet.public)[count.index].id
    
    tags = merge(var.tags, {
        Name = "${var.project}-${var.environment}-nat-${count.index}"
    })
    
    depends_on = [aws_internet_gateway.this]
}

resource "aws_subnet" "private" {
    for_each = { for index, cidr in var.private_subnet_cidrs : index => cidr }

    vpc_id                  = aws_vpc.this.id
    cidr_block              = each.value
    availability_zone       = element(var.azs, each.key)
    map_public_ip_on_launch = false

    tags = merge(var.tags, {
        Name = "${var.project}-${var.environment}-private-${each.key}"
    })
}

resource "aws_route_table" "private" {
    # If single NAT, create just one route table; otherwise, create one per AZ
    count = length(var.private_subnet_cidrs) > 0 ? (
        var.single_nat_gateway || !var.create_nat_gateway ? 1 : length(var.private_subnet_cidrs)
    ) : 0
    
    vpc_id = aws_vpc.this.id
    
    tags = merge(var.tags, {
        Name = "${var.project}-${var.environment}-private-rt${count.index > 0 ? "-${count.index}" : ""}"
    })
}

resource "aws_route" "private_nat" {
    # Create routes only when NAT Gateway is enabled
    count = var.create_nat_gateway && length(var.private_subnet_cidrs) > 0 ? (
        var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)
    ) : 0
    
    route_table_id         = aws_route_table.private[count.index].id
    destination_cidr_block = "0.0.0.0/0"
    
    # If single NAT, all routes point to the same NAT gateway; otherwise, each route table points to its AZ's NAT
    nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : min(count.index, local.nat_gateway_count - 1)].id
}

resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private
    
    subnet_id = each.value.id
    
    # If single NAT/route table, all subnets use the same route table; otherwise, match subnet index to route table
    route_table_id = var.single_nat_gateway || !var.create_nat_gateway ? aws_route_table.private[0].id :aws_route_table.private[tonumber(each.key) % length(aws_route_table.private)].id
}

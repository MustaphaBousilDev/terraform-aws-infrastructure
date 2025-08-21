#ElasticCache Subnet Group

resource "aws_elasticache_subnet_group" "redis" {
    name = "${var.project_name}-${var.environment}-redis-subnet-group"
    subnet_ids = var.private_subnet_ids
    tags = {
        Name = "${var.project_name}-${var.environment}-redis-subnet-group"
    }
}

#Security Group for redis 
resource "aws_security_group" "redis" {
    name_prefix = "${var.project_name}-${var.environment}-redis-"
    vpc_id = var.vpc_id

    ingress {
        from_port       = 6379
        to_port         = 6379
        protocol        = "tcp"
        //only allows connection to redis from servers that have this application security_group attached
        security_groups = [var.app_security_group_id]
    }

    egress {
        //from all port
        from_port   = 0
        //to all port 
        to_port     = 0
        // protocol=-1 (All Protocol)(TCP, UDP, ICMP)
        protocol    = "-1"
        //Anywhere on the internet
        cidr_blocks = ["0.0.0.0/0"]
    }
}
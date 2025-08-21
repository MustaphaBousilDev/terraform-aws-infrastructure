#ElasticCache Subnet Group

resource "aws_elasticache_subnet_group" "redis" {
    name = "${var.project_name}-${var.environment}-redis-subnet-group"
    subnet_ids = var.private_subnet_ids
    tags = {
        Name = "${var.project_name}-${var.environment}-redis-subnet-group"
    }
}


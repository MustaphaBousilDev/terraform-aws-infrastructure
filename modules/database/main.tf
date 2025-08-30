# Database Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# Security Group for Database
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-${var.environment}-db-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-db-sg"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-${var.environment}-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  db_name                       = var.db_name
  username = var.db_username
   password = var.db_password

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7 # Primary keeps 7 days of backups
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.environment}-db"
  }
}


#RDS read replica for improved read performance
# Read Replica inherits most settings from source DB automatically
# Engine , version , storage encryption, ...
resource "aws_db_instance" "read_replica" {
  identifier = "${var.project_name}-${var.environment}-db-replica"
  #Creates replica of your main database
  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = var.db_instance_class
  #Placement (it is the same as main database)
  vpc_security_group_ids = [aws_security_group.database.id]

  #Read replica settings 
  publicly_accessible = false
  /*
  -->AWS automatically applies minor database updates (like MySQL 8.0.28 → 8.0.32)
  -->Updates happen during maintenance windows (not immediately)
  -->Only minor versions (bug fixes, security patches) - never major versions
  */
  auto_minor_version_upgrade = true

  #Backup Setting (read replicas don't need their own backup) because main database already has backup for 7days
  #read replica is copy not a source of truth (that why dont neet backup)
  # backup costing
  # the main database backup is sufficient for recovery , there is no need for more replica backup

  backup_retention_period = 0
  /*
  -->true = Don't create snapshot when deleting read replica
  --> false = Create final snapshot before deletion
  -> Why do true for read replica
  ----->because: Read replica can be easily recreated from primary
  ----->because: Faster deletion when needed
  ----->Primary database has its own snapshots
  ----->No need for duplicate snapshots
  */
  skip_final_snapshot = true
  /*
  false = Can delete the read replica easily
  true = Must disable protection before deletion
  --> Why false:
  ---->because: Read replicas are meant to be disposable
  ---->because: Easy to delete and recreate for testing
  ---->because: Primary database has deletion_protection
  ---->Replica is not critical infrastructure
  !!!! Your Primary DB should have: true
  */
  deletion_protection = false



  tags = {
    Name    = "${var.project_name}-${var.environment}-db-replica"
    Type    = "read-replica"
    Purpose = "read-performance-optimization"
  }
}



##--------- Config for RDS Proxy -------------##

# IAM Role for RDS Proxy
resource "aws_iam_role" "rds_proxy_role" {
  name = "${var.project_name}-${var.environment}-rds-proxy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-proxy-role"
  }
}

# IAM Policy for RDS Proxy to access Secrets Manager
resource "aws_iam_role_policy" "rds_proxy_policy" {
  name = "${var.project_name}-${var.environment}-rds-proxy-policy"
  role = aws_iam_role.rds_proxy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_db_instance.main.master_user_secret[0].secret_arn]
      }
    ]
  })
}

# RDS Proxy
resource "aws_db_proxy" "main" {
  name          = "${var.project_name}-${var.environment}-rds-proxy"
  engine_family = "MYSQL"
  auth {
    auth_scheme = "SECRETS"
    secret_arn  = aws_db_instance.main.master_user_secret[0].secret_arn
  }
  role_arn            = aws_iam_role.rds_proxy_role.arn
  vpc_subnet_ids      = var.private_subnet_ids
  require_tls         = true # force encrypted connection between application and proxy
  idle_client_timeout = 1800 # 30 minutes
  tags = {
    Name = "${var.project_name}-${var.environment}-rds-proxy"
  }
}

# RDS Proxy Target Group for Primary Database
resource "aws_db_proxy_default_target_group" "main" {
  db_proxy_name = aws_db_proxy.main.name

  connection_pool_config {
    max_connections_percent      = 100 #Use 100% of the proxy's available connection capacity (don't reserve any connections).
    max_idle_connections_percent = 50  #Keep 50% of database connections open even when not actively used (reduces connection setup latency).
    connection_borrow_timeout    = 120 #If all database connections are busy, wait up to 2 minutes for one to become available before failing.
    session_pinning_filters      = ["EXCLUDE_VARIABLE_SETS"]
  }
}

# RDS Proxy Target (Primary Database)
resource "aws_db_proxy_target" "main" {
  db_instance_identifier = aws_db_instance.main.identifier
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
}

# RDS Proxy Target For Read Replica
resource "aws_db_proxy_target" "read_replica" {
  count = var.enable_read_replica_proxy ? 1 : 0

  db_instance_identifier = aws_db_instance.read_replica.identifier
  db_proxy_name          = aws_db_proxy.main.name
  target_group_name      = aws_db_proxy_default_target_group.main.name
}

# Security Group for RDS Proxy
resource "aws_security_group" "rds_proxy" {
  name_prefix = "${var.project_name}-${var.environment}-rds-proxy-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.database.id]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-proxy-sg"
  }
}

# Update existing database security group to allow RDS Proxy
resource "aws_security_group_rule" "database_from_proxy" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_proxy.id
  security_group_id        = aws_security_group.database.id
}
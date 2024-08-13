
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "Maria DB Subnet Group"
  }
}

resource "aws_db_instance" "master" {
  identifier           = "awesome-mariadb-master"
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mariadb"
  engine_version       = "10.11.8"
  instance_class       = "db.t3.micro"
  backup_retention_period = 7
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot  = true
  username             = var.db_username
  password             = var.db_password
  availability_zone    = var.azs[1]
  deletion_protection  = false

  tags = {
    name = "Awesome MariaDB Master"
  }
}

resource "aws_db_instance" "replica" {
  identifier = "awesome-mariadb-replica"
  engine = "mariadb"
  instance_class       = "db.t3.micro"
  # db_subnet_group_name = aws_db_subnet_group.mbb_mariadb_subnet_group.name
  backup_retention_period = 7
  availability_zone    = var.azs[0]
  skip_final_snapshot  = true
  replicate_source_db = aws_db_instance.master.identifier

  tags = {
    name = "Awesome MariaDB Replica"
  }
}
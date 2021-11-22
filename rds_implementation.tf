/*
-- RDS MYSQL
*/

resource "aws_db_instance" "mysql_metabase" {
  identifier             = "mysqldb"
  name                   = "mysql_instance_${local.service_name}"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = "usermetabase"
  password               = "metabase"
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.sec_group_ecs.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  skip_final_snapshot    = true

  tags = {
    Name = "${local.service_name}_data_base"
  }
}

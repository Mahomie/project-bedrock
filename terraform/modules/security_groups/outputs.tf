output "eks_nodes_sg_id" {
  value = aws_security_group.eks_nodes.id
}

output "rds_mysql_sg_id" {
  value = aws_security_group.rds_mysql.id
}

output "rds_postgres_sg_id" {
  value = aws_security_group.rds_postgres.id
}

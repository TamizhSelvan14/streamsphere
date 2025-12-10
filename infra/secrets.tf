resource "aws_secretsmanager_secret" "db" {
  name = "streamsphere-db-secret"
}

resource "aws_secretsmanager_secret_version" "db_version" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "streamsphere"
    password = "changeme123" # never hardcode in code anymore!
    host     = aws_rds_cluster.aurora.endpoint
    port     = 5432
    dbname   = "streamsphere"
  })
}

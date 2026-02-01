# Data Sources para recuperar a senha gerenciada pelo RDS no Secrets Manager
data "aws_secretsmanager_secret" "db_pass" {
  arn = aws_db_instance.default.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "db_pass_val" {
  secret_id = data.aws_secretsmanager_secret.db_pass.id
}

# Configuração do Provider PostgreSQL
# Usa a senha recuperada do Secrets Manager para autenticar
provider "postgresql" {
  host            = aws_db_instance.default.address
  port            = 5432
  database        = "postgres"
  username        = aws_db_instance.default.username
  password        = jsondecode(data.aws_secretsmanager_secret_version.db_pass_val.secret_string)["password"]
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

# Criação dos Bancos de Dados Lógicos
resource "postgresql_database" "databases" {
  for_each = var.create_databases ? var.db_names : []

  name              = each.key
  owner             = "postgresadmin"
  connection_limit  = -1
  allow_connections = true
}

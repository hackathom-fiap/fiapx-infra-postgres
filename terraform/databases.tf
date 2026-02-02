locals {
  # Tenta obter o ARN do segredo do usuário mestre de forma segura. Retorna nulo se não encontrado.
  # Isso evita erros de "Index value required" durante a destruição ou se o segredo não estiver disponível.
  master_user_secret_arn = try(aws_db_instance.default.master_user_secret[0].secret_arn, null)
}

# Data Sources para recuperar a senha gerenciada pelo RDS no Secrets Manager
# A execução desses data sources é condicionada à existência do ARN do segredo.
data "aws_secretsmanager_secret" "db_pass" {
  count = local.master_user_secret_arn != null ? 1 : 0
  arn   = local.master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "db_pass_val" {
  count     = local.master_user_secret_arn != null ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.db_pass[0].id
}

# Configuração do Provider PostgreSQL
# Usa a senha recuperada do Secrets Manager para autenticar.
# A senha será nula se o segredo não for encontrado, impedindo a conexão.
provider "postgresql" {
  host            = aws_db_instance.default.address
  port            = 5432
  database        = "postgres"
  username        = aws_db_instance.default.username
  password        = local.master_user_secret_arn != null ? jsondecode(data.aws_secretsmanager_secret_version.db_pass_val[0].secret_string)["password"] : null
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

# Criação dos Bancos de Dados Lógicos
# A criação só é tentada se a variável 'create_databases' for verdadeira e o segredo existir.
resource "postgresql_database" "databases" {
  for_each = var.create_databases && local.master_user_secret_arn != null ? var.db_names : toset([])

  name              = each.key
  owner             = "postgresadmin"
  connection_limit  = -1
  allow_connections = true
}

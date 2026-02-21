locals {
  # Tenta obter o ARN do segredo do usuário mestre de forma segura. Retorna nulo se não encontrado.
  # Isso evita erros de "Index value required" durante a destruição ou se o segredo não estiver disponível.
  master_user_secret_arn = try(aws_db_instance.default.master_user_secret[0].secret_arn, null)
}

# Data Source para recuperar a versão do segredo gerenciado pelo RDS no Secrets Manager.
# A sua execução é controlada pela variável 'create_databases', que é conhecida no momento do 'plan'.
data "aws_secretsmanager_secret_version" "db_pass_val" {
  count     = var.create_databases ? 1 : 0
  secret_id = local.master_user_secret_arn
}

# Configuração do Provider PostgreSQL que será passado para o módulo.
# A configuração de um provedor no root e a sua passagem explícita é a maneira
# correta de contornar a limitação de 'count' em módulos que precisam de provedores.
provider "postgresql" {
  alias           = "db_creator"
  host            = aws_db_instance.default.address
  port            = 5432
  database        = "postgres"
  username        = aws_db_instance.default.username
  # A senha só será lida se 'create_databases' for true, pois o data source 'db_pass_val' depende disso.
  password        = var.create_databases ? jsondecode(data.aws_secretsmanager_secret_version.db_pass_val[0].secret_string)["password"] : null
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

# Cria os bancos de dados lógicos usando um módulo condicional.
# A sua execução é controlada pela variável 'create_databases'.
module "postgres_databases" {
  source = "./modules/postgres_db_creator"
  count  = var.create_databases ? 1 : 0

  providers = {
    postgresql = postgresql.db_creator
  }

  db_names = var.db_names
}

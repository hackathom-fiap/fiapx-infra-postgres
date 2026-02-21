locals {
  # Tenta obter o ARN do segredo do usuário mestre de forma segura. Retorna nulo se não encontrado.
  # Isso evita erros de "Index value required" durante a destruição ou se o segredo não estiver disponível.
  master_user_secret_arn = try(aws_db_instance.default.master_user_secret[0].secret_arn, null)
}

# Data Source para recuperar a versão do segredo gerenciado pelo RDS no Secrets Manager
# A execução deste data source é condicionada à existência do ARN do segredo.
data "aws_secretsmanager_secret_version" "db_pass_val" {
  count     = local.master_user_secret_arn != null ? 1 : 0
  secret_id = local.master_user_secret_arn
}

# Cria os bancos de dados lógicos usando um módulo condicional.
# Isso quebra o ciclo de dependência do provedor, pois o módulo só é instanciado
# após o segredo do banco de dados principal ter sido criado.
module "postgres_databases" {
  source = "./modules/postgres_db_creator"
  count  = var.create_databases && local.master_user_secret_arn != null ? 1 : 0

  host     = aws_db_instance.default.address
  username = aws_db_instance.default.username
  password = jsondecode(data.aws_secretsmanager_secret_version.db_pass_val[0].secret_string)["password"]
  db_names = var.db_names
}

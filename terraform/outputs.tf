# Output do endpoint do banco de dados. Use este endereço na sua aplicação para se conectar ao banco.
output "db_instance_endpoint" {
  description = "Endereço de conexão (endpoint) da instância RDS criada."
  value       = aws_db_instance.default.endpoint
}

# Output do ARN do segredo do usuário mestre.
# Este é o ARN que você deve usar no seu SecretProviderClass no Kubernetes
# para permitir que o CSI driver busque as credenciais.
output "master_user_secret_arn" {
  description = "ARN do segredo do Secrets Manager que contém as credenciais do usuário mestre."
  value       = aws_db_instance.default.master_user_secret[0].secret_arn
}
# Exemplo de arquivo de variáveis.
# Copie este arquivo para terraform.tfvars e preencha com seus valores.
# O arquivo terraform.tfvars NÃO deve ser enviado para o controle de versão (git).

# ID da VPC onde o banco de dados e a aplicação estão.
vpc_id = "vpc-8ce247f1"

# Lista de IDs de sub-redes PRIVADAS onde o banco de dados será colocado.
private_subnet_ids = ["subnet-c3f47da5", "subnet-8a652684"]

# ID do Security Group da sua aplicação. O banco de dados permitirá conexões de entrada a partir deste grupo na porta 5432.
app_security_group_id = "sg-0c84b61816a057356"

# --- Configurações de Banco de Dados Lógicos ---

# Flag para habilitar a criação dos bancos. Mude para true APÓS o primeiro deploy (ou se a rede permitir).
create_databases = true

# Controla se o RDS será acessível pela internet (necessário true para o GitHub Actions criar os bancos)
db_publicly_accessible = false

# Nomes dos bancos de dados lógicos que serão criados
db_names = ["api-db", "worker-db"]

# IPs permitidos para conexão (0.0.0.0/0 libera para a internet para o GitHub Actions conectar)
db_allowed_cidr_blocks = ["0.0.0.0/0"]


# 1 Deploy - create database : false e db_publicly_accessible : true
# 2 Deploy - create database : true e db_publicly_accessible : true
# 3 Deploy - create database : true e db_publicly_accessible : false
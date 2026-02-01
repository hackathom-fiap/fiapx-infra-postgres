
# Cria um grupo de sub-redes para o RDS, garantindo que ele seja implantado em sub-redes privadas.
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# Cria um grupo de segurança para o RDS para controlar o tráfego de rede.
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Allows inbound traffic on port 5432 for RDS"
  vpc_id      = var.vpc_id

  # Regra de entrada: permite acesso da aplicação na porta do PostgreSQL (5432).
  # A conexão é permitida apenas a partir do Security Group da aplicação.
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  # Regra de entrada: permite acesso externo controlado por CIDR (necessário para GitHub Actions)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.db_allowed_cidr_blocks
  }

  # Regra de saída: permite todo o tráfego de saída.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# Cria a instância do banco de dados RDS PostgreSQL.

resource "aws_db_instance" "default" {

  identifier             = "${var.project_name}-db"

  engine                 = "postgres"

  engine_version         = "15.7" # Use uma versão estável e suportada

  instance_class         = var.db_instance_class

  allocated_storage      = var.db_allocated_storage

  storage_type           = "gp2"



  # Deixa o RDS gerenciar a senha mestre e a armazenar no AWS Secrets Manager.

  # Esta é a abordagem mais segura e recomendada.

  manage_master_user_password = true

  username                    = "postgresadmin" # Você pode customizar o nome de usuário

  db_name                     = "postgres"      # Banco de dados inicial padrão



  db_subnet_group_name   = aws_db_subnet_group.default.name

  vpc_security_group_ids = [aws_security_group.db_sg.id]





    # Configurações adicionais importantes





    multi_az            = false # Mude para 'true' para alta disponibilidade em produção





    publicly_accessible = var.db_publicly_accessible # Controlado via terraform.tfvars





    skip_final_snapshot = true  # Mude para 'false' em produção para criar um snapshot ao deletar





  



  tags = {

    Name = "${var.project_name}-db-instance"

  }

}

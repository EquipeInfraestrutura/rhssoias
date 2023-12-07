terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
       version = "~> 4.0"
    }
  }
}

provider "aws" {}
#script para enviar as variáveis para o parameter store
data "template_file" "test" {
  template = <<-EOT
              #!/bin/bash
              yum install aws-cli -y
              PARAM_VALUE=$(aws ssm get-parameter --with-decrypt --name "KC_DB_CONNSTRING_HMG" --query "Parameter.Value" --output text)
              PARAM_VALUE1=$(aws ssm get-parameter --with-decrypt --name "KC_DB_USER" --query "Parameter.Value" --output text)
              PARAM_VALUE2=$(aws ssm get-parameter --with-decrypt --name "KC_DB_PW" --query "Parameter.Value" --output text)
              echo "export KC_DB_CONNSTRING_HMG=$PARAM_VALUE" >> /etc/profile
              echo "export KC_DB_USER=$PARAM_VALUE1" >> /etc/profile
              echo "export KC_DB_PW=$PARAM_VALUE2" >> /etc/profile
              EOT
}
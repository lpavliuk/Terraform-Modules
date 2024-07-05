# main.tf
module "ecs_service" {
  source = "git::https://github.com/lpavliuk/Terraform-Modules.git//aws_ecs_service"

  name                         = "api"
  cluster_id                   = var.cluster_id
  capacity_provider_name       = var.capacity_provider_name
  desired_count                = 2

  containers = [
    {
      name                         = "api"
      links                        = ["mysql"]
      port                         = 52150
      image                        = "gitlab.example.com/group/api:latest"
      private_registry_credentials = {
        username = var.gitlab_token_username
        password = var.gitlab_token_secret
      }
      essential                    = true
      target_group_arn             = var.target_group_arn
      health_check                 = {
        endpoint = "/health.check"
      }
      env                          = [{
        name  = "ENVIRONMENT"
        value = "dev"
      }]
    },
    {
      name                         = "mysql"
      port                         = 3306
      essential                    = false
      image                        = "mysql:latest"
    }
  ]
}

# main.tf
module "ecs_service" {
  source = "../../../../modules/aws_ecs_service"

  name                         = "portal-api"
  cluster_id                   = var.cluster_id
  capacity_provider_name       = var.capacity_provider_name
  desired_count                = 2

  containers = [
    {
      name                         = "portal-api"
      links                        = ["mysql"]
      port                         = 52150
      image                        = "registry.larder.investfast.digital/ui-group/customer-portal-proxy-api:dev"
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

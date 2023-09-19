locals {
  gitlab_secrets_namespace = [
    format("%s-%s", var.apps["gitlab"].name, var.environment.type),
    format("%s-%s", var.apps["gitlab_runner"].name, var.environment.type)
  ]
  gitlab_secret = {
    for key_result, val_result in flatten([
      for key, namespace in local.gitlab_secrets_namespace : [
        for k, v in var.apps["gitlab"].secrets : {
          name      = v.name
          data      = v.data
          namespace = namespace
        }
      ]
    ]) : "${val_result.name}-${val_result.namespace}" => val_result
  }
}


variable "helm" {
  default = {
    atomic = true
  }
}

variable "environment" {
  default = {
    name = "minikube"
    type = "staging"
  }
}

variable "ingress" {
  default = {
    ingress_class_name = "traefik"
    tls                = true
  }
}

variable "apps" {
  default = {
    gitlab = {
      hostname        = "local"
      gitlab_hostname = "gitlab.local"
      name            = "gitlab"
      repository      = "http://charts.gitlab.io/"
      chart           = "gitlab"
      version         = "7.3.3"
      path_value      = "app/gitlab/values.yaml"
      secrets = {
        runner = {
          name = "gitlab-runner-secret"
          data = {
            "runner-registration-token" = "a928d6c215d977f631ae6529b53926111c6fba9cb503e9dc5bca1260ea210e07"
            "runner-token" : ""
          }
        }
        minio = {
          name = "gitlab-minio-access-secret"
          data = {
            accesskey = "cfeb27ffcc1a52803ae9fb735e696d4893a86f434627e0a4dea4598db09ee690"
            secretkey = "da18dd20159ec5d1a1091d34e14be503eab37db9e484765a0f0e5b85ae70babc"
          }
        }
      }
    }
    gitlab_runner = {
      name       = "gitlab-runner"
      repository = "http://charts.gitlab.io/"
      chart      = "gitlab-runner"
      version    = "0.38.1"
      path_value = "app/gitlab_runner/values.yaml"
    }
    traefik = {
      name       = "traefik"
      repository = "https://helm.traefik.io/traefik"
      chart      = "traefik"
      version    = "10.15.0"
      path_value = "app/traefik/values.yaml"
    }
  }
}

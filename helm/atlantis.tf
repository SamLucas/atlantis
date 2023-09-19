########################################
######### Atlantis (Namespace) #########
########################################

resource "kubernetes_namespace" "atlantis_namespace" {
  metadata {
    name = format(
      "%s-%s",
      var.config_atlantis.name,
      var.environment.type
    )
  }
}

########################################
############### Atlantis ###############
########################################

resource "helm_release" "atlantis" {
  name       = var.config_atlantis.name
  repository = var.config_atlantis.repository
  chart      = var.config_atlantis.chart
  version    = var.config_atlantis.version
  atomic     = var.helm.atomic
  namespace = format(
    "%s-%s",
    var.config_atlantis.name,
    var.environment.type
  )

  values = [
    templatefile(var.config_atlantis.path_value, {
      HOST_NAME                   = var.config_atlantis.hostname
      USERNAME                    = var.config_atlantis.username
      TOKEN                       = var.config_atlantis.token
      SECRET                      = var.config_atlantis.secret
      HOST_NAME_GITLAB            = var.config_atlantis.hostname_gitlab
      HOST_NAME_GITLAB_ALLOW_LIST = var.config_atlantis.hostname_gitlab_allow_list
    })
  ]

  depends_on = [
    kubernetes_namespace.atlantis_namespace,
  ]
}

variable "environment" {
  default = {
    type = "staging"
  }
}

variable "helm" {
  default = {
    atomic = true
  }
}

variable "ingress" {
  default = {
    ingress_class_name = "traefik"
    tls                = true
  }
}

variable "config_atlantis" {
  default = {
    name                       = "atlantis"
    repository                 = "https://runatlantis.github.io/helm-charts"
    chart                      = "atlantis"
    version                    = "4.14.0"
    path_value                 = "values_helm.yaml"
    username                   = "atlantis"
    token                      = "glpat-u-6QixrK65oPE9LgPvJs"
    secret                     = "a928d6c2"
    hostname                   = "atlantis.helm.local"
    hostname_gitlab            = "http://gitlab.local"
    hostname_gitlab_allow_list = "gitlab.local/*"
  }
}

terraform {
  required_providers {
    helm = {
      version = "2.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

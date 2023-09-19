###############################################
################# Namespaces ##################
###############################################

resource "kubernetes_namespace" "namespaces" {
  for_each = var.apps
  metadata {
    name = format(
      "%s-%s",
      each.value.name,
      var.environment.type
    )
  }
}

############################################
################# Traefik ##################
############################################

resource "helm_release" "traefik" {
  name       = var.apps["traefik"].name
  repository = var.apps["traefik"].repository
  chart      = var.apps["traefik"].chart
  version    = var.apps["traefik"].version
  atomic     = var.helm.atomic
  namespace = format(
    "%s-%s",
    var.apps["traefik"].name,
    var.environment.type
  )

  values = [file(var.apps["traefik"].path_value)]
  depends_on = [
    kubernetes_namespace.namespaces
  ]
}

##########################################
################ Gitlab ##################
##########################################

resource "helm_release" "gitlab" {
  name       = var.apps["gitlab"].name
  repository = var.apps["gitlab"].repository
  chart      = var.apps["gitlab"].chart
  version    = var.apps["gitlab"].version
  atomic     = var.helm.atomic
  namespace = format(
    "%s-%s",
    var.apps["gitlab"].name,
    var.environment.type
  )

  values = [templatefile(var.apps["gitlab"].path_value, {
    HOST_GITLAB = var.apps["gitlab"].hostname
  })]

  depends_on = [
    kubernetes_namespace.namespaces,
  ]
}


resource "kubernetes_secret" "gitlab_secrets" {

  for_each = local.gitlab_secret

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
  }

  data       = each.value.data
  depends_on = [kubernetes_namespace.namespaces]
}


############################################
############ Gitlab Runner #################
############################################

resource "helm_release" "gitlab_runner" {
  name       = var.apps["gitlab_runner"].name
  repository = var.apps["gitlab_runner"].repository
  chart      = var.apps["gitlab_runner"].chart
  version    = var.apps["gitlab_runner"].version

  namespace = format(
    "%s-%s",
    var.apps["gitlab_runner"].name,
    var.environment.type
  )

  values = [templatefile(var.apps["gitlab_runner"].path_value, {
    SERVER_ADDRESS = "minio.${var.apps["gitlab"].hostname}"
    GITLAB_URL     = format("http://%s", var.apps["gitlab"].gitlab_hostname)
  })]

  depends_on = [
    helm_release.gitlab,
    kubernetes_namespace.namespaces,
    kubernetes_secret.gitlab_secrets
  ]
}

############################################
######### Traefik IngressRouteTCP ##########
############################################

resource "kubectl_manifest" "traefik_ingressRouteTCP" {
  yaml_body = templatefile("app/traefik/ingressRouteTcp.yaml", {
    NAMESPACE = format(
      "%s-%s",
      var.apps["traefik"].name,
      var.environment.type
    )
  })
  depends_on = [
    helm_release.traefik,
    helm_release.gitlab
  ]
}

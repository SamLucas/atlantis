# Atlantis

Este repo tem configuracoes para instalacao do atlantis de duas formas diferentes, helm + terraform e kustomize.

Execute a base primeiro para poder instalar o Atlantis

# Instalando a Base

Acesso Gitlab sem signin automático

```
https://<host_gitlab>/users/sign_in?auto_sign_in=false
```

Alterar senha do root

```
kubectl exec <pod_webservice_name> -n <namespace_name> -it -- bash
```

```
/srv/gitlab/bin/rails runner "user = User.first; user.password='12345678'; user.password_confirmation='12345678'; user.save!"
```

Get Token API

```
curl --user "root:12345678" 'http://gitlab.prod8.solutis.xyz/jwt/auth?client_id=docker&offline_token=true&service=container_registry&scope=repository:samuel.gomes/samuelonboard:pull'
```

Senha Root 

```
➜  k get secret -n gitlab-staging gitlab-gitlab-initial-root-password --template={{.data.password}} | base64 -d
```
## Erros Comuns 

- Erro 422 Gitlab

O que causa: uso de http com o https configurado
Como resolver: desabilite o https


## Pos instalacao

- Criar usuario administrador do atlantis

- Criar token para o atlantis

- Adicionar o atlantis como membro do projeto 

- habilitar solicitacoes locais 

- admin area > network > Outbound request > Allow requests to the local network from webhooks and integrations


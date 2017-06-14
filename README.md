Repo des sources du slot Nomad pour la Paris Container Day 2017

Ce repo est divisé en plusieurs dossiers liés aux différentes étapes du slot, ainsi qu'un dossier app contenant les sources de l'application utilisée pour la démo.

étape 1 : Création du cluster Nomad et Consul sur GCP pour gérer la région Europe
étape 2 : Lancement de l'application de test sur le cluster
étape 3 : Extension du cluster Nomad sur un nouveau datacenter en France sur l'infra OVH
étape 4 : Mise à jour de l'application de test pour s'étendre sur le nouveau datacenter
étape 5 : Création du cluster Nomad et Consul sur AWS pour gérer la région US et jonction avec la région Europe
app : Application de test utilisant consul-template et nginx

# Création de l'infra Nomad

## Création du cluster Nomad de la région Europe

Les sources sont dans le dossier `etape1_initialisation` et sont gérées via terraform.  
Le provider utilisé est GCP, les identifiants doivent être configurés avant de lancer l'exécution : https://www.terraform.io/docs/providers/google/index.html

Terraform peut être lancé :
```shell
cd etape1_initialisation/
terraform apply
```

A la fin de la création il est possible de se connecter sur l'un des serveurs pour vérifier l'état consul et nomad :
```shell
ssh xxx.xxx.xxx.xxx
consul members
nomad node-status
nomad server-members
```

## Création du datacenter France dans la région Europe

Les sources sont dans le dossier `etape3_extending` et sont gérées via terraform.  
Le provider utilisé est OVH via OpenStack, les identifiants doivent être configurés avant de lancer l'exécution : https://www.terraform.io/docs/providers/openstack/index.html

Terraform peut être lancé :
```shell
cd etape3_extending/
terraform apply
```

A la fin de la création il est possible de se connecter sur l'un des serveurs pour vérifier l'état consul et nomad :
```shell
ssh xxx.xxx.xxx.xxx
consul members
```

On peut également se reconnecter à l'un des serveurs de la région europe précédemment créés :
```shell
ssh xxx.xxx.xxx.xxx
consul members -wan
nomad node-status
nomad server-members
```

Nomad Remote : nomad status -address=https://remote-address:4646

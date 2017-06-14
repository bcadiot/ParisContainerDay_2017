# Nomad @ Paris Container Day 2017

Repo des sources du slot "Nomad, l'orchestration made in HashiCorp" pour le Paris Container Day 2017

Ce repo est divisé en plusieurs dossiers liés aux différentes étapes du slot, ainsi qu'un dossier app contenant les sources de l'application utilisée pour la démo.

* étape 1 : Création du cluster Nomad et Consul sur GCP pour gérer la région Europe
* étape 2 : Lancement de l'application de test sur le cluster
* étape 3 : Extension du cluster Nomad sur un nouveau datacenter en France sur l'infra OVH
* étape 4 : Mise à jour de l'application de test pour s'étendre sur le nouveau datacenter
* étape 5 : Création du cluster Nomad et Consul sur AWS pour gérer la région US et jonction avec la région Europe
* app : Application de test utilisant consul-template et nginx

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
ssh yyy.yyy.yyy.yyy
consul members -wan
nomad node-status
nomad server-members
```

## Création du cluster Nomad dans la région US

Les sources sont dans le dossier `etape5_extending` et sont gérées via terraform.  
Le provider utilisé est AWS, les identifiants doivent être configurés avant de lancer l'exécution : https://www.terraform.io/docs/providers/aws/index.html

Terraform peut être lancé :
```shell
cd etape5_extending/
terraform apply
```

A la fin de la création il est possible de se connecter sur l'un des serveurs pour vérifier l'état consul et nomad :
```shell
ssh zzz.zzz.zzz.zzz
consul members -wan
nomad node-status
nomad server-members
```

La jonction de la région Nomad doit être réalisée manuellement. La découverte automatique via consul se limite à la connexion entre DC sous une même région (indiquer l'IP d'un serveur nomad d'une autre région) :
```shell
ssh zzz.zzz.zzz.zzz
nomad server-join xxx.xxx.xxx.xx
nomad server-members
```

# Lancement des jobs

## Compilation de l'image docker

Une image Docker de test a été utilisée, les sources sont disponibles dans le dossier `app`

L'image est déja compilée et disponible sur le docker hub, sont emplacement est `bcadiot/app-pcd2017:1.0`

Il est possible de la recompiler et d'utiliser sa propre image (remplacez le tag par le votre et votre compte):
```shell
cd app/
docker build -t bcadiot/app-pcd2017:1.0 .
docker push bcadiot/app-pcd2017:1.0
```

Si vous changez l'image n'oubliez pas de modifier les jobs Nomad dans les dossier `etape2_running` et `etape4_updating`

## Lancement de l'application sur GCP

Les sources sont dans le dossier `etape2_running`, il s'agit d'un job nomad.

Le job peut être lancé soit depuis le client local si le binaire nomad est installé, soit via l'API HTTP avec un POST, soit en le copiant sur l'un des serveurs en le lançant localement :
```shell
# Pour le lancement local, utiliser l'adresse IP d'un serveur Nomad de l'étape 1
cd etape2_running/
nomad run -address=http://xxx.xxx.xxx.xxx:4646 app.nomad

# Pour le lancement distant, utiliser l'adresse IP d'un serveur Nomad de l'étape 1
cd etape2_running/
scp app.nomad xxx.xxx.xxx.xxx:/tmp/
ssh xxx.xxx.xxx.xxx
cd /tmp
nomad run app.nomad
```

Pour utiliser l'API HTTP en POST, suivre la référence d'API :
https://www.nomadproject.io/docs/http/jobs.html
Attention, pour être passé en POST les jobs doivent être formatés en JSON. Ce n'est pas le cas du job de test qui est au format HCL

## Vérification du status de l'application

Pour vérifier le job on peut utiliser les commandes status (ou utiliser l'API indiquée plus haut pour les accès HTTP) :
```shell
# En distant
nomad status -address=http://xxx.xxx.xxx.xxx:4646
nomad status -address=http://xxx.xxx.xxx.xxx:4646 pcd2017

# En distant
nomad status
nomad status pcd2017
```

Pour terminer, on peut aller avec un navigateur interroger le port 80 de l'un des Nodes nomad executant notre application (la liste est indiquée par la commande status lancée plus haut)

## Mise à jour de l'application pour OVH

Les sources sont dans le dossier `etape4_updating`, il s'agit d'un job nomad.

Le job peut être lancé soit depuis le client local si le binaire nomad est installé, soit via l'API HTTP avec un POST, soit en le copiant sur l'un des serveurs en le lançant localement :
```shell
# Pour le lancement local, utiliser l'adresse IP d'un serveur Nomad de l'étape 1
cd etape4_updating/
nomad run -address=http://xxx.xxx.xxx.xxx:4646 app.nomad

# Pour le lancement distant, utiliser l'adresse IP d'un serveur Nomad de l'étape 1
cd etape4_updating/
scp app.nomad xxx.xxx.xxx.xxx:/tmp/
ssh xxx.xxx.xxx.xxx
cd /tmp
nomad run app.nomad
```

Pour utiliser l'API HTTP en POST, suivre la référence d'API :
https://www.nomadproject.io/docs/http/jobs.html
Attention, pour être passé en POST les jobs doivent être formatés en JSON. Ce n'est pas le cas du job de test qui est au format HCL

## Vérification de l'application

La vérification est exactement la même qu'a l'étape précédente

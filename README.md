Repo des sources du slot Nomad pour la Paris Container Day 2017

Ce repo est divisé en plusieurs dossiers liés aux différentes étapes du slot, ainsi qu'un dossier app contenant les sources de l'application utilisée pour la démo.

étape 1 : Création du cluster Nomad et Consul sur GCP pour gérer la région Europe
étape 2 : Lancement de l'application de test sur le cluster
étape 3 : Extension du cluster Nomad sur un nouveau datacenter en France sur l'infra OVH
étape 4 : Mise à jour de l'application de test pour s'étendre sur le nouveau datacenter
étape 5 : Création du cluster Nomad et Consul sur AWS pour gérer la région US et jonction avec la région Europe
app : Application de test utilisant consul-template et nginx

Nomad Remote : nomad status -address=https://remote-address:4646

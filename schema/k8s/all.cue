// all the V1 objects usable by Helm
package k8s

import (
	apps "k8s.io/api/apps/v1"
	autoscaling "k8s.io/api/autoscaling/v1"
	batch "k8s.io/api/batch/v1"
	core "k8s.io/api/core/v1"
	networking "k8s.io/api/networking/v1"
	policy "k8s.io/api/policy/v1"
	rbac "k8s.io/api/rbac/v1"
	storage "k8s.io/api/storage/v1"
)

// Same order as Helm
// these were missing

// #CustomResourceDefinition
// #PodSecurityPolicy
// #SecretList
// #ClusterRoleList
// #ClusterRoleBindingList
// #RoleList
// #RoleBindingList
// #APIService

#Namespace:               core.#Namespace
#NetworkPolicy:           networking.#NetworkPolicy
#ResourceQuota:           core.#ResourceQuota
#LimitRange:              core.#LimitRange
#PodDisruptionBudget:     policy.#PodDisruptionBudget
#ServiceAccount:          core.#ServiceAccount
#Secret:                  core.#Secret
#ConfigMap:               core.#ConfigMap
#StorageClass:            storage.#StorageClass
#PersistentVolume:        core.#PersistentVolume
#PersistentVolumeClaim:   core.#PersistentVolumeClaim
#ClusterRole:             rbac.#ClusterRole
#ClusterRoleBinding:      rbac.#ClusterRoleBinding
#Role:                    rbac.#Role
#RoleBinding:             rbac.#RoleBinding
#Service:                 core.#Service
#DaemonSet:               apps.#DaemonSet
#Pod:                     core.#Pod
#ReplicationController:   core.#ReplicationController
#ReplicaSet:              apps.#ReplicaSet
#Deployment:              apps.#Deployment
#HorizontalPodAutoscaler: autoscaling.#HorizontalPodAutoscaler
#StatefulSet:             apps.#StatefulSet
#Job:                     batch.#Job
#CronJob:                 batch.#CronJob
#Ingress:                 networking.#Ingress

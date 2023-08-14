package main

import (
	"github.com/hofstadter-io/cuelm/schema/k8s"
)

app: {
	namespace: k8s.#Namespace
	deploy:    k8s.#Deployment
	ingress:   k8s.#Ingress
}

package v1

_apiVersion: "networking/v1"

#NetworkPolicy: {
	kind:       "NetworkPolicy"
	apiVersion: _apiVersion
}

#Ingress: {
	kind:       "Ingress"
	apiVersion: _apiVersion
}

#IngressClass: {
	kind:       "IngressClass"
	apiVersion: _apiVersion
}

#NetworkPolicyPort: port: intstr.#IntOrStringPort

package v1

_apiVersion: "v1"

#Namespace: {
	kind:       "Namespace"
	apiVersion: _apiVersion
}

#PersistentVolume: {
	kind:       "PersistentVolume"
	apiVersion: _apiVersion
}

#PersistentVolumeClaim: {
	kind:       "PersistentVolumeClaim"
	apiVersion: _apiVersion
}

#PersistentVolumeClaimTemplate: {
	kind:       "PersistentVolumeClaimTemplate"
	apiVersion: _apiVersion
}

#PodStatusResult: {
	kind:       "PodStatusResult"
	apiVersion: _apiVersion
}

#Pod: {
	kind:       "Pod"
	apiVersion: _apiVersion
}

#PodTemplateSpec: {
	kind:       "PodTemplateSpec"
	apiVersion: _apiVersion
}

#PodTemplate: {
	kind:       "PodTemplate"
	apiVersion: _apiVersion
}

#ReplicationController: {
	kind:       "ReplicationController"
	apiVersion: _apiVersion
}

#Service: {
	kind:       "Service"
	apiVersion: _apiVersion
}

#ServiceAccount: {
	kind:       "ServiceAccount"
	apiVersion: _apiVersion
}

#Endpoints: {
	kind:       "Endpoints"
	apiVersion: _apiVersion
}

#Node: {
	kind:       "Node"
	apiVersion: _apiVersion
}

#Binding: {
	kind:       "Binding"
	apiVersion: _apiVersion
}

#Event: {
	kind:       "Event"
	apiVersion: _apiVersion
}

#LimitRange: {
	kind:       "LimitRange"
	apiVersion: _apiVersion
}

#ResourceQuota: {
	kind:       "ResourceQuota"
	apiVersion: _apiVersion
}

#Secret: {
	kind:       "Secret"
	apiVersion: _apiVersion
}

#ConfigMap: {
	kind:       "ConfigMap"
	apiVersion: _apiVersion
}

#ComponentStatus: {
	kind:       "ComponentStatus"
	apiVersion: _apiVersion
}

#RangeAllocation: {
	kind:       "RangeAllocation"
	apiVersion: _apiVersion
}

#HTTPGetAction: port:     intstr.#IntOrStringPort
#TCPSocketAction: port:   intstr.#IntOrStringPort
#ServicePort: targetPort: intstr.#IntOrStringPort

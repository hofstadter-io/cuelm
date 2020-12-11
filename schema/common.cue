package schema

#Labels: [string]: string
#Annotations: [string]: string

#Metadata: {
	name: string
	namespace?: string
	labels?: #Labels
	annotations?: #Annotations
}

#Resource: {
	apiVersion: string
	kind: string
	metadata: #Metadata
	...
}

#List: {
	apiVersion: "v1"
	kind: "List"
	items: [...#Resource]
}

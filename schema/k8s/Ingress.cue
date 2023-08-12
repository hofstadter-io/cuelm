package schema

#Ingress: #Resource & {
	apiVersion: "networking.k8s.io/v1"
	kind: "Ingress"

	spec: {
		tls: [...{
			hosts: [...string]
			secretName: string
		}]
		rules: [...{
			host: string
			http: {
				paths: [...{
					path: string | *"/"
					pathType: *"Prefix" | "Exact" | "Mixed"
					backend: {
						service: {
							name: string
							port: "number": int
						}
					}
				}]
			}
		}]
	}
}


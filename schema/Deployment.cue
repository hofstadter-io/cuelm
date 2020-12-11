package schema

#Deployment: #Resource & {
	apiVersion: "apps/v1"
	kind: "Deployment"

	spec: {
		selector: matchLabels: #Labels
		strategy: {...} | *{
			type: "RollingUpdate"
			rollingUpdate: {
				maxSurge: 1
				maxUnavailable: 0
			}
		}
		minReadySeconds: 5

		template: {
			metadata: {
				labels: #Labels
			}
			spec: {
				containers: [...{...}]
			}
		}
	}
}


param name string
param location string
param envId string
param image string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@minValue(0) @maxValue(10)
param minReplicas int = 0

@minValue(1) @maxValue(10)
param maxReplicas int = 3

resource app 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: envId
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
      activeRevisionsMode: 'Multiple'
    }
    template: {
      containers: [
        {
          name: name
          image: image
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: 80
              }
              initialDelaySeconds: 10
              periodSeconds: 30
              failureThreshold: 3
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/health/ready'
                port: 80
              }
              periodSeconds: 10
              failureThreshold: 3
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'http-rule'
            http: { metadata: { concurrentRequests: '10' } }
          }
        ]
      }
    }
  }
}

output fqdn string = app.properties.configuration.ingress.fqdn
output latestRevisionName string = app.properties.latestRevisionName

param name string
param location string
param logWorkspaceCustomerId string
@secure()
param logWorkspacePrimaryKey string

resource env 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logWorkspaceCustomerId
        sharedKey: logWorkspacePrimaryKey
      }
    }
  }
}

output envId string = env.id
output defaultDomain string = env.properties.defaultDomain

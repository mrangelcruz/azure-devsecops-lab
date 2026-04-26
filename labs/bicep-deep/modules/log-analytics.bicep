@description('Name of the Log Analytics workspace')
param name string

@description('Azure region')
param location string

@allowed([30, 60, 90, 120, 180, 270, 365, 550, 730])
param retentionDays int = 30

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: retentionDays
  }
}

output workspaceId string = workspace.id
output customerId string = workspace.properties.customerId
@secure()
output primaryKey string = workspace.listKeys().primarySharedKey

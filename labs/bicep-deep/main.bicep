@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Set to true to retain logs for 90 days (prod) vs 30 days (non-prod)')
param isProduction bool = environment == 'prod'

param location string = resourceGroup().location

var prefix = 'lab-${environment}'

module logs 'modules/log-analytics.bicep' = {
  name: 'logs'
  params: {
    name: '${prefix}-logs'
    location: location
    retentionDays: isProduction ? 90 : 30
  }
}

module acaEnv 'modules/container-app-env.bicep' = {
  name: 'aca-env'
  params: {
    name: '${prefix}-env'
    location: location
    logWorkspaceCustomerId: logs.outputs.customerId
    logWorkspacePrimaryKey: logs.outputs.primaryKey
  }
}

module app 'modules/container-app.bicep' = {
  name: 'app'
  params: {
    name: '${prefix}-api'
    location: location
    envId: acaEnv.outputs.envId
    minReplicas: isProduction ? 2 : 0
    maxReplicas: isProduction ? 10 : 3
  }
}

output appUrl string = 'https://${app.outputs.fqdn}'

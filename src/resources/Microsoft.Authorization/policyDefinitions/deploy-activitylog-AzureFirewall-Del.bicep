targetScope = 'managementGroup'

param parResourceGroupName string = 'AlzMonitoring-rg'
param policyLocation string = 'centralus'
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

param parAlertState string = 'true'

module ActivityLogFirewallDeleteAlert '../../arm/Microsoft.Authorization/policyDefinitions/managementGroup/deploy.bicep' = {
    name: '${uniqueString(deployment().name)}-shi-policyDefinitions'
    params: {
        name: 'Deploy_activitylog_Firewall_Delete'
        displayName: '[DINE] Deploy Activity Log Azure FireWall Delete Alert'
        description: 'DINE policy to Deploy Activity Log Azure Firewall Delete Alert'
        location: policyLocation
        metadata: {
            version: '1.0.0'
            Category: 'ActivityLog'
            source: 'https://github.com/Azure/ALZ-Monitor/'
        }
        parameters: {
            enabled: {
                type: 'String'
                metadata: {
                    displayName: 'Alert State'
                    description: 'Alert state for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAlertState
            }
        }
        policyRule: {
            if: {
                allOf: [

                    {
                        field: 'type'
                        equals: 'Microsoft.Network/azureFirewalls'
                    }
                ]
            }
            then: {
                effect: 'deployIfNotExists'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/activityLogAlerts'
                    // should be replaced with parameter value
                    resourceGroupName: parResourceGroupName
                    existenceCondition: {
                        allOf: [
                            {
                                field: 'Microsoft.Insights/ActivityLogAlerts/enabled'
                                equals: '[parameters(\'enabled\')]'
                            }
                            {
                                count: {
                                    field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*]'
                                    where: {
                                        anyOf: [
                                            {
                                                allOf: [
                                                    {
                                                        field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*].field'
                                                        equals: 'category'
                                                    }
                                                    {
                                                        field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*].equals'
                                                        equals: 'Administrative'
                                                    }
                                                ]
                                            }
                                            {
                                                allOf: [
                                                    {
                                                        field: 'microsoft.insights/activityLogAlerts/condition.allOf[*].field'
                                                        equals: 'operationName'
                                                    }
                                                    {
                                                        field: 'microsoft.insights/activityLogAlerts/condition.allOf[*].equals'
                                                        equals: 'Microsoft.Microsoft.Network/azurefirewalls/delete'
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                }
                                equals: 2
                            }
                        ]
                    }
                    deployment: {
                        properties: {
                            mode: 'incremental'
                            template: {
                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                contentVersion: '1.0.0.0'
                                parameters: {
                                    enabled: {
                                        type: 'string'
                                    }
                                }
                                variables: {}
                                resources: [
                                    //should deploy resource group as well
                                    {
                                        type: 'Microsoft.Resources/resourceGroups'
                                        apiVersion: '2020-10-01'
                                        name: parResourceGroupName
                                        location: policyLocation
                                        properties: {}
                                    }
                                    {
                                        type: 'Microsoft.Resources/deployments'
                                        apiVersion: '2019-10-01'
                                        //change name
                                        name: 'ActivityLAWorkspaceDelete'
                                        resourceGroup: parResourceGroupName
                                        dependsOn: [
                                            'Microsoft.Resources/resourceGroups/${parResourceGroupName}'
                                        ]
                                        properties: {
                                            mode: 'Incremental'
                                            template: {
                                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                                contentVersion: '1.0.0.0'
                                                parameters: {
                                                    enabled: {
                                                        type: 'string'
                                                    }
                                                }
                                                variables: {}
                                                resources: [
                                                    {
                                                        type: 'microsoft.insights/activityLogAlerts'
                                                        apiVersion: '2020-10-01'
                                                        //name: '[concat(subscription().subscriptionId, \'-ActivityReGenKey\')]'
                                                        name: 'ActivityAzureFirewallDelete'
                                                        location: 'global'
                                                        properties: {
                                                            description: 'Activity Log Firewall Delete'
                                                            enabled: '[parameters(\'enabled\')]'
                                                            scopes: [
                                                                '[subscription().id]'
                                                            ]
                                                            condition: {
                                                                allOf: [
                                                                    {
                                                                        field: 'category'
                                                                        equals: 'Administrative'
                                                                    }
                                                                    {
                                                                        field: 'operationName'
                                                                        equals: 'Microsoft.Network/azurefirewalls/delete'
                                                                    }
                                                                    {
                                                                        field: 'status'
                                                                        containsAny: [
                                                                            'succeeded'
                                                                        ]
                                                                    }

                                                                ]
                                                            }
                                                            parameters: {
                                                                enabled: {
                                                                    value: '[parameters(\'enabled\')]'
                                                                }
                                                            } 
                                                        }
                                                    }
                                                ]
                                            }
                                            parameters: {
                                                enabled: {
                                                    value: '[parameters(\'enabled\')]'
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            parameters: {
                                enabled: {
                                    value: '[parameters(\'enabled\')]'
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

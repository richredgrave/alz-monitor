// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

targetScope = 'managementGroup'

param policyLocation string = 'centralus'
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

@allowed([
    '0'
    '1'
    '2'
    '3'
    '4'
])
param parAlertSeverity string = '1'

@allowed([
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
    'PT6H'
    'PT12H'
    'P1D'
])
param parWindowSize string = 'PT15M'

@allowed([
    'Equals'
    'GreaterThan'
    'GreaterThanOrEqual'
    'LessThan'
    'LessThanOrEqual'

])
param parOperator string = 'GreaterThan'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
])
param parEvaluationFrequency string = 'PT5M'

@allowed([
    'deployIfNotExists'
    'disabled'
])
param parPolicyEffect string = 'deployIfNotExists'

param parAutoMitigate string = 'true'

param parautoResolve string = 'true'

param parautoResolveTime string = '00:10:00'

param parAlertState string = 'true'

param parThreshold string = '10'

@allowed([
  'Average'
  'Count'
  'Maximum'
  'Minimum'
  'Total'
])

param parTimeAggregation string = 'Average'

param parMonitorDisable string = 'MonitorDisable' 

module AvailableMemoryAlert '../../arm/Microsoft.Authorization/policyDefinitions/managementGroup/deploy.bicep' = {
    name: '${uniqueString(deployment().name)}-vmama-policyDefinitions'
    params: {
        name: 'Deploy_VM_HeartBeat_Alert_RG'
        displayName: 'Deploy VM HeartBeat Alert'
         description: 'Policy to audit/deploy VM HeartBeat Alert for VMs in the resource group'
        location: policyLocation
        metadata: {
            version: '1.0.0'
            category: 'Compute'
            source: 'https://github.com/Azure/Enterprise-Scale/' 
            alzCloudEnvironments: [ 
               'AzureCloud'
              ]
        }
        parameters: {
            severity: {
                type: 'String'
                metadata: {
                    displayName: 'Severity'
                    description: 'Severity of the Alert'
                }
                allowedValues: [
                    '0'
                    '1'
                    '2'
                    '3'
                    '4'
                ]
                defaultValue: parAlertSeverity
            }
            operator: {
                type: 'String'
                metadata:{ displayName: 'Operator'}
                allowedvalues:[
                'Equals'
                'GreaterThan'
                'GreaterThanOrEqual'
                'LessThan'
                'LessThanOrEqual'
            ]
            defaultvalue: parOperator
        }
        timeAggregation:{
            type:'String'
            metadata: {
              displayName: 'TimeAggregation'
          }
          allowedValues:[
            'Average'
            'Count'
            'Maximum'
            'Minimum'
            'Total'

          ]

          defaultvalue: parTimeAggregation

        }

         
            windowSize: {
                type: 'String'
                metadata: {
                    displayName: 'Window Size'
                    description: 'Window size for the alert'
                }
                allowedValues: [
                    
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                    'PT6H'
                    'PT12H'
                    'PT24H'
                ]
                defaultValue: parWindowSize
            }
            evaluationFrequency: {
                type: 'String'
                metadata: {
                    displayName: 'Evaluation Frequency'
                    description: 'Evaluation frequency for the alert'
                }
                allowedValues: [
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                ]
                defaultValue: parEvaluationFrequency
            }
            autoMitigate: {
                type: 'String'
                metadata: {
                    displayName: 'Auto Mitigate'
                    description: 'Auto Mitigate for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAutoMitigate
            }
            autoResolve: {
                type: 'String'
                metadata: {
                    displayName: 'Auto Resolve'
                    description: 'Auto Resolve for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parautoResolve
            }

            autoResolveTime: {
                type: 'String'
                metadata: {
                    displayName: 'Auto Resolve'
                    description: 'Auto Resolve time for the alert in ISO 8601 format'
                }
           
                defaultValue: parautoResolveTime
            }
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
     
            threshold: {
                type: 'String'
                metadata: {
                    displayName: 'Threshold'
                    description: 'Threshold for the alert'
                }
                defaultValue: parThreshold
            }
            effect: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Effect of the policy'
                }
                allowedValues: [
                    'deployIfNotExists'
                    'disabled'
                ]
                defaultValue: parPolicyEffect
            }
            MonitorDisable: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Tag name to disable monitoring resource. Set to true if monitoring should be disabled'
                }
          
                defaultValue: parMonitorDisable
            }
        }
        policyRule: {
            if: {
                allOf: [
                    {
                        field: 'type'
                        equals: 'Microsoft.Compute/virtualMachines'
                    }

                    {
                        field: '[concat(\'tags[\', parameters(\'MonitorDisable\'), \']\')]'
                        notEquals: 'true'
                    }
                ]
            }
            then: {
                effect: '[parameters(\'effect\')]'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    existenceCondition: {
                        allOf: [
               
                            {
                                field: 'Microsoft.Insights/scheduledQueryRules/displayName'
                                equals: '[concat(resourceGroup().name, \'-VMHeartBeatAlert\')]'
                            }
                            {
                                field: 'Microsoft.Insights/scheduledqueryrules/scopes[*]'
                                equals: '[concat(subscription().id, \'/resourceGroups/\', resourceGroup().name)]'
                            }
                            {
                                field: 'Microsoft.Insights/scheduledqueryrules/enabled'
                                equals: '[parameters(\'enabled\')]'
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
                                
                                    severity: {
                                        type: 'String'
                                    }
                                    windowSize: {
                                        type: 'String'
                                    }
                                    evaluationFrequency: {
                                        type: 'String'
                                    }
                                    autoMitigate: {
                                        type: 'String'
                                    }
                                    autoResolve: {
                                        type: 'String'
                                    }
                                    autoResolveTime: {
                                        type: 'String'
                                    }
                                    enabled: {
                                        type: 'String'
                                    }
                                    threshold: {
                                        type: 'String'
                                    }
                                    operator: {
                                        type:'String'

                                    }
                                    timeAggregation: {
                                        type:'String'

                                    }
                                }
                                variables: {}
                                resources: [
                                    {
                                        type: 'Microsoft.Insights/scheduledQueryRules'
                                        apiVersion: '2022-08-01-preview'
                                        name: '[concat(resourceGroup().name, \'-VMHeartBeatAlert\')]'
                                        location: '[resourceGroup().location]'
                                        properties: {
                                            displayName: '[concat(resourceGroup().name, \'-VMHeartBeatAlert\')]'
                                            description: 'Log Alert for Virtual Machine Heartbeat'
                                            severity: '[parameters(\'severity\')]'
                                            enabled: '[parameters(\'enabled\')]'
                                            scopes: [
                                                '[resourceGroup().Id]'
                                            ]
                                            targetResourceTypes: [
                                                'Microsoft.Compute/virtualMachines'
                                            ]
                                            evaluationFrequency: '[parameters(\'evaluationFrequency\')]'
                                            windowSize: '[parameters(\'windowSize\')]'
                                            criteria: {
                                                allOf: [
                                                    {
                                                        query: 'Heartbeat| summarize TimeGenerated=max(TimeGenerated) by Computer, _ResourceId| extend Duration = datetime_diff(\'minute\',now(),TimeGenerated)| summarize AggregatedValue = min(Duration) by Computer, bin(TimeGenerated,5m), _ResourceId'
                                                        metricMeasureColumn: 'AggregatedValue'
                                                        threshold: '[parameters(\'threshold\')]'
                                                        operator: '[parameters(\'operator\')]'
                                                        resourceIdColumn: '_ResourceId'
                                                        timeAggregation: '[parameters(\'timeAggregation\')]'
                                                        dimensions:[
                                                            {
                                                                name: 'Computer'
                                                                operator: 'Include'
                                                                values: [
                                                                    '*'
                                                                ]
                                                            }  

                                                        ]
                                                        failingPeriods:{
                                                            numberOfEvaluationPeriods: 1
                                                             minFailingPeriodsToAlert: 1
                                                        }
                                                    }
                                                ]
                                             
                                            }
                                            autoMitigate: '[parameters(\'autoMitigate\')]'
                                            ruleResolveConfiguration: {
                                                autoResolved: '[parameters(\'autoResolve\')]'
                                                timeToResolve: '[parameters(\'autoResolveTime\')]'
                                              }
                                          
                                            parameters: {
                                                severity: {
                                                    value: '[parameters(\'severity\')]'
                                                }
                                                windowSize: {
                                                    value: '[parameters(\'windowSize\')]'
                                                }
                                                evaluationFrequency: {
                                                    value: '[parameters(\'evaluationFrequency\')]'
                                                }
                                                autoMitigate: {
                                                    value: '[parameters(\'autoMitigate\')]'
                                                }
                                                autoResolve: {
                                                    value: '[parameters(\'autoResolve\')]'
                                                }
                                                autoResolveTime: {
                                                    value: '[parameters(\'autoResolveTime\')]'
                                                }
                                                enabled: {
                                                    value: '[parameters(\'enabled\')]'
                                                }
                                                threshold: {
                                                    value: '[parameters(\'threshold\')]'
                                                }
                                         
                                            }
                                        }
                                    }
                                ]
                            }
                            parameters: {
                              
                                severity: {
                                    value: '[parameters(\'severity\')]'
                                }
                                windowSize: {
                                    value: '[parameters(\'windowSize\')]'
                                }
                                evaluationFrequency: {
                                    value: '[parameters(\'evaluationFrequency\')]'
                                }
                                autoMitigate: {
                                    value: '[parameters(\'autoMitigate\')]'
                                  }
                                  autoResolve: {
                                    value: '[parameters(\'autoResolve\')]'
                                }
                                autoResolveTime: {
                                    value: '[parameters(\'autoResolveTime\')]'
                                }
                                enabled: {
                                    value: '[parameters(\'enabled\')]'
                                }
                                threshold: {
                                    value: '[parameters(\'threshold\')]'
                                }
                                operator: {
                                    value: '[parameters(\'operator\')]'
                                }
                                timeAggregation: {
                                    value: '[parameters(\'timeAggregation\')]'
                                }


                            }
                        }
                    }
                }
            }
        }
    }
}

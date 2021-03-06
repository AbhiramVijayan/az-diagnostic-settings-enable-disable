
Connect-AzAccount


$Reponse = 'y'
$Subscriptionid = $null
$SubscriptionList = @()
Do {
  $Subscriptionid = Read-Host 'Enter your subscription id '
  $Reponse = Read-Host 'Would you like to add additional subscription to this list? (y/n)'
  $SubscriptionList += $Subscriptionid
}
Until ($Reponse -eq 'n')
$Eventhub = Read-Host "Enter Event Hub namespace name  "
$Name = Read-Host "Enter Event Hub name  "
$resourceGroupname = Read-Host "Enter Resource group name  "
$Eventhubid = Read-Host "Enter vent Hub namespace Subscription ID "
$Region = Read-Host "Enter Event Hub region "
$Region = $Region -replace '\s', ''
$RegionLower = $Region.ToLower()
foreach ($subid in $SubscriptionList) {
  
 

  Set-AzContext -SubscriptionId $subid

  $Resources = Get-AzResource 
  $Display = Get-AzResource | Format-Table
  Write-Output $Display
  Write-Output  "Subscription id  $subid "
  Write-Output "1: Enable 
2: Disable "
  $Number = Read-Host "Select... "

  switch ($Number) {
    1 { 

      foreach ($Resource in $Resources) {
        if ($Resource.Location -eq $RegionLower) {
          # for other services 
          Set-AzDiagnosticSetting -ResourceId $Resource.ResourceId -EventHubName $Name -EventHubAuthorizationRuleId "/subscriptions/$Eventhubid/resourceGroups/$resourceGroupname/providers/Microsoft.EventHub/namespaces/$Eventhub/authorizationrules/RootManageSharedAccessKey" -Enabled $true -EnableLog $true -EnableMetrics $true
       

    
          if ( $Resource.ResourceType -eq "Microsoft.Storage/storageAccounts") {
            #for  blob,queue,table and file
            $Ids = @($Resource.ResourceId + "/blobServices/default"
              $Resource.ResourceId + "/fileServices/default"
              $Resource.ResourceId + "/queueServices/default"
              $Resource.ResourceId + "/tableServices/default"
            )
            $Ids | ForEach-Object {
            
              Set-AzDiagnosticSetting -ResourceId $_ -EventHubName $Name -EventHubAuthorizationRuleId "/subscriptions/$Eventhubid/resourceGroups/$resourceGroupname/providers/Microsoft.EventHub/namespaces/$Eventhub/authorizationrules/RootManageSharedAccessKey" -Enabled $true -EnableLog $true -EnableMetrics $true

          
            }
            #for  Storage account
            az monitor diagnostic-settings create  `
              --name  $Name `
              --resource $Resource.ResourceId `
              --metrics '[{""category"": ""AllMetrics"",""enabled"": true}]' `
              --event-hub-rule /subscriptions/$Eventhubid/resourceGroups/$resourceGroupname/providers/Microsoft.EventHub/namespaces/$Eventhub/authorizationrules/RootManageSharedAccessKey

          }
       
        }
      }

  
    }
    2 {

      foreach ($Resource in $Resources) {
        if ($Resource.Location -eq $RegionLower) {

          # for other services 
         
          Set-AzDiagnosticSetting -ResourceId $Resource.ResourceId -EventHubName $Name -EventHubAuthorizationRuleId "/subscriptions/$Eventhubid/resourceGroups/$resourceGroupname/providers/Microsoft.EventHub/namespaces/$Eventhub/authorizationrules/RootManageSharedAccessKey" -Enabled $false -EnableLog $false -EnableMetrics $false
   
         
          if ( $Resource.ResourceType -eq "Microsoft.Storage/storageAccounts") {
            #for  blob,queue,table and file

            $Ids = @($Resource.ResourceId + "/blobServices/default"
              $Resource.ResourceId + "/fileServices/default"
              $Resource.ResourceId + "/queueServices/default"
              $Resource.ResourceId + "/tableServices/default"
            )
            $Ids | ForEach-Object {
         
             
              Set-AzDiagnosticSetting -ResourceId $_ -EventHubName $Name -EventHubAuthorizationRuleId "/subscriptions/$Eventhubid/resourceGroups/$resourceGroupname/providers/Microsoft.EventHub/namespaces/$Eventhub/authorizationrules/RootManageSharedAccessKey" -Enabled $false -EnableLog $false -EnableMetrics $false

            }
            #for  Storage account
            
            az monitor diagnostic-settings delete  `
              --name  $Name `
              --resource $Resource.ResourceId

              
          }

      
    
        }
     
      }
    
    }
  }


}
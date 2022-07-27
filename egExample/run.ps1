
param($eventGridEvent, $TriggerMetadata)

# Make sure to pass hashtables to Out-String so they're logged correctly
# $eventGridEvent | Out-String | Write-Host
# $response = $eventGridEvent | ConvertTo-JSON -Depth 5 | Out-String -Width 200
$topic = $eventGridEvent.topic
$api = $eventGridEvent.data.api
$file = $eventGridEvent.data.url
$fileType = $eventGridEvent.data.contentType
# check for container name and file type and invoke appropriate
# operation in VM
Write-Information "A file change operation happened in $topic"
Write-Host "A file change operation happened in $topic"
Write-Host "$api was invoked on $file of type $fileType"
Write-Host "START execution of script in remote host"
Invoke-AzVMRunCommand -ResourceGroupName 'autosys100-rg' -Name 'autosyslinuxvm' -CommandId 'RunShellScript' -ScriptPath '.\install.bash'
Write-Host "COMPLETED execution of script on remote host"
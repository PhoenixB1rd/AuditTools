#Script to help install/setup AuditTools
$ModulePaths = @($env:PSModulePath -split ';')
$ExpectedUserModulePath = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath WindowsPowerShell\Modules
$Destination = $ModulePaths | Where-Object { $_ -eq $ExpectedUserModulePath }
if (-not $Destination) {
  $Destination = $ModulePaths | Select-Object -Index 0
}
if (-not (Test-Path ($Destination + "\AuditTools\"))) {
  New-Item -Path ($Destination + "\AuditTools\") -ItemType Directory -Force | Out-Null
  Write-Host 'Downloading AuditTools from https://github.com/ScriptAutomate/AuditTools/raw/master/AuditTools/AuditTools.psm1'
  $client = (New-Object Net.WebClient)
  $client.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
  $client.DownloadFile("https://github.com/ScriptAutomate/AuditTools/raw/master/AuditTools/AuditTools.psm1", $Destination + "\AuditTools\AuditTools.psm1")
  $client.DownloadFile("https://github.com/ScriptAutomate/AuditTools/raw/master/AuditTools/AuditTools.psd1", $Destination + "\AuditTools\AuditTools.psd1")
  
  $executionPolicy = (Get-ExecutionPolicy)
  $executionRestricted = ($executionPolicy -eq "Restricted")
  if ($executionRestricted) {
    Write-Warning @"
Your execution policy is $executionPolicy, this means you will not be able import or use any scripts -- including modules.
To fix this, change your execution policy to something like RemoteSigned.

    PS> Set-ExecutionPolicy RemoteSigned

For more information, execute:

    PS> Get-Help about_execution_policies

"@
  }

  if (!$executionRestricted) {
    # Ensure AuditTools is imported from the location it was just installed to
    Import-Module -Name $Destination\AuditTools
    Get-Command -Module AuditTools
  }
}

Write-Host "AuditTools is installed and ready to use" -Foreground Green
Write-Host @"
For more details, visit: 
https://github.com/ScriptAutomate/AuditTools
"@
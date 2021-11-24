<#
        .SYNOPSIS
        To Suspend/Restart VMware Workstation VMs using Rest API
        Developer - K.Janarthanan
        .DESCRIPTION
        To Suspend/Restart VMware Workstation VMs using Rest API
        Date - 17/11/2021
        .OUTPUTS
        Log file with name VMware_RestAPI.log in the same directory of the script
        .EXAMPLE
        PS> \Suspend_VMs.ps1
#>

$Global:LogFile = "$PSScriptRoot\VMware_RestAPI.log" #Log file location
function Write-Log #Function for logging
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Validateset("INFO","ERR","WARN")]
        [string]$Type="INFO"
    )

    $DateTime = Get-Date -Format "MM-dd-yyyy HH:mm:ss"
    $FinalMessage = "[{0}]::[{1}]::[{2}]" -f $DateTime,$Type,$Message

    #Storing the output in the log file
    $FinalMessage | Out-File -FilePath $LogFile -Append

    if($Type -eq "ERR")
    {
        Write-Host "$FinalMessage" -ForegroundColor Red
    }
    else 
    {
        Write-Host "$FinalMessage" -ForegroundColor Green
    }
}

try
{
    Write-Log "Script Started"

    $Credentials = Get-Credential -Message "Workstation Pro Credentials"
    $auth = $Credentials.UserName + ':' + $Credentials.GetNetworkCredential().password
    $Encoded = [System.Text.Encoding]::UTF8.GetBytes($auth)
    $authorizationInfo = [System.Convert]::ToBase64String($Encoded)
    $headers = @{"Authorization"="Basic $($authorizationInfo)"}

    (Invoke-RestMethod -Uri "http://127.0.0.1:8697/api/vms" -Method GET -Headers $headers -EA Stop) | Select-Object -Property path,id  | select-object  @{Name="VM_Name";Expression={$_.path.split("\")[-1].split(".")[0]}},@{Name="ID";Expression={$_.id}}

}
catch
{
    Write-Log "$_" -Type ERR
}
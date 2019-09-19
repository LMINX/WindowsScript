<#2019/09/18 use the script to install the software belows.




#>
{}
function Install-Application {
<#
    .SYNOPSIS
        Install the Anti-virus and config software from Share folder  \\r1wrdsp001\jim\ServerBuildAPP
    .DESCRIPTION
    App Name	Install Command
    Nomad	    powershell.exe -ExecutionPolicy bypass -NoProfile -NonInteractive -WindowStyle Hidden -File InstallNomadx64.ps1
    CrowdStrike	Powershell.exe -ExecutionPolicy Bypass -File AppConfig.ps1 -DeploymentType "Install"
    SCCM 	    ccmsetup.exe /smssitecode=NKE ; PowerShell.exe -NoProfile -Command ""([wmiclass]'ROOT\ccm:SMS_Client').SetAssignedSite('NKE')""
    Trend-Micro	powershell.exe -executionpolicy bypass -file Install-Trend.PS1 -role CORP
    Tanium	    Double click the msi file (“TaniumClientInstaller 3211.msi”)
    .EXAMPLE
    Install-Application -ComputerName TCGEBRP1WCVVS01 -AppName Tanium
#>
param (
# Parameter help description
[Parameter(Mandatory=$false)]
[ValidateSet("1E nomad","CrowdStrike","SCCM Client","Tanium")]$AppName,
[Parameter(Mandatory=$True)]
[String]$ComputerName
)
$username=$env:USERDOMAIN+"\"+$env:USERNAME
if ($username -notmatch "NIKE\SA.")
{
$SAUserName=$username.replace("\","\SA.")
$SACredential=Get-Credential -UserName $SAUserName -Message "Please input your SA account Password"
# validation the username and pwd

}
else 
{$SACredential=Get-Credential -UserName $UserName -Message "Please input your SA account Password"
}

#copy the installation file to the target 
$s1=New-PSSession -ComputerName $ComputerName -Credential $SACredential
Copy-Item \\r1wrdsp001\jim\ServerBuildAPP C:\ -ToSession $s1 -Recurse


$App1=[PSCustomObject]@{
    AppName="1E nomad"
    InstallCommand="powershell.exe -ExecutionPolicy bypass -NoProfile -NonInteractive -WindowStyle Hidden -File InstallNomadx64.ps1"
}

$App2=[PSCustomObject]@{
    AppName="CrowdStrike"
    InstallCommand="Powershell.exe -ExecutionPolicy Bypass -File AppConfig.ps1 -DeploymentType 'Install'"
}

$App3=[PSCustomObject]@{
    AppName="SCCM Client"
    InstallCommand="ccmsetup.exe /smssitecode=NKE ; PowerShell.exe -NoProfile -Command ""([wmiclass]'ROOT\ccm:SMS_Client').SetAssignedSite('NKE')"""
}

$App4=[PSCustomObject]@{
    AppName="Tanium"
    InstallCommand="msiexe /q  'TaniumClientInstaller 3211.msi'"
}

$AppMappingTable=@()
$AppMappingTable+=$App1
$AppMappingTable+=$App2
$AppMappingTable+=$App3
$AppMappingTable+=$App4
$AppMappingTable+=$App5
if ($appname -ne $null)
{
    foreach ($app in $AppMappingTable)
    {
        if ($app.AppName -eq $appname){
            $AppMappingTable=@()
            $AppMappingTable+=$app
        }
    }
}



foreach ($app in $AppMappingTable){
    Invoke-Command -ComputerName $ComputerName -Credential $SACredential -ScriptBlock {cd c:\ServerBuildAPP\$($args[0].appname);cmd /c $Args[0].InstallCommand} -ArgumentList $app1
}

}



<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Get ImpageProfile on an ESXi host
#>

# Define Variables
$Cluster = "Cluster"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

	Write-Host "`nPreparing $($_.Name) for esxcli" -F Yellow

	$esxcli = Get-EsxCli -VMHost $_ -V2

	# Get ImageProfile
	Write-Host "Checking ImageProfile on $($_.Name)" -F Yellow

	$action = ($esxcli.software.profile.get.Invoke()) | select acceptancelevel,creationtime,description,modificationtime,name,statelessready,vendor

	# Display ImageProfile information
	Write-Host "`nAcceptanceLevel	:	"	$action.AcceptanceLevel
	Write-Host "CreationTime	:	"	$action.CreationTime
	Write-Host "Description	:	"		$action.Description
	Write-Host "ModificationTime:	"	$action.ModificationTime
	Write-Host "Name		:	"		$action.Name
	Write-Host "StatelessReady	:	"	$action.StatelessReady
	Write-Host "VIBs		:	"		$action.VIBs
	Write-Host "Vendor		:	"		$action.Vendor
}

# Disconnect from vCenter
Disconnect-VIServer -Server * -Force -Confirm:$false

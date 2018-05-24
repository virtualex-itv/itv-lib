<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Install VIB on an ESXi host
#>

# Define Variables
$Cluster = "Cluster"
$vibname = "synonfs-vaai-plugin"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

	Write-Host "`nPreparing $($_.Name) for esxcli" -F Yellow

	$esxcli = Get-EsxCli -VMHost $_ -V2

	# List VIBs
	Write-Host "Listing VIB on $($_.Name)" -F Yellow

	$action = $esxcli.software.vib.list.Invoke() | where { $_.Name -like $vibname }

	# Display VIB information
	Write-Host "`nAcceptanceLevel	:	"	$action.AcceptanceLevel
	Write-Host "ID		:	"	$action.ID
	Write-Host "InstallDate	:	"	$action.InstallDate
	Write-Host "Name		:	"	$action.Name
	Write-Host "Status		:	"	$action.Status
	Write-Host "Vendor		:	"	$action.Vendor
	Write-Host "Version		:	"	$action.Version
}

# Disconnect from vCenter
Disconnect-VIServer -Server * -Force -Confirm:$false

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

    Write-host "Preparing $($_.Name) for ESXCLI" -F Yellow

    $ESXCLI = Get-EsxCli -VMHost $_ -V2

    # List VIBs
    Write-host "Listing VIB on $($_.Name)" -F Yellow
		
	$action = $ESXCLI.software.vib.list.Invoke() | where { $_.Name -like $vibname }
	
    # Display VIB information
	Write-Host ""
    Write-Host "AcceptanceLevel	:	"	$action.AcceptanceLevel
	Write-Host "ID		:	"	$action.ID
	Write-Host "InstallDate	:	"	$action.InstallDate
	Write-Host "Name		:	"	$action.Name
	Write-Host "Status		:	"	$action.Status
	Write-Host "Vendor		:	"	$action.Vendor
	Write-Host "Version		:	"	$action.Version
	Write-Host ""
}
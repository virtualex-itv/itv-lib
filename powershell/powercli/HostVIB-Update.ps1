<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Update VIB on an ESXi host
#>

# Define Variables
$Cluster = "Cluster"
$viburl = "http://download3.vmware.com/software/vmw-tools/esxui/esxui-signed-latest.vib"
#$viburl = "/vmfs/volumes/NFS01/Patches/VIBs/esxui-signed-latest.vib"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential
$nosigcheck = $true
$maintenancemode = $false
$force = $false
$dryrun = $false

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

    Write-Host "`nPreparing $($_.Name) for esxcli" -F Yellow

    $esxcli = Get-EsxCli -VMHost $_ -V2

    # Update VIBs
    Write-Host "Updating VIB on $($_.Name)" -F Yellow

		# Create Update Arguments
		$updParm = @{
			viburl = $viburl
			dryrun = $dryrun
			nosigcheck = $nosigcheck
			maintenancemode = $maintenancemode
			force = $force
		}

	$action = $esxcli.software.vib.update.Invoke($updParm)

	# Verify VIB updated successfully
	if ($action.Message -eq "Operation finished successfully."){Write-Host "Action Completed successfully on $($_.Name)" -F Green} else {Write-Host $action.Message -F Red}
}

<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Removes VIB on an ESXi host
#>

# Define Variables
$Cluster = "Cluster"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential
$vibname = "esx-nfsplugin"
$maintenancemode = $false
$force = $false
$dryrun = $false

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

    Write-host "Preparing $($_.Name) for ESXCLI" -F Yellow

    $ESXCLI = Get-EsxCli -VMHost $_ -V2

    # Install VIBs
    Write-host "Removing VIB from $($_.Name)" -F Yellow
		
		# Create Removal Arguments
		$remParm = @{
			vibname = $vibname
			maintenancemode = $maintenancemode
			force = $force
			dryrun = $dryrun
		}
	
	$action = $ESXCLI.software.vib.remove.Invoke($remParm)

    # Verify VIB removed successfully
    if ($action.Message -eq "Operation finished successfully."){Write-host "Action Completed successfully on $($_.Name)" -F Green} else {Write-host $action.Message -F Red}
}
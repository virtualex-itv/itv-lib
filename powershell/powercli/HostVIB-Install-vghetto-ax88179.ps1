<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Install vghetto-ax88179 VIB on an ESXi host and disable vmkusb module
#>

# Define Variables
$Cluster = "Cluster"
$viburl = "https://s3.amazonaws.com/virtuallyghetto-download/vghetto-ax88179-esxi65.vib"
#$viburl = "/vmfs/volumes/NFS01/Patches/VIBs/6.5/vghetto-ax88179-esxi65.vib"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential
$nosigcheck = $true
$maintenancemode = $false
$force = $true
$dryrun = $false

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

    Write-Host "`nPreparing $($_.Name) for esxcli" -F Yellow

    $esxcli = Get-EsxCli -VMHost $_ -V2

    # Install VIBs
    Write-Host "Installing VIB on $($_.Name)" -F Yellow

		# Create Installation Arguments
		$insParm = @{
			viburl = $viburl
			dryrun = $dryrun
			nosigcheck = $nosigcheck
			maintenancemode = $maintenancemode
			force = $force
		}

	$action = $esxcli.software.vib.install.Invoke($insParm)

	# Disable vmkusb module
	Write-Host "Disabling module on $($_.Name)" -F Yellow
	
		# Create Module Arguements
		$modParm = @{
			module = "vmkusb"
			enabled = $false
			force = $true
		}
	
	$modaction = $esxcli.system.module.set.Invoke($modParm)
	
	# Verify VIB installed successfully
	if ($action.Message -eq "Operation finished successfully."){Write-Host "Action Completed successfully on $($_.Name)" -F Green} else {Write-Host $action.Message -F Red}
}

# Disconnect from vCenter
Disconnect-VIServer -Server * -Force -Confirm:$false

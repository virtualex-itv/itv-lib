<#
    .NOTES
    ===========================================================================
     Created by:    Alex Lopez
     Organization:  iThinkVirtual
     Blog:          https://ithinkvirtual.com
     Twitter:       @iVirtuAlex
    ===========================================================================
    .DESCRIPTION
        Upgrade ImpageProfile on an ESXi host
#>

# Define Variables
$Cluster = "Cluster"
$vcenter = "vcsa.lab.edu"
$cred = Get-Credential
$depoturl = "https://hostupdate.vmware.com/software/VUM/PRODUCTION/main/vmw-depot-index.xml"
$profilename = "ESXi-6.5.0-20180304001-standard"
$allowdowngrades = $true
$nosigcheck = $false
$maintenancemode = $false
$force = $false
$dryrun = $false

# Connect to vCenter
Connect-VIServer -Server $vcenter -Credential $cred

# Get each host in specified cluster that meets criteria
Get-VMhost -Location $Cluster | where { $_.PowerState -eq "PoweredOn" -and $_.ConnectionState -eq "Connected" } | foreach {

    Write-host "Preparing $($_.Name) for ESXCLI" -F Yellow

    $ESXCLI = Get-EsxCli -VMHost $_ -V2

    # Update ImageProfile
    Write-host "Updating ImageProfile on $($_.Name)" -F Yellow
		
		# Create Firewall Arguments
		$enParm = @{
			enabled = $true
			rulesetid = "httpClient"
		}
		
		disParm = @{
			enabled = $false
			rulesetid = "httpClient"
		}
		
		# Create Update Arguments
		$updParm = @{
			allowdowngrades = $allowdowngrades
			depot = $depoturl
			profile = $profilename
			dryrun = $dryrun
			nosigcheck = $nosigcheck
			maintenancemode = $maintenancemode
			force = $force
		}
	
	$ESXCLI.network.firewall.ruleset.set.Invoke($enParm)
	
	$action = $ESXCLI.software.profile.update.Invoke($updParm)
	
	$ESXCLI.network.firewall.ruleset.set.Invoke($disParm)

    # Verify ImgageProfile updated successfully
    if ($action.Message -eq "Operation finished successfully."){Write-host "Action Completed successfully on $($_.Name)" -F Green} else {Write-host $action.Message -F Red}
}

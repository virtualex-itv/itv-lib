<#
		.NOTES
		==================================================================
			Created by:			Alex Lopez
			Organization:		iThinkVirtual
			Date:				10.27.2017		
		==================================================================
		.DESCRIPTION
				Installs the required Windows Roles/Features for System Center installation

#>

Write-host "Would you like to install the required Windows Features for a System Center Configuration Manager (Current Branch) installation on"$env:ComputerName"? (Default is No)" -F Yellow 

    $Readhost = Read-Host " ( y / n ) "

    Switch ($ReadHost) 

     { 
       
       Y { Write-Host "Installing the required Roles and Features on"$env:ComputerName", please wait..." -F Green

			Get-Module | Where-Object { $_.Name -eq 'ServerManager' } | FT -Autosize
			Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-Windows-Auth' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-ISAPI-Ext' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-Metabase' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-WMI' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'BITS' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'RDC' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'NET-Framework-Features' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-Asp-Net' } | Install-WindowsFeature | FT -Autosize
			Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-Asp-Net45' } | Install-WindowsFeature | FT -Autosize
			Get-WindowsFeature | Where-Object {$_.Name -eq 'Web-DAV-Publishing' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'NET-HTTP-Activation' } | Install-WindowsFeature | FT -Autosize
            Get-WindowsFeature | Where-Object {$_.Name -eq 'NET-Non-HTTP-Activ' } | Install-WindowsFeature | FT -Autosize
			
			Write-Host "OK, I'm done!" -F Green }
						
		    		 
       N { Write-Host "OK, run me again when you're ready..." -F Yellow }
        
       Default { Write-Host "OK, run me again when you're ready..." -F Yellow }

    }
 
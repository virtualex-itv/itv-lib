<#
		.NOTES
		==================================================================
			Created by:			Alex Lopez
			Organization:		iThinkVirtual
			Date:				10.27.2017		
		==================================================================
		.DESCRIPTION
				Installs the required Windows Roles/Features for Software Update Point installation

#>

Write-host "Would you like to install the required Windows Features for configuring a Software Update Point (WSUS) on"$env:ComputerName"? (Default is No)" -F Yellow
			
            $Readhost = Read-Host " ( y / n ) "

			Switch ($ReadHost) 

			 { 
			   
                Y { Write-Host "Installing the required Roles and Features on"$env:ComputerName", please wait..." -F Green
				
					Get-WindowsFeature | Where-Object {$_.Name -eq 'UpdateServices-Services' } | Install-WindowsFeature -IncludeManagementTools  | FT -Autosize
                    Get-WindowsFeature | Where-Object {$_.Name -eq 'UpdateServices-DB' } | Install-WindowsFeature -IncludeManagementTools | FT -Autosize
					
                    $WSUSDir = "D:\_Sources_\WSUS"
					
					If ( ! ( Test-Path $WSUSDir ) ) { New-Item -Path $WSUSDir  -Type Directory -force }
					
					cd "C:\Program Files\Update Services\Tools"
					
					#Display wsusutil help
					.\wsusutil postinstall /?
					
					#Configure WSUS DB Server and Content Directory
					.\wsusutil postinstall SQL_INSTANCE_NAME=$env:ComputerName CONTENT_DIR=$WSUSDir
					
					#Checks the configuration
					Invoke-BpaModel -ModelId Microsoft/Windows/UpdateServices
					
					Get-BpaResult -ModelId Microsoft/Windows/UpdateServices | Select Title,Severity,Compliance | FL
					
					Write-Host "Ok, I'm done!  Please perform the configuration steps by adding the Software Update Point role in System Center." -F Green }
					
				N { Write-Host "OK, then I'm done!" -F Yellow }
 
				Default { Write-Host "OK, then I'm done!" -F Yellow }

			    }
				
<#
.SYNOPSIS
    Checks available disk space on the system drive.

.DESCRIPTION
    This script verifies the available disk space on the Windows system drive and displays
    the percentage of free space remaining. It helps ensure that the system maintains at
    least 10% free space for optimal performance. After displaying the information, it
    opens File Explorer to show the drive details.

.NOTES
    - Requires administrator privileges to run
    - Automatically elevates privileges if not run as administrator
    - Opens File Explorer after displaying space information
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
{Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
Exit}
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
$Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

Write-Host "Maintain at least 10% free space"
$driveletter = $env:SystemDrive -replace ':', ''
$volume = Get-Volume $driveletter | Select-Object Size,SizeRemaining
$percentRemain = ($volume.SizeRemaining / $volume.Size) * 100
Write-Host "Free space =" "$($percentRemain.ToString().substring(0,4))%"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Start-Process explorer shell:MyComputerFolder

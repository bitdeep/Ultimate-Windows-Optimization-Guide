<#
.SYNOPSIS
    Enables or Disables MSI (Message Signaled Interrupt) Mode for GPU Devices

.DESCRIPTION
    This PowerShell script allows users to toggle MSI Mode for all display devices in the system.
    MSI Mode can potentially improve GPU interrupt handling and reduce system latency.

    - Option 1: Enables MSI Mode (Recommended for most systems)
    - Option 2: Disables MSI Mode

    The script requires administrative privileges and will prompt for elevation if not run as admin.
    Changes require a system restart to take effect.

.NOTES
    - Modifies Windows Registry
    - Affects all detected display devices
    - Requires careful use as it can impact system stability
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
    {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit}
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host

    Write-Host "1. Msi Mode: On (Recommended)"
    Write-Host "2. Msi Mode: Off"
    while ($true) {
    $choice = Read-Host " "
    if ($choice -match '^[1-2]$') {
    switch ($choice) {
    1 {

Clear-Host
# get all gpu driver ids
$gpuDevices = Get-PnpDevice -Class Display
foreach ($gpu in $gpuDevices) {
$instanceID = $gpu.InstanceId
# enable msi mode for all gpus regedit
reg add "HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f | Out-Null
}
# display msi mode for all gpus
foreach ($gpu in $gpuDevices) {
$instanceID = $gpu.InstanceId
$regPath = "Registry::HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
try {
$msiSupported = Get-ItemProperty -Path $regPath -Name "MSISupported" -ErrorAction Stop
Write-Output "$instanceID"
Write-Output "MSISupported: $($msiSupported.MSISupported)"
} catch {
Write-Output "$instanceID"
Write-Output "MSISupported: Not found or error accessing the registry."
}
}
Write-Host ""
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    2 {

Clear-Host
# get all gpu driver ids
$gpuDevices = Get-PnpDevice -Class Display
foreach ($gpu in $gpuDevices) {
$instanceID = $gpu.InstanceId
# disable msi mode for all gpus regedit
reg add "HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "0" /f | Out-Null
}
# display msi mode for all gpus
foreach ($gpu in $gpuDevices) {
$instanceID = $gpu.InstanceId
$regPath = "Registry::HKLM\SYSTEM\ControlSet001\Enum\$instanceID\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
try {
$msiSupported = Get-ItemProperty -Path $regPath -Name "MSISupported" -ErrorAction Stop
Write-Output "$instanceID"
Write-Output "MSISupported: $($msiSupported.MSISupported)"
} catch {
Write-Output "$instanceID"
Write-Output "MSISupported: Not found or error accessing the registry."
}
}
Write-Host ""
Write-Host "Restart to apply . . ."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit

      }
    } } else { Write-Host "Invalid input. Please select a valid option (1-2)." } }

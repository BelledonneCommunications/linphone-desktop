param(
	[Parameter(Mandatory = $true)][string]$Msi,
	[Parameter(Mandatory = $true)][string]$Transform,
	[Parameter(Mandatory = $true)][int]$Language
)
$ErrorActionPreference = "Stop"

function Invoke-Com($Target, [string]$Name, [System.Reflection.BindingFlags]$Kind, [object[]]$Arguments = @()) {
	return $Target.GetType().InvokeMember($Name, $Kind, $null, $Target, $Arguments)
}

$method = [System.Reflection.BindingFlags]::InvokeMethod
$get = [System.Reflection.BindingFlags]::GetProperty
$set = [System.Reflection.BindingFlags]::SetProperty
$objects = New-Object System.Collections.ArrayList
try {
	$installer = New-Object -ComObject WindowsInstaller.Installer
	[void]$objects.Add($installer)
	$database = Invoke-Com $installer "OpenDatabase" $method @((Resolve-Path $Msi).Path, 1)
	[void]$objects.Add($database)
	$view = Invoke-Com $database "OpenView" $method @("SELECT ``Name``, ``Data`` FROM ``_Storages``")
	[void]$objects.Add($view)
	[void](Invoke-Com $view "Execute" $method)
	$record = Invoke-Com $installer "CreateRecord" $method @(2)
	[void]$objects.Add($record)
	[void](Invoke-Com $record "StringData" $set @(1, [string]$Language))
	[void](Invoke-Com $record "SetStream" $method @(2, (Resolve-Path $Transform).Path))
	[void](Invoke-Com $view "Modify" $method @(3, $record))
	[void](Invoke-Com $view "Close" $method)
	$summary = Invoke-Com $database "SummaryInformation" $get @(1)
	[void]$objects.Add($summary)
	$template = [string](Invoke-Com $summary "Property" $get @(7))
	$parts = $template.Split(";", 2)
	$languages = New-Object System.Collections.ArrayList
	if ($parts.Count -eq 2) { foreach ($value in $parts[1].Split(",")) { if ($value.Trim()) { [void]$languages.Add($value.Trim()) } } }
	if (-not $languages.Contains([string]$Language)) { [void]$languages.Add([string]$Language) }
	[void](Invoke-Com $summary "Property" $set @(7, "$($parts[0]);$($languages -join ',')"))
	[void](Invoke-Com $summary "Persist" $method)
	[void](Invoke-Com $database "Commit" $method)
	Write-Output "Template: $($parts[0]);$($languages -join ',')"
} finally {
	for ($i = $objects.Count - 1; $i -ge 0; $i--) {
		[void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($objects[$i])
	}
	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
}

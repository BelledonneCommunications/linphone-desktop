param(
	[Parameter(Mandatory = $true)][string]$Msi,
	[string]$NsisInstaller = "",
	[ValidateSet("Basic", "Full")][string]$Suite = "Full",
	[string]$WorkDir = (Join-Path $env:TEMP "linphone-msi-tests"),
	[string]$JUnit = "",
	[string[]]$Only = @(),
	[switch]$UninstallExisting
)
$ErrorActionPreference = "Stop"
$Only = @($Only | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim().Trim('"') } | Where-Object { $_ })

$ComMethod = [System.Reflection.BindingFlags]::InvokeMethod
$ComGet = [System.Reflection.BindingFlags]::GetProperty
$ComSet = [System.Reflection.BindingFlags]::SetProperty
$script:Results = New-Object System.Collections.ArrayList
$script:MsiRun = 0

function Invoke-Com($Target, [string]$Name, [System.Reflection.BindingFlags]$Kind, [object[]]$Arguments = @()) {
	return $Target.GetType().InvokeMember($Name, $Kind, $null, $Target, $Arguments)
}

function Remove-Com([object[]]$Objects) {
	foreach ($object in $Objects) {
		if ($null -ne $object) { [void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($object) }
	}
	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
}

function Get-MsiTable([string]$Path, [string]$Query, [int]$Columns) {
	$installer = New-Object -ComObject WindowsInstaller.Installer
	$database = Invoke-Com $installer "OpenDatabase" $ComMethod @($Path, 0)
	$view = Invoke-Com $database "OpenView" $ComMethod @($Query)
	[void](Invoke-Com $view "Execute" $ComMethod)
	$rows = New-Object System.Collections.ArrayList
	while ($true) {
		$record = Invoke-Com $view "Fetch" $ComMethod
		if ($null -eq $record) { break }
		$row = New-Object string[] $Columns
		for ($column = 0; $column -lt $Columns; $column++) {
			$row[$column] = [string](Invoke-Com $record "StringData" $ComGet @($column + 1))
		}
		[void]$rows.Add($row)
		[void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($record)
	}
	[void](Invoke-Com $view "Close" $ComMethod)
	Remove-Com @($view, $database, $installer)
	return $rows
}

function Get-MsiTemplate([string]$Path) {
	$installer = New-Object -ComObject WindowsInstaller.Installer
	$summary = Invoke-Com $installer "SummaryInformation" $ComGet @($Path, 0)
	$template = [string](Invoke-Com $summary "Property" $ComGet @(7))
	Remove-Com @($summary, $installer)
	return $template
}

function New-MsiVariant([string]$Source, [string]$Target, [string]$Version) {
	Copy-Item -LiteralPath $Source -Destination $Target -Force
	$productCode = "{" + [guid]::NewGuid().ToString().ToUpperInvariant() + "}"
	$packageCode = "{" + [guid]::NewGuid().ToString().ToUpperInvariant() + "}"
	$installer = New-Object -ComObject WindowsInstaller.Installer
	$database = Invoke-Com $installer "OpenDatabase" $ComMethod @($Target, 1)
	$updates = @(
		("UPDATE ``Property`` SET ``Value`` = '" + $Version + "' WHERE ``Property`` = 'ProductVersion'"),
		("UPDATE ``Property`` SET ``Value`` = '" + $productCode + "' WHERE ``Property`` = 'ProductCode'"),
		"DELETE FROM ``_Storages``"
	)
	foreach ($query in $updates) {
		$view = Invoke-Com $database "OpenView" $ComMethod @($query)
		[void](Invoke-Com $view "Execute" $ComMethod)
		[void](Invoke-Com $view "Close" $ComMethod)
		[void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($view)
	}
	$summary = Invoke-Com $database "SummaryInformation" $ComGet @(2)
	$platform = ([string](Invoke-Com $summary "Property" $ComGet @(7))).Split(";")[0]
	[void](Invoke-Com $summary "Property" $ComSet @(7, ($platform + ";" + $script:BaseLanguage)))
	[void](Invoke-Com $summary "Property" $ComSet @(9, $packageCode))
	[void](Invoke-Com $summary "Persist" $ComMethod)
	[void](Invoke-Com $database "Commit" $ComMethod)
	Remove-Com @($summary, $database, $installer)
}

function Get-ShiftedVersion([string]$Version, [int]$Direction) {
	$parts = @($Version.Split(".") | ForEach-Object { [int]$_ })
	while ($parts.Count -lt 3) { $parts += 0 }
	$major = $parts[0]
	$minor = $parts[1]
	$build = $parts[2]
	if ($Direction -gt 0) {
		if ($build -lt 65535) { $build++ }
		elseif ($minor -lt 255) { $minor++; $build = 0 }
		else { $major++; $minor = 0; $build = 0 }
	} else {
		if ($build -gt 0) { $build-- }
		elseif ($minor -gt 0) { $minor--; $build = 65535 }
		elseif ($major -gt 0) { $major--; $minor = 255; $build = 65535 }
		else { throw "Cannot build a version lower than $Version." }
	}
	return "$major.$minor.$build"
}

function Invoke-Process([string]$FilePath, [string]$Arguments, [int]$TimeoutSeconds = 1200) {
	$info = New-Object System.Diagnostics.ProcessStartInfo
	$info.FileName = $FilePath
	$info.Arguments = $Arguments
	$info.UseShellExecute = $false
	$process = [System.Diagnostics.Process]::Start($info)
	if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
		$process.Kill()
		throw "$FilePath $Arguments did not finish within $TimeoutSeconds seconds."
	}
	return $process.ExitCode
}

function Invoke-Msiexec([string]$Arguments, [string]$Name, [switch]$NoLog) {
	$script:MsiRun++
	$log = Join-Path $script:LogDir ("{0:D3}-{1}.log" -f $script:MsiRun, $Name)
	$commandLine = "$Arguments /norestart"
	if (-not $NoLog) { $commandLine += " /l*v `"$log`"" }
	$deadline = (Get-Date).AddMinutes(3)
	while ($true) {
		$code = Invoke-Process "$env:SystemRoot\System32\msiexec.exe" $commandLine
		if ($code -ne 1618 -or (Get-Date) -gt $deadline) { break }
		Start-Sleep -Seconds 5
	}
	Write-Host "    msiexec $commandLine -> $code"
	return [pscustomobject]@{ Code = $code; Log = $log }
}

function Invoke-MsiexecAsSystem([string]$Arguments, [string]$Name) {
	$script:MsiRun++
	$log = Join-Path $script:LogDir ("{0:D3}-{1}.log" -f $script:MsiRun, $Name)
	$exitFile = Join-Path $WorkDir "system-exit.txt"
	$commandFile = Join-Path $WorkDir "system-msiexec.cmd"
	Remove-Item -LiteralPath $exitFile -Force -ErrorAction SilentlyContinue
	Remove-Item -LiteralPath "$exitFile.tmp" -Force -ErrorAction SilentlyContinue
	Set-Content -LiteralPath $commandFile -Encoding ASCII -Value ("@`"$env:SystemRoot\System32\msiexec.exe`" $Arguments /norestart /l*v `"$log`"`r`n@echo %ERRORLEVEL% > `"$exitFile.tmp`"`r`n@move /y `"$exitFile.tmp`" `"$exitFile`" > nul")
	$task = "$($script:AppName) MSI tests"
	$action = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\cmd.exe" -Argument "/c `"`"$commandFile`"`""
	$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
	Register-ScheduledTask -TaskName $task -Action $action -Principal $principal -Force | Out-Null
	try {
		Start-ScheduledTask -TaskName $task
		$deadline = (Get-Date).AddMinutes(20)
		while (-not (Test-Path -LiteralPath $exitFile) -and (Get-Date) -lt $deadline) { Start-Sleep -Seconds 2 }
	} finally {
		Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction SilentlyContinue
	}
	Assert-True (Test-Path -LiteralPath $exitFile) "msiexec run as SYSTEM finished within 20 minutes"
	$code = [int]([string](Get-Content -LiteralPath $exitFile -Raw)).Trim()
	Write-Host "    msiexec (SYSTEM) $Arguments -> $code"
	return [pscustomobject]@{ Code = $code; Log = $log }
}

function Get-LogText([string]$Path) {
	if (-not (Test-Path -LiteralPath $Path)) { return "" }
	return [string](Get-Content -LiteralPath $Path -Raw)
}

function Assert-True($Condition, [string]$Message) {
	if (-not $Condition) { throw "Assertion failed: $Message" }
}

function Assert-Equal($Expected, $Actual, [string]$Message) {
	if ($Expected -ne $Actual) { throw "Assertion failed: $Message (expected '$Expected', got '$Actual')" }
}

function Assert-ExitCode($Expected, $Run) {
	if ($Run.Code -ne $Expected) {
		$tail = ""
		if (Test-Path -LiteralPath $Run.Log) {
			$tail = (Get-Content -LiteralPath $Run.Log | Select-String -Pattern "Return value 3|Valeur renvoy.e 3|Error \d{4}|Erreur \d{4}" | Select-Object -First 10 | ForEach-Object { $_.Line }) -join "`n"
		}
		throw "Assertion failed: msiexec exit code (expected $Expected, got $($Run.Code)), log $($Run.Log)`n$tail"
	}
}

function Skip-Test([string]$Reason) {
	throw "SKIP: $Reason"
}

function Get-UninstallEntries {
	$entries = New-Object System.Collections.ArrayList
	foreach ($view in @([Microsoft.Win32.RegistryView]::Registry64, [Microsoft.Win32.RegistryView]::Registry32)) {
		$base = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $view)
		$root = $base.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")
		if ($null -ne $root) {
			foreach ($name in $root.GetSubKeyNames()) {
				$key = $root.OpenSubKey($name)
				if ($null -eq $key) { continue }
				if ([string]$key.GetValue("DisplayName") -eq $script:AppName) {
					[void]$entries.Add([pscustomobject]@{
						Name = $name
						View = $view
						Version = [string]$key.GetValue("DisplayVersion")
						Msi = ([int]$key.GetValue("WindowsInstaller", 0) -eq 1)
						Uninstaller = [string]$key.GetValue("UninstallString")
					})
				}
				$key.Close()
			}
			$root.Close()
		}
		$base.Close()
	}
	return $entries
}

function Get-RelatedProductCodes {
	$installer = New-Object -ComObject WindowsInstaller.Installer
	$codes = New-Object System.Collections.ArrayList
	foreach ($code in @(Invoke-Com $installer "RelatedProducts" $ComGet @($script:UpgradeCode))) {
		if ($code) { [void]$codes.Add([string]$code) }
	}
	Remove-Com @($installer)
	return $codes
}

function Get-AppProcesses {
	return @(Get-Process -Name $script:ExeBase -ErrorAction SilentlyContinue)
}

function Stop-App {
	foreach ($process in Get-AppProcesses) {
		Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
		[void]$process.WaitForExit(10000)
	}
}

function Remove-Tree([string]$Path) {
	if (-not (Test-Path -LiteralPath $Path)) { return }
	for ($attempt = 0; $attempt -lt 10; $attempt++) {
		try {
			Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
			return
		} catch {
			Start-Sleep -Seconds 2
		}
	}
	Remove-Item -LiteralPath $Path -Recurse -Force
}

function Uninstall-Nsis {
	foreach ($entry in @(Get-UninstallEntries)) {
		if ($entry.Msi) { continue }
		$uninstaller = $entry.Uninstaller.Trim('"')
		if ($uninstaller -and (Test-Path -LiteralPath $uninstaller)) {
			$directory = Split-Path -Parent $uninstaller
			[void](Invoke-Process $uninstaller "/S _?=$directory" 600)
			Remove-Tree $directory
		}
		$base = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $entry.View)
		$base.DeleteSubKeyTree("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + $entry.Name, $false)
		$base.Close()
	}
	foreach ($folder in @(Get-ChildItem -LiteralPath $script:CommonPrograms -Directory -Filter "$($script:AppName) *" -ErrorAction SilentlyContinue)) {
		Remove-Tree $folder.FullName
	}
}

function Remove-UserData {
	Remove-Tree $script:LocalData
	Remove-Tree $script:RoamingData
	foreach ($key in @($script:SettingsKey, $script:AumidKey)) {
		if (Test-Path -LiteralPath $key) { Remove-Item -LiteralPath $key -Recurse -Force }
	}
	Remove-ItemProperty -LiteralPath $script:RunKey -Name $script:ExeBase -ErrorAction SilentlyContinue
}

function Reset-Environment {
	Stop-App
	foreach ($code in @(Get-RelatedProductCodes)) {
		$run = Invoke-Msiexec "/x $code /qn PURGE=0" "reset-uninstall"
		if ($run.Code -ne 0 -and $run.Code -ne 3010 -and $run.Code -ne 1605) { throw "Cannot uninstall $code (exit code $($run.Code))." }
	}
	Uninstall-Nsis
	Stop-App
	Remove-Tree $script:TestRoot
	Remove-Tree $script:DefaultInstallDir
	Remove-UserData
}

function Backup-UserState {
	$script:BackupDir = Join-Path $WorkDir "user-backup"
	if (Test-Path -LiteralPath $script:BackupDir) {
		throw "A previous run left the user data backup $($script:BackupDir). Restore it by hand before running the tests again."
	}
	[void](New-Item -ItemType Directory -Path $script:BackupDir)
	if (Test-Path -LiteralPath $script:LocalData) { Move-Item -LiteralPath $script:LocalData -Destination (Join-Path $script:BackupDir "local") }
	if (Test-Path -LiteralPath $script:RoamingData) { Move-Item -LiteralPath $script:RoamingData -Destination (Join-Path $script:BackupDir "roaming") }
	$index = 0
	foreach ($key in $script:BackupKeys) {
		$index++
		if (Test-Path -LiteralPath ("Registry::" + $key)) {
			$exported = Invoke-Process "$env:SystemRoot\System32\reg.exe" "export `"$key`" `"$(Join-Path $script:BackupDir "key$index.reg")`" /y" 60
			if ($exported -ne 0) { throw "Cannot back up $key." }
		}
	}
	$run = (Get-ItemProperty -LiteralPath $script:RunKey -Name $script:ExeBase -ErrorAction SilentlyContinue)
	if ($null -ne $run) { Set-Content -LiteralPath (Join-Path $script:BackupDir "run.txt") -Value $run.($script:ExeBase) -Encoding UTF8 }
}

function Restore-UserState {
	if (-not $script:BackupDir -or -not (Test-Path -LiteralPath $script:BackupDir)) { return }
	Remove-UserData
	if (Test-Path -LiteralPath (Join-Path $script:BackupDir "local")) { Move-Item -LiteralPath (Join-Path $script:BackupDir "local") -Destination $script:LocalData }
	if (Test-Path -LiteralPath (Join-Path $script:BackupDir "roaming")) { Move-Item -LiteralPath (Join-Path $script:BackupDir "roaming") -Destination $script:RoamingData }
	foreach ($file in @(Get-ChildItem -LiteralPath $script:BackupDir -Filter "key*.reg")) {
		$imported = Invoke-Process "$env:SystemRoot\System32\reg.exe" "import `"$($file.FullName)`"" 60
		if ($imported -ne 0) { throw "Cannot restore $($file.FullName)." }
	}
	$runFile = Join-Path $script:BackupDir "run.txt"
	if (Test-Path -LiteralPath $runFile) {
		Set-ItemProperty -LiteralPath $script:RunKey -Name $script:ExeBase -Value ([string](Get-Content -LiteralPath $runFile -Raw)).Trim()
	}
	Remove-Item -LiteralPath $script:BackupDir -Recurse -Force
}

function New-UserData([string]$InstallDir) {
	[void](New-Item -ItemType Directory -Force -Path (Join-Path $script:LocalData "logs"))
	[void](New-Item -ItemType Directory -Force -Path $script:RoamingData)
	$random = New-Object System.Random
	foreach ($name in @("linphone.db", "lime.db", "linphonerc", "logs\linphone1.log")) {
		$bytes = New-Object byte[] 65536
		$random.NextBytes($bytes)
		[System.IO.File]::WriteAllBytes((Join-Path $script:LocalData $name), $bytes)
	}
	Set-Content -LiteralPath (Join-Path $script:RoamingData "roaming.txt") -Value ([guid]::NewGuid().ToString())
	[void](New-Item -Force -Path $script:SettingsKey)
	Set-ItemProperty -LiteralPath $script:SettingsKey -Name "TestMarker" -Value "1"
	[void](New-Item -Force -Path $script:AumidKey)
	Set-ItemProperty -LiteralPath $script:AumidKey -Name "DisplayName" -Value $script:AppName
	Set-ItemProperty -LiteralPath $script:RunKey -Name $script:ExeBase -Value ("`"" + (Join-Path $InstallDir "bin\$($script:ExeName)") + "`" --minimized")
	return Get-UserDataSnapshot
}

function Get-UserDataSnapshot {
	$snapshot = @{}
	foreach ($root in @($script:LocalData, $script:RoamingData)) {
		foreach ($file in @(Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue)) {
			$snapshot[$file.FullName] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
		}
	}
	return $snapshot
}

function Assert-UserDataIntact($Snapshot) {
	Assert-True ($Snapshot.Count -gt 0) "user data snapshot is not empty"
	foreach ($path in $Snapshot.Keys) {
		Assert-True (Test-Path -LiteralPath $path) "user file $path still exists"
		Assert-Equal $Snapshot[$path] (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash "content of $path"
	}
	Assert-True (Test-Path -LiteralPath $script:SettingsKey) "settings key $($script:SettingsKey) still exists"
	Assert-True (Test-Path -LiteralPath $script:AumidKey) "notification key $($script:AumidKey) still exists"
	Assert-True ($null -ne (Get-ItemProperty -LiteralPath $script:RunKey -Name $script:ExeBase -ErrorAction SilentlyContinue)) "autostart entry still exists"
}

function Assert-UserDataRemoved {
	Assert-True (-not (Test-Path -LiteralPath $script:LocalData)) "$($script:LocalData) removed"
	Assert-True (-not (Test-Path -LiteralPath $script:RoamingData)) "$($script:RoamingData) removed"
	Assert-True (-not (Test-Path -LiteralPath $script:SettingsKey)) "settings key removed"
	Assert-True (-not (Test-Path -LiteralPath $script:AumidKey)) "notification key removed"
	Assert-True ($null -eq (Get-ItemProperty -LiteralPath $script:RunKey -Name $script:ExeBase -ErrorAction SilentlyContinue)) "autostart entry removed"
}

function Get-ShortcutTarget([string]$Path) {
	$shell = New-Object -ComObject WScript.Shell
	$target = $shell.CreateShortcut($Path).TargetPath
	[void][System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($shell)
	return $target
}

function Get-RegistryDefault([string]$Path) {
	$item = Get-ItemProperty -LiteralPath $Path -ErrorAction SilentlyContinue
	if ($null -eq $item) { return $null }
	return $item."(default)"
}

function Assert-Installed([string]$InstallDir, [string]$Version) {
	$directory = $InstallDir.TrimEnd("\")
	$entries = @(Get-UninstallEntries)
	$msiEntries = @($entries | Where-Object { $_.Msi })
	Assert-Equal 1 $msiEntries.Count "number of MSI uninstall entries"
	Assert-Equal 0 @($entries | Where-Object { -not $_.Msi }).Count "number of NSIS uninstall entries"
	Assert-Equal $Version $msiEntries[0].Version "installed version"
	$exe = Join-Path $directory "bin\$($script:ExeName)"
	Assert-True (Test-Path -LiteralPath $exe) "$exe exists"
	$files = @(Get-ChildItem -LiteralPath $directory -Recurse -File -Force).Count
	Assert-Equal $script:PayloadCount $files "number of installed files in $directory"
	Assert-Equal "$directory\" (Get-ItemProperty -LiteralPath $script:VendorKey -Name "InstallDir").InstallDir "InstallDir registry value"
	Assert-Equal "`"$exe`" `"%1`"" (Get-RegistryDefault "Registry::HKEY_CLASSES_ROOT\$($script:AppName).sip\Shell\Open\Command") "sip: handler command"
	Assert-Equal "URL:sip Protocol" (Get-RegistryDefault "Registry::HKEY_CLASSES_ROOT\sip") "sip: protocol declaration"
	$shortcut = Join-Path $script:CommonPrograms "$($script:AppName)\$($script:AppName).lnk"
	Assert-True (Test-Path -LiteralPath $shortcut) "$shortcut exists"
	Assert-Equal $exe (Get-ShortcutTarget $shortcut) "shortcut target"
	Assert-Equal 0 @(Get-ChildItem -LiteralPath $script:CommonPrograms -Directory -Filter "$($script:AppName) *" -ErrorAction SilentlyContinue).Count "leftover NSIS Start menu folders"
	Assert-True (-not (Test-Path -LiteralPath (Join-Path $directory "Uninstall.exe"))) "no NSIS uninstaller left"
}

function Assert-NotInstalled([string]$InstallDir) {
	Assert-Equal 0 @(Get-UninstallEntries).Count "number of uninstall entries"
	Assert-Equal 0 @(Get-RelatedProductCodes).Count "number of installed products"
	Assert-True (-not (Test-Path -LiteralPath $InstallDir)) "$InstallDir removed"
	Assert-True (-not (Test-Path -LiteralPath "Registry::HKEY_CLASSES_ROOT\$($script:AppName).sip")) "sip: handler removed"
	Assert-True ($null -eq (Get-ItemProperty -LiteralPath $script:VendorKey -Name "InstallDir" -ErrorAction SilentlyContinue)) "InstallDir registry value removed"
	Assert-True (-not (Test-Path -LiteralPath (Join-Path $script:CommonPrograms $script:AppName))) "Start menu folder removed"
}

function Assert-Interactive {
	if (-not $script:Interactive) { Skip-Test "needs an interactive desktop session (the runner runs in session 0)" }
}

function Start-App([string]$InstallDir, [switch]$Legacy) {
	$exe = Join-Path $InstallDir.TrimEnd("\") "bin\$($script:ExeName)"
	$process = Start-Process -FilePath $exe -PassThru
	$deadline = (Get-Date).AddSeconds(90)
	$ready = $false
	while (-not $ready -and (Get-Date) -lt $deadline) {
		Start-Sleep -Milliseconds 500
		if ($process.HasExited) { throw "$exe exited during startup with code $($process.ExitCode)." }
		if ($Legacy) {
			$process.Refresh()
			$ready = $process.MainWindowHandle -ne [IntPtr]::Zero
		} else {
			$handle = $null
			$ready = [System.Threading.EventWaitHandle]::TryOpenExisting("Global\$($script:QuitEventPrefix)$($process.Id)", [ref]$handle)
			if ($ready) { $handle.Dispose() }
		}
	}
	Assert-True $ready "$exe is ready within 90 seconds"
	Start-Sleep -Seconds 3
	return $process
}

function Wait-Relaunched([string]$InstallDir, [datetime]$After, [int]$Seconds = 60) {
	$exe = Join-Path $InstallDir.TrimEnd("\") "bin\$($script:ExeName)"
	$deadline = (Get-Date).AddSeconds($Seconds)
	while ((Get-Date) -lt $deadline) {
		$found = @(Get-AppProcesses | Where-Object { $_.StartTime -ge $After -and $_.Path -eq $exe })
		if ($found.Count -gt 0) { return $found[0] }
		Start-Sleep -Seconds 1
	}
	return $null
}

function Install-Nsis([string]$Directory = "") {
	if (-not $NsisInstaller) { Skip-Test "no NSIS reference installer given (-NsisInstaller)" }
	$arguments = "/S"
	if ($Directory) { $arguments += " /D=$Directory" }
	Assert-Equal 0 (Invoke-Process $NsisInstaller $arguments 900) "NSIS installer exit code"
	Assert-Equal 1 @(Get-UninstallEntries | Where-Object { -not $_.Msi }).Count "NSIS uninstall entry"
}

function Invoke-Test([string]$Name, [string[]]$Suites, [scriptblock]$Body) {
	if ($Suites -notcontains $Suite) { return }
	if ($Only.Count -gt 0 -and -not ($Only | Where-Object { $Name -like $_ })) { return }
	Write-Host "=== $Name"
	$started = Get-Date
	$status = "passed"
	$message = ""
	try {
		Reset-Environment
		& $Body
	} catch {
		$text = $_.Exception.Message
		if ($text.StartsWith("SKIP: ")) {
			$status = "skipped"
			$message = $text.Substring(6)
		} else {
			$status = "failed"
			$message = "$text`n$($_.InvocationInfo.PositionMessage)"
		}
	}
	try {
		Reset-Environment
	} catch {
		if ($status -ne "failed") {
			$status = "failed"
			$message = "Cleanup failed: $($_.Exception.Message)"
		}
	}
	$seconds = [Math]::Round(((Get-Date) - $started).TotalSeconds, 1)
	[void]$script:Results.Add([pscustomobject]@{ Name = $Name; Status = $status; Message = $message; Seconds = $seconds })
	Write-Host ("--- {0}: {1} ({2}s) {3}" -f $Name, $status.ToUpperInvariant(), $seconds, $message)
}

function Write-JUnit([string]$Path) {
	$document = New-Object System.Xml.XmlDocument
	$suiteNode = $document.CreateElement("testsuite")
	$suiteNode.SetAttribute("name", "msi-installer-$($Suite.ToLowerInvariant())")
	$suiteNode.SetAttribute("tests", [string]$script:Results.Count)
	$suiteNode.SetAttribute("failures", [string]@($script:Results | Where-Object { $_.Status -eq "failed" }).Count)
	$suiteNode.SetAttribute("skipped", [string]@($script:Results | Where-Object { $_.Status -eq "skipped" }).Count)
	$suiteNode.SetAttribute("time", [string](($script:Results | Measure-Object -Property Seconds -Sum).Sum))
	foreach ($result in $script:Results) {
		$case = $document.CreateElement("testcase")
		$case.SetAttribute("classname", "msi.$($Suite.ToLowerInvariant())")
		$case.SetAttribute("name", $result.Name)
		$case.SetAttribute("time", [string]$result.Seconds)
		if ($result.Status -eq "failed") {
			$failure = $document.CreateElement("failure")
			$failure.SetAttribute("message", ($result.Message -split "`n")[0])
			$failure.InnerText = $result.Message
			[void]$case.AppendChild($failure)
		} elseif ($result.Status -eq "skipped") {
			$skipped = $document.CreateElement("skipped")
			$skipped.SetAttribute("message", $result.Message)
			[void]$case.AppendChild($skipped)
		}
		[void]$suiteNode.AppendChild($case)
	}
	[void]$document.AppendChild($suiteNode)
	$document.Save($Path)
}

$principal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
	throw "The MSI tests must run elevated."
}
$Msi = (Resolve-Path -LiteralPath $Msi).Path
if ($NsisInstaller) { $NsisInstaller = (Resolve-Path -LiteralPath $NsisInstaller).Path }
[void](New-Item -ItemType Directory -Force -Path $WorkDir)
$WorkDir = (Resolve-Path -LiteralPath $WorkDir).Path
$script:LogDir = Join-Path $WorkDir "logs"
Remove-Tree $script:LogDir
[void](New-Item -ItemType Directory -Force -Path $script:LogDir)

$properties = @{}
foreach ($row in @(Get-MsiTable $Msi "SELECT ``Property``, ``Value`` FROM ``Property``" 2)) { $properties[$row[0]] = $row[1] }
$script:AppName = $properties["LINPHONE_APP_NAME"]
$script:ExeName = $properties["LINPHONE_EXE_NAME"]
$script:ExeBase = [System.IO.Path]::GetFileNameWithoutExtension($script:ExeName)
$script:QuitEventPrefix = $properties["LINPHONE_QUIT_EVENT"]
$script:Vendor = $properties["Manufacturer"]
$script:UpgradeCode = $properties["UpgradeCode"]
$script:BaseVersion = $properties["ProductVersion"]
$script:BaseLanguage = $properties["ProductLanguage"]
$script:Languages = @(((Get-MsiTemplate $Msi).Split(";") | Select-Object -Last 1).Split(",") | Where-Object { $_ })
$script:PayloadCount = @(Get-MsiTable $Msi "SELECT ``File`` FROM ``File``" 1).Count
$script:DefaultInstallDir = Join-Path $env:ProgramFiles $script:AppName
$script:TestRoot = Join-Path $env:SystemDrive "$($script:AppName) MSI Tests"
$script:CommonPrograms = [Environment]::GetFolderPath("CommonPrograms")
$script:VendorKey = "HKLM:\SOFTWARE\$($script:Vendor)\$($script:AppName)"
$script:LocalData = Join-Path $env:LOCALAPPDATA $script:ExeBase
$script:RoamingData = Join-Path $env:APPDATA $script:ExeBase
$script:SettingsKey = "HKCU:\Software\$($script:Vendor)\$($script:AppName)"
$script:AumidKey = "HKCU:\Software\Classes\AppUserModelId\$($script:AppName)"
$script:RunKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$script:BackupKeys = @("HKCU\Software\$($script:Vendor)\$($script:AppName)", "HKCU\Software\Classes\AppUserModelId\$($script:AppName)")
$script:Interactive = ((Get-Process -Id $PID).SessionId -ne 0) -and [Environment]::UserInteractive
foreach ($name in @("AppName", "ExeName", "QuitEventPrefix", "Vendor", "UpgradeCode", "BaseVersion", "BaseLanguage")) {
	if (-not (Get-Variable -Name $name -Scope Script -ValueOnly)) { throw "Cannot read $name from $Msi." }
}

Write-Host "Package     : $Msi"
Write-Host "Product     : $($script:AppName) $($script:BaseVersion) ($($script:Vendor)), languages $($script:Languages -join ',')"
Write-Host "Payload     : $($script:PayloadCount) files"
Write-Host "NSIS        : $(if ($NsisInstaller) { $NsisInstaller } else { 'none' })"
Write-Host "Interactive : $($script:Interactive)"
Write-Host "Logs        : $($script:LogDir)"

$existing = @(Get-RelatedProductCodes).Count + @(Get-UninstallEntries).Count
if ($existing -gt 0 -and -not $UninstallExisting) {
	throw "$($script:AppName) is already installed on this machine. Uninstall it first or pass -UninstallExisting."
}
if (Get-AppProcesses) { throw "$($script:ExeName) is running. Close it before running the tests." }

$script:UpVersion = Get-ShiftedVersion $script:BaseVersion 1
$script:DownVersion = Get-ShiftedVersion $script:BaseVersion -1
$script:BaseMsi = Join-Path $WorkDir "base.msi"
$script:UpMsi = Join-Path $WorkDir "upgrade.msi"
$script:DownMsi = Join-Path $WorkDir "downgrade.msi"
$script:RebuildMsi = Join-Path $WorkDir "rebuild.msi"
New-MsiVariant $Msi $script:BaseMsi $script:BaseVersion
New-MsiVariant $Msi $script:UpMsi $script:UpVersion
New-MsiVariant $Msi $script:DownMsi $script:DownVersion
New-MsiVariant $Msi $script:RebuildMsi $script:BaseVersion

Backup-UserState
try {
	Invoke-Test "Install.Silent" @("Basic", "Full") {
		$run = Invoke-Msiexec "/i `"$Msi`" /qn" "install"
		Assert-ExitCode 0 $run
		Assert-True ((Get-LogText $run.Log) -match "MainEngineThread is returning 0") "log $($run.Log) reports success"
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
	}

	Invoke-Test "Uninstall.Silent.KeepsUserData" @("Basic", "Full") {
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "install")
		$snapshot = New-UserData $script:DefaultInstallDir
		$productCode = @(Get-RelatedProductCodes)[0]
		$run = Invoke-Msiexec "/x $productCode /qn" "uninstall"
		Assert-ExitCode 0 $run
		Assert-True ((Get-LogText $run.Log) -match "MainEngineThread is returning 0") "log $($run.Log) reports success"
		Assert-NotInstalled $script:DefaultInstallDir
		Assert-UserDataIntact $snapshot
	}

	Invoke-Test "Switch.InstallDir" @("Full") {
		$directory = Join-Path $script:TestRoot "Custom Dir"
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn INSTALLDIR=`"$directory`"" "install-dir")
		Assert-Installed $directory $script:BaseVersion
		Assert-True (-not (Test-Path -LiteralPath $script:DefaultInstallDir)) "default folder not created"
		Assert-ExitCode 0 (Invoke-Msiexec "/x `"$Msi`" /qn" "uninstall")
		Assert-NotInstalled $directory
	}

	Invoke-Test "Switch.Log" @("Full") {
		$log = Join-Path $script:LogDir "explicit-log.txt"
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn /log `"$log`"" "install-log" -NoLog)
		Assert-True ((Get-LogText $log) -match "InstallFinalize") "/log wrote a complete log to $log"
		$since = Get-Date
		Assert-ExitCode 0 (Invoke-Msiexec "/x `"$Msi`" /qn" "uninstall-default-log" -NoLog)
		$defaults = @(Get-ChildItem -Path @("$env:TEMP\MSI*.LOG", "$env:SystemRoot\Temp\MSI*.LOG") -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -ge $since })
		Assert-True ($defaults.Count -gt 0) "MsiLogging wrote a default MSI*.LOG without any log switch"
	}

	Invoke-Test "Upgrade.KeepsDataAndFolder" @("Full") {
		$directory = Join-Path $script:TestRoot "Upgrade Dir"
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:BaseMsi)`" /qn INSTALLDIR=`"$directory`"" "install-base")
		$snapshot = New-UserData $directory
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:UpMsi)`" /qn" "upgrade")
		Assert-Installed $directory $script:UpVersion
		Assert-UserDataIntact $snapshot
	}

	Invoke-Test "Upgrade.SameVersionRebuild" @("Full") {
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:BaseMsi)`" /qn" "install-base")
		$before = @(Get-RelatedProductCodes)[0]
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:RebuildMsi)`" /qn" "install-rebuild")
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
		Assert-True (@(Get-RelatedProductCodes)[0] -ne $before) "the rebuild replaced the previous product"
	}

	Invoke-Test "Upgrade.AcrossLanguages" @("Full") {
		$other = @($script:Languages | Where-Object { $_ -ne $script:BaseLanguage }) | Select-Object -First 1
		if (-not $other) { Skip-Test "the package embeds a single language" }
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn ProductLanguage=$other" "install-language-$other")
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:UpMsi)`" /qn" "upgrade")
		Assert-Installed $script:DefaultInstallDir $script:UpVersion
	}

	Invoke-Test "Downgrade.Refused" @("Full") {
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:UpMsi)`" /qn" "install-upgrade")
		$run = Invoke-Msiexec "/i `"$($script:DownMsi)`" /qn" "downgrade"
		Assert-ExitCode 1603 $run
		Assert-Installed $script:DefaultInstallDir $script:UpVersion
	}

	Invoke-Test "Repair" @("Full") {
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "install")
		$exe = Join-Path $script:DefaultInstallDir "bin\$($script:ExeName)"
		Remove-Item -LiteralPath $exe -Force
		Remove-Item -LiteralPath "Registry::HKEY_CLASSES_ROOT\$($script:AppName).sip" -Recurse -Force
		Assert-ExitCode 0 (Invoke-Msiexec "/famus `"$Msi`" /qn" "repair-famus")
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
		Remove-Item -LiteralPath $exe -Force
		Remove-Item -LiteralPath "Registry::HKEY_CLASSES_ROOT\$($script:AppName).sip" -Recurse -Force
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "repair-reinstall")
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
	}

	Invoke-Test "Purge" @("Full") {
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "install")
		$snapshot = New-UserData $script:DefaultInstallDir
		Assert-ExitCode 0 (Invoke-Msiexec "/x `"$Msi`" /qn PURGE=0" "uninstall-purge-0")
		Assert-UserDataIntact $snapshot
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "reinstall")
		Assert-ExitCode 0 (Invoke-Msiexec "/x `"$Msi`" /qn PURGE=1" "uninstall-purge-1")
		Assert-NotInstalled $script:DefaultInstallDir
		Assert-UserDataRemoved
	}

	Invoke-Test "App.GracefulCloseAndRestart" @("Full") {
		Assert-Interactive
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:BaseMsi)`" /qn" "install-base")
		$process = Start-App $script:DefaultInstallDir
		$session = $process.SessionId
		$since = Get-Date
		$run = Invoke-Msiexec "/i `"$($script:UpMsi)`" /qn" "upgrade-running"
		Assert-ExitCode 0 $run
		Assert-True $process.HasExited "the running instance was closed"
		$log = Get-LogText $run.Log
		Assert-True ($log -match "Requested graceful quit of process $($process.Id) via IPC event") "the instance was asked to quit through the IPC event"
		Assert-True ($log -notmatch "Forced termination of process $($process.Id)") "the instance was not killed"
		$relaunched = Wait-Relaunched $script:DefaultInstallDir $since
		Assert-True ($null -ne $relaunched) "the application was relaunched"
		Assert-Equal $session $relaunched.SessionId "relaunched in the same session"
		Assert-Installed $script:DefaultInstallDir $script:UpVersion
	}

	Invoke-Test "App.GracefulCloseAndRestart.AsSystem" @("Full") {
		Assert-Interactive
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:BaseMsi)`" /qn" "install-base")
		$process = Start-App $script:DefaultInstallDir
		$session = $process.SessionId
		$since = Get-Date
		$run = Invoke-MsiexecAsSystem "/i `"$($script:UpMsi)`" /qn" "upgrade-running-as-system"
		Assert-ExitCode 0 $run
		Assert-True $process.HasExited "the running instance was closed"
		$log = Get-LogText $run.Log
		Assert-True ($log -match "Requested graceful quit of process $($process.Id) via IPC event") "the instance was asked to quit through the IPC event"
		Assert-True ($log -notmatch "Forced termination of process $($process.Id)") "the instance was not killed"
		$relaunched = Wait-Relaunched $script:DefaultInstallDir $since
		Assert-True ($null -ne $relaunched) "the application was relaunched"
		Assert-Equal $session $relaunched.SessionId "relaunched in the user session"
		Assert-Installed $script:DefaultInstallDir $script:UpVersion
	}

	Invoke-Test "Switch.RestartApp.Disabled" @("Full") {
		Assert-Interactive
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:BaseMsi)`" /qn" "install-base")
		$process = Start-App $script:DefaultInstallDir
		$since = Get-Date
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:UpMsi)`" /qn RESTARTAPP=0" "upgrade-no-restart")
		Assert-True $process.HasExited "the running instance was closed"
		Assert-True ($null -eq (Wait-Relaunched $script:DefaultInstallDir $since 20)) "the application was not relaunched"
	}

	Invoke-Test "Uninstall.ClosesRunningApp" @("Full") {
		Assert-Interactive
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "install")
		$process = Start-App $script:DefaultInstallDir
		$since = Get-Date
		Assert-ExitCode 0 (Invoke-Msiexec "/x `"$Msi`" /qn" "uninstall-running")
		Assert-True $process.HasExited "the running instance was closed"
		Assert-Equal 0 @(Get-AppProcesses | Where-Object { $_.StartTime -ge $since }).Count "no instance relaunched after uninstall"
		Assert-NotInstalled $script:DefaultInstallDir
	}

	Invoke-Test "Nsis.Migration" @("Full") {
		Install-Nsis
		$snapshot = New-UserData $script:DefaultInstallDir
		$run = Invoke-Msiexec "/i `"$Msi`" /qn" "install-over-nsis"
		Assert-ExitCode 0 $run
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
		Assert-True ((Get-LogText $run.Log) -match "NSIS uninstaller exit code: 0") "the NSIS uninstaller ran successfully"
		Assert-UserDataIntact $snapshot
	}

	Invoke-Test "Nsis.Migration.RunningApp" @("Full") {
		Assert-Interactive
		Install-Nsis
		$process = Start-App $script:DefaultInstallDir -Legacy
		$since = Get-Date
		$run = Invoke-Msiexec "/i `"$Msi`" /qn" "install-over-running-nsis"
		Assert-ExitCode 0 $run
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
		Assert-True $process.HasExited "the NSIS instance was closed"
		$log = Get-LogText $run.Log
		Assert-True ($log -match "Requested graceful quit of process $($process.Id) via end session") "the NSIS instance was asked to quit"
		Assert-True ($log -notmatch "Forced termination of process $($process.Id)") "the NSIS instance was not killed"
		Assert-True ($null -ne (Wait-Relaunched $script:DefaultInstallDir $since)) "the application was relaunched"
	}

	Invoke-Test "Nsis.Migration.RunningApp.AsSystem" @("Full") {
		Assert-Interactive
		Install-Nsis
		$process = Start-App $script:DefaultInstallDir -Legacy
		$session = $process.SessionId
		$since = Get-Date
		$run = Invoke-MsiexecAsSystem "/i `"$Msi`" /qn" "install-over-running-nsis-as-system"
		Assert-ExitCode 0 $run
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
		Assert-True $process.HasExited "the NSIS instance was closed"
		$log = Get-LogText $run.Log
		Assert-True ($log -match "Requested graceful quit of process $($process.Id) via end session from session $session") "the NSIS instance was asked to quit from its session"
		Assert-True ($log -notmatch "Forced termination of process $($process.Id)") "the NSIS instance was not killed"
		$relaunched = Wait-Relaunched $script:DefaultInstallDir $since
		Assert-True ($null -ne $relaunched) "the application was relaunched"
		Assert-Equal $session $relaunched.SessionId "relaunched in the user session"
	}

	Invoke-Test "Nsis.Migration.CustomDir" @("Full") {
		$directory = Join-Path $script:TestRoot "Nsis Dir"
		Install-Nsis $directory
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "install-over-nsis-custom")
		Assert-Installed $directory $script:BaseVersion
		Assert-True (-not (Test-Path -LiteralPath $script:DefaultInstallDir)) "default folder not created"
	}

	Invoke-Test "Nsis.InstalledOverMsi.Repaired" @("Full") {
		if (-not $NsisInstaller) { Skip-Test "no NSIS reference installer given (-NsisInstaller)" }
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "install")
		Assert-Equal 0 (Invoke-Process $NsisInstaller "/S" 900) "NSIS installer exit code"
		Assert-Equal 2 @(Get-UninstallEntries).Count "NSIS and MSI entries side by side"
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$Msi`" /qn" "repair-over-nsis")
		Assert-Installed $script:DefaultInstallDir $script:BaseVersion
	}

	Invoke-Test "ExitCode.RebootRequired" @("Full") {
		Assert-ExitCode 0 (Invoke-Msiexec "/i `"$($script:BaseMsi)`" /qn" "install-base")
		$locked = Join-Path $script:DefaultInstallDir "bin\$($script:ExeName)"
		$stream = [System.IO.File]::Open($locked, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
		try {
			$run = Invoke-Msiexec "/i `"$($script:UpMsi)`" /qn NOFORCECLOSE=1" "upgrade-locked"
		} finally {
			$stream.Dispose()
		}
		Assert-ExitCode 3010 $run
		Assert-Equal $script:UpVersion @(Get-UninstallEntries | Where-Object { $_.Msi })[0].Version "installed version"
	}

	Invoke-Test "ExitCode.RebootInitiated" @("Full") {
		Skip-Test "1641 means Windows Installer restarts the machine itself; check it by hand with REBOOT=Force and without /norestart"
	}
} finally {
	try { Reset-Environment } catch { Write-Host "Final cleanup failed: $($_.Exception.Message)" }
	Restore-UserState
	Remove-Item -LiteralPath @($script:BaseMsi, $script:UpMsi, $script:DownMsi, $script:RebuildMsi) -Force -ErrorAction SilentlyContinue
}

if ($JUnit) {
	Write-JUnit $JUnit
	Write-Host "JUnit report: $JUnit"
}
$failed = @($script:Results | Where-Object { $_.Status -eq "failed" }).Count
$skipped = @($script:Results | Where-Object { $_.Status -eq "skipped" }).Count
Write-Host ("{0} tests, {1} failed, {2} skipped" -f $script:Results.Count, $failed, $skipped)
if ($failed -gt 0) { exit 1 }
exit 0

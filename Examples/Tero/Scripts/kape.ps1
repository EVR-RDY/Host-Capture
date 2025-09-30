# Modified 25NOV2021

$host.UI.RawUI.WindowTitle = "Centaur v5.0"

$test = (Get-ItemProperty "HKLM:Software\Microsoft\Net Framework Setup\NDP\v4\Full" -erroraction 'silentlycontinue').Release -ge 378389
$drive = (get-location).drive.name
$centaur = (get-location).path | split-path -parent
$kape = "$centaur\kape\kape.exe"
$hostname = $env:COMPUTERNAME
$finalsave = $args[0]
$timestamp = $args[1]
$capture = $finalsave | split-path -parent
$binaries = "$centaur\binaries"

Try {
	get-itempropertyvalue -path "HKLM:Software\Microsoft\.NETFramework" -Name "AllowStrongNameBypass"
}
Catch {
	write-output "`n================================================="
	write-output "     Strong-Name .NET Assemblies enforced!`n        If having issues with KAPE,`n   Please adjust the correct registry keys..."
	write-output "================================================="
	sleep 5
}
	

function kape {
	$arg = "--tsource C: --tdest $finalsave --target !centaur --vhdx %m_KAPE --zv false --tdd false"
	start $kape $arg -NoNewWindow -wait
	write-output "==============================="
	write-output "   KAPE Collection Complete`!  "
	write-output "===============================`n"
	sleep 1
}

function process {
	write-output "`nCollecting running processes..."
	get-process | select processname,ID,Handles,path,SessionID,fileversion,totalprocessortime,productversion | Export-Csv $finalsave\${hostname}--${timestamp}_processes.csv -notypeinformation
	write-output "...Process Collection Complete`!"
}

function sigcheck {
	$proceed = Read-host -prompt "Would you like to conduct Sigcheck?`n`n1 - Yes`n2 - No`n`nSelect your choice, then press ENTER"
	if ($proceed -match "1") {
		write-output "`nChecking System32 and Temp files..."			
			if ([System.Environment]::Is64BitOperatingSystem -match "True") {
				& $binaries\sigcheck64.exe -e -h -q -nobanner -s -c -accepteula -w $finalsave\${hostname}_sigcheck_system32.csv C:\Windows\system32 | out-null
				& $binaries\sigcheck64.exe -e -h -q -nobanner -s -c -accepteula -w $finalsave\${hostname}_sigcheck_temp.csv C:\Windows\Temp | out-null
			} ELSE {
				& $binaries\sigcheck.exe -e -h -q -nobanner -s -c -accepteula -w $finalsave\${hostname}_sigcheck_system32.csv C:\Windows\system32 | out-null
				& $binaries\sigcheck.exe -e -h -q -nobanner -s -c -accepteula -w $finalsave\${hostname}_sigcheck_temp.csv C:\Windows\Temp | out-null
			}
		write-output "...Sigcheck Complete`!`n"
	} ELSE {
		write-output "...Skipping Sigcheck!`n"
	}
}	

function hash {
	$proceed = Read-host -prompt "Would you like to collect hashes?`n`n1 - Yes`n2 - No`n`nSelect your choice, then press ENTER"
	if ($proceed -match "1") {	
		write-output "`nHashing C:\Windows\System32 and C:\Windows\Temp..."
		$include = @("*.exe","*.dll","*.sys")
		$sys32csv = "$finalsave\${hostname}_hash_system32.txt"
		$files = gci C:\windows\system32 -file -include $include  -recurse -erroraction silentlycontinue
		$hashes = foreach ($file in $files){
			write-output (new-object -typename PSCustomObject -property @{
				Filename = $file.fullname
				MD5 = get-filehash $file.fullname -algorithm md5 | select-object -expandproperty hash
				SHA1 = get-filehash $file.fullname -algorithm SHA1 | select-object -expandproperty hash
				SHA256 = get-filehash $file.fullname -algorithm SHA256 | select-object -expandproperty hash
				})
		}
		$hashes |select-object Filename,MD5,SHA1,SHA256 | convertto-csv -notypeinformation | select -skip 1 | set-content $sys32csv
		$tempcsv = "$finalsave\${hostname}_hash_temp.txt"
		$files = gci C:\windows\temp -file -include $include  -recurse -erroraction silentlycontinue
		$hashes = foreach ($file in $files){
			write-output (new-object -typename PSCustomObject -property @{
				Filename = $file.fullname
				MD5 = get-filehash $file.fullname -algorithm md5 | select-object -expandproperty hash
				SHA1 = get-filehash $file.fullname -algorithm SHA1 | select-object -expandproperty hash
				SHA256 = get-filehash $file.fullname -algorithm SHA256 | select-object -expandproperty hash
				})
		}
		$hashes | select-object Filename,MD5,SHA1,SHA256 | convertto-csv -notypeinformation | select -skip 1 | set-content $tempcsv
		write-output "...Hashing Complete!`n"
	} ELSE {
		write-output "...Skipping Hashing!`n"
	}	
}

function post_KAPE {
	$post = read-host -prompt "Would you like to collect supplementary IR artifacts?`n`n1 - Yes`n2 - No`n`nSelect your choice, then press ENTER"
	if ($post -match "1") {
		sigcheck
		hash
	} else {
		write-output "`n...Skipping post-KAPE collection!`n"
		sleep 1
	}
}

if ($test -match "True") {
	process
	write-output "`n .NET Framework 4.6+ confirmed! Proceeding with KAPE."
	sleep 1
	kape
	post_KAPE
	exit
} ELSE {
	write-output ".NET Framework 4.5+ not detected! Please restart in LEGACY mode."
	sleep 2
	exit
}


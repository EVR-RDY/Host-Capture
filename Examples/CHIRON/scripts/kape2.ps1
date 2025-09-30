# Modified 21JAN21

#Set-ExecutionPolicy -ExecutionPolicy unrestricted -Force
$host.UI.RawUI.WindowTitle = "CHIRON (with Memcap) v4.0"
#setlocal enabledelayedexpansion


echo "`n"
$drive = (get-location).drive.name
$tools = (get-location).path
$kape = "${tools}\kape\kape.exe"
$hostname = (echo $env:computername)
$folder = (Get-Content ${tools}\scripts\kape.txt)


function kape{
	echo "`n"
	$arg = "--tsource C: --tdest ${folder} :\%d_%m_KAPE --target !biggie --vhdx %m_KAPE --zv false --gui"
	start $kape $arg -NoNewWindow -wait
	# #$recent = (Get-ChildItem -literalPath ${drive}:\ | Where-Object {$_.PSIsContainer} | Sort-Object LastWriteTime -Descending | Select-Object -First 1).fullname



	get-process | select processname,ID,Handles,path,SessionID,fileversion,totalprocessortime,productversion | Export-Csv "$folder\${hostname}_processes.csv" -notypeinformation
	echo "...Process Collection Complete`!"
	sleep 1
}
function sig{
	echo "Verifying System32 and Temp signed binaries..."			
	if ([System.Environment]::Is64BitOperatingSystem -match "True") {
		.\binaries\sigcheck64.exe -e -h -q -nobanner -s -c -accepteula -w "$folder\${env:computername}_sigcheck_system32.csv" C:\Windows\system32
		.\binaries\sigcheck64.exe -e -h -q -nobanner -s -c -accepteula -w "$folder\${env:computername}_sigcheck_temp.csv" C:\Windows\Temp
	} ELSE {
		.\binaries\sigcheck.exe -e -h -q -nobanner -s -c -accepteula -w "$folder\${env:computername}_sigcheck_system32.csv" C:\Windows\system32
		.\binaries\sigcheck.exe -e -h -q -nobanner -s -c -accepteula -w "$folder\${env:computername}_sigcheck_temp.csv" C:\Windows\Temp
	}
	echo "...Sigcheck Complete`!"
	sleep 1
}
$test = (Get-ItemProperty "HKLM:Software\Microsoft\Net Framework Setup\NDP\v4\Full" -erroraction 'silentlycontinue').Release -ge 378389 
echo $test
if ($test -match "True") {
	echo "...NET Framework 4.5+ confirmed! You may proceed.`n"
	kape
	sig
}
if ($test -notlike "True") {
	echo "...NET Framework 4.5+ NOT FOUND! You will need to run LEGACY MODE.`n"
	sleep 5
	Exit
}
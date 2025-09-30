#var
$drive = (get-location)
$collect= "$drive\Collection"
$case = "$drive\Cases"
#$binaries = "$drive\binaries"
#$tools = $PsScriptRoot
function prefetch {
    Write-Output "Parsing Prefetch..."
    $cmd = "${drive}\EZ\PECmd.exe -d ${Path}\Prefetch --csv ${case}\${folder}\Prefetch --json ${case}\${folder}\Prefetch --jsonpretty"
    invoke-expression $cmd
}

function amcache_recentfilecache {
    if ((test-path -literalpath "${Path}\Amcache") -match "True") {
        Write-Output "Parsing Amcache.hve`/RecentFileCache.bcf..."
        if ((test-path -literalpath "${Path}\Amcache\Amcache.hve") -match "True") {
            .\EZ\Amcacheparser.exe -f "${Path}\Amcache\Amcache.hve" --csv "${case}\${folder}\Amcache" --csvf amcache.csv
        }
        if ((test-path -literalpath "${Path}\Amcache\Recentfilecache.bcf") -match "True") {
            .\EZ\RecentFileCacheParser.exe -f "${Path}\Amcache\RecentFileCache.bcf" --csv "${case}\${folder}\Amcache" --csvf RecentFileCache.csv --json "${case}\${folder}\Amcache" --jsonpretty
        }
    }
}

function eventlogs {
    Write-Output "Parsing Event Logs..."
    if ((test-path -literalpath "${Path}\Evt") -match "True") {
        robocopy.exe "${Path}\Evt" "${case}\${folder}\Evt" /E /COPYALL >null 2>&1
        py -2 ${$binaries}\evtkit.py "${case}\${folder}\Evt\AppEvent.evt" "${case}\${folder}\Evt\SecEvent.evt" "${case}\${folder}\Evt\SysEvent.evt" >nul 2>&1
        wevtutil export-log "${case}\${folder}\Evt\AppEvent.evt" "${case}\${folder}\Evt\AppEvent.evtx" /lf
        wevtutil export-log "${case}\${folder}\Evt\SecEvent.evt" "${case}\${folder}\Evt\SecEvent.evtx" /lf
        wevtutil export-log "${case}\${folder}\Evt\SysEvent.evt" "${case}\${folder}\Evt\SysEvent.evtx" /lf
        Remove-Item "${case}\${folder}\Evt\AppEvent.evt"
        Remove-Item "${case}\${folder}\Evt\SecEvent.evt"
        Remove-Item "${case}\${folder}\Evt\SysEvent.evt"
       .\EZ\EvtxExplorer\EvtxECmd.exe -d "${case}\${folder}\Evt" --csv "${case}\${folder}\Evt" --json "${case}\${folder}\Evt"
    }
    if ((test-path -literalpath "${Path}\Evtx") -match "True") {
        .\EZ\EvtxExplorer\EvtxECmd.exe -d "${Path}\Evtx" --csv "${case}\${folder}\Evtx" --json "${case}\${folder}\Evtx"
    }
}

function registry {
    Write-Output "Parsing Registry..."
    if ((test-path -literalpath "${Path}\Registry\*.log*") -match "True") {
        .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\RegistryASEPs.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry" --nl
	    .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\UserActivity.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry" --nl
        .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\SoftwareASEPs.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry" --nl
        .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\BasicSystemInfo.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry" --nl
    } ELSE {
        .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\RegistryASEPs.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry"
	    .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\UserActivity.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry"
        .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\SoftwareASEPs.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry"
        .\EZ\RegistryExplorer\RECmd.exe --bn "${drive}\EZ\RegistryExplorer\BatchExamples\BasicSystemInfo.reb" -d "${Path}\Registry" --csv "${case}\${folder}\Registry" --json "${case}\${folder}\Registry"
    }
}


function filesystem {

	$MFT = (Get-ChildItem -path ${Path}\File_System\ -filter *MFT* -Recurse  | ForEach-Object {$_.fullname} ) 
	foreach ($a in $MFT){
		if ($a -notlike '*log*') {
			Write-Output "Parsing `$MFT...}"
    		.\EZ\MFTECmd.exe -f $a --csv "${case}\${folder}\File_System" --csvf MFT.csv --json "${case}\${folder}\File_System" --jsonf MFT.json	
		}
	}
}


function timeline {
    if ((test-path -literalpath "${Path}\ActivitiesCache") -match "True") {
        Write-Output "Parsing Win10 Timeline..."
        foreach ($d in (Get-ChildItem "${Path}\ActivitiesCache").name) {
			Write-Output $d
			new-item "${case}\${folder}\ActivitiesCache\${d}" -type directory -erroraction silentlycontinue | out-null
            #robocopy.exe "${Path}\ActivitiesCache\${d}" "${case}\${folder}\ActivitiesCache\${d}" /E >nul 2>&1
			foreach ($e in (Get-ChildItem "${Path}\ActivitiesCache\*\*" -filter "*.db" ).fullname) {
				.\EZ\WxTCmd.exe -f "${e}" --csv "${case}\${folder}\ActivitiesCache\${d}"
            }
        }
    }
}

#Jumplists
function jumplist {
    Write-Output "Parsing Jumplists..."
    foreach ($d in (Get-ChildItem -literalpath "${Path}\Jumplist").name) {
		Write-Output $d
		new-item "${case}\${folder}\Jumplist\${d}" -type directory -erroraction silentlycontinue | out-null
        #robocopy.exe "${Path}\Jumplist\${d}" "${case}\${folder}\Jumplist\${d}" /E >nul 2>&1
        .\EZ\JLECmd.exe -d "${Path}\Jumplist\${d}" --csv "${case}\${folder}\Jumplist\${d}" --json "${case}\${folder}\Jumplist\${d}" --jsonpretty
    }
}

#Shellbags
function shellbags {
    Write-Output "Parsing Shellbags..."
    if (-not((test-path -literalpath "${Path}\Registry\*.log*") -match "True")) {
        .\EZ\ShellBagsExplorer\SBECmd.exe -d "${Path}\Registry" --csv "${case}\${folder}\Shellbags" --json "${case}\${folder}\Shellbags" --nl --dedupe
    } ELSE {
        .\EZ\ShellBagsExplorer\SBECmd.exe -d "${Path}\Registry" --csv "${case}\${folder}\Shellbags" --json "${case}\${folder}\Shellbags" --dedupe
    }
}

#APPCOMPATCACHE
function appcompatcache {
    Write-Output "Parsing AppCompatCache..."
    if (-not((test-path -literalpath "${Path}\Registry\SYSTEM.log*") -match "True")) {
        .\EZ\AppCompatCacheParser.exe -f "${Path}\Registry\SYSTEM" --csv "${case}\${folder}\Appcompatcache" --csvf appcompatcache.csv -nl
    } ELSE {
        .\EZ\AppCompatCacheParser.exe -f "${Path}\Registry\SYSTEM" --csv "${case}\${folder}\Appcompatcache" --csvf appcompatcache.csvf
    }
}


#SHORTCUTS (.LNK)
function lnk {
    Write-Output "Parsing Shortcut .LNKs..."
    .\EZ\LECmd.exe -d "${Path}\LNK" --csv "${case}\${folder}\LNK" --json "${case}\${folder}\LNK" --jsonpretty
}


function masterlegacyanalysis {
	create_folder
    prefetch
    amcache_recentfilecache
    eventlogs
    registry
    filesystem
    timeline
    jumplist
    shellbags
    appcompatcache
    lnk
}

function log2timeline {
	.\plaso\log2timeline.exe "${case}\${Folder}\timeline\${Folder}.dump" "${Path}"
}

function log2timelinekape {
	
	$VHDXdrive = (Mount-diskimage -imagePath "${Path}" -PassThru | Get-Disk | Get-Partition | Get-Volume).DriveLetter
	.\plaso\log2timeline.exe "${case}\${Folder}\timeline\\${Folder}.dump" "${VHDXdrive}`:`\"
	dismount-diskimage -imagePath "${Path}"
}
function psortkape {
	.\plaso\psort.exe -z EST -o l2tcsv -w "${case}\${Folder}\timeline\${Folder}.csv" "${case}\${Folder}\timeline\${Folder}.dump" "date > '2020-03-01 00:00:00'"
}
#Main Analysis portion
function kape_analysis {
	$VHDXdrive = (Mount-diskimage -imagepath "${Path}" -PassThru  | Get-Disk | Get-Partition | Get-Volume).DriveLetter
	.\kape\kape.exe --msource "${VHDXdrive}`:`\" --mdest "$case\$Folder" --module !EZParser --mef csv --gui
	dismount-diskimage -imagepath "$Path"
}
function uncompress 
{	if (((test-path -path "$case\$Folder\$Folder.dmp")) -eq $True) {
		Remove-Item "$case\$Folder\$Folder.dmp"
	}
	write-host "`nUncompressing $Folder; please wait..."
	.\binaries\Z2DMP_uncompress_dmp64.exe "$Path" "$case\$Folder\$Folder.dmp"
}


function create_folder {
	if ($env:PROCESSOR_ARCHITECTURE -match "x86") {
		$rawcopy = ".\binaries\rawcopy.exe"
	}
	if ($env:PROCESSOR_ARCHITECTURE -match "AMD64") {
		$rawcopy = ".\binaries\rawcopy64.exe"
	}
    robocopy.exe $collect "$case\$Folder" /xf * >null
}
function makefolder
{
	if (-not(test-path $case\$Folder)) {
		new-item $case\$Folder -type directory
	}	
}
function makefoldertimeline
{
	if (-not(test-path $case\$Folder\timeline)) {
		new-item $case\$Folder\timeline -type directory
	}	
}






function makelist{
	#get list for memdump
	$MPath= (Get-ChildItem -path $collect -filter *.zdmp -Recurse  | ForEach-Object {$_.fullname} ) 
	$MPath > $drive\Scripts\mpath.txt
	$MFolder= Split-Path -Path $MPath
	Split-Path -Path $MFolder -Resolve -Leaf > $drive\Scripts\mfolder.txt


	# #get list for analysis and time line. Create tracker for type of capture	
	$Path = (Get-ChildItem -Path $collect -filter "*Kape.vhdx" -Recurse  | ForEach-Object {$_.fullname} )  
	$Path >> $drive\Scripts\path.txt
	foreach($line in $Path){
		Write-Output CHIRON >> $drive\Scripts\tracker.txt
	}
	#Split-Path -Path $Path >> $drive\Scripts\path.txt
	$Folder= Split-Path -Path $Path
	Split-Path -Path $Folder -Resolve -Leaf >> $drive\Scripts\folder.txt
	
	$Path = (Get-ChildItem -path $collect -filter "TXT" -Recurse  | ForEach-Object {$_.fullname} ) 
	foreach($line in $Path){
		Write-Output LEGACY >> $drive\Scripts\tracker.txt
	}
	Split-Path -Path $Path >> $drive\Scripts\path.txt
	$Folder= Split-Path -Path $Path
	Split-Path -Path $Folder -Resolve -Leaf >> $drive\Scripts\folder.txt
}



function finish {
	Remove-Item $drive\Scripts\*.txt
	Remove-Item $drive\*.gz
	Remove-Item $drive\*null*
	Exit 
}



#prompts for timeline 
function promptt{
	Write-Output "List of Captures ready for Timeline:"
	Write-Output `n
		$place = 1
		$count = 0
		Get-content .\Scripts\folder.txt | ForEach-object {
			Write-Output "${place}`) $_"
			$place++
			$count++
		}
	Write-Output `n
	$answer = read-host -prompt "Select Capture to process or `"all`", then press ENTER"
	if ($answer -eq "a") {$answer="all"}
	if ($answer -eq "All") {$answer="all"}
	if ($answer -eq "ALL") {$answer="all"}
	if ($answer -ne "all") {
		if ($answer -gt $count -or $answer -lt 1) {
			prompta
		} else {
			$answer = $answer -1
			$test= get-content $drive\Scripts\tracker.txt | Select-Object -index ${answer}
			if ($test -eq 'CHIRON'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Path = $Path.replace(".zdmp","")
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				create_folder
				makefoldertimeline 
				log2timelinekape
				psortkape			
			} 
			if ($test -eq 'LEGACY'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Path = $Path.replace(".zdmp","")
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				create_folder
				makefoldertimeline
				create_folder
				log2timeline
				psortkape
			} 
		}
	}	
	if ($answer -eq "all") {
		$answer = 0
		foreach ($line in Get-content $drive\Scripts\path.txt) {
			$test= get-content $drive\Scripts\tracker.txt | Select-Object -index ${answer}
			if ($test -eq 'CHIRON'){
			$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
			$Path = $Path.replace(".zdmp","")
			$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
			create_folder
			makefoldertimeline
			log2timelinekape
			psortkape	
			$answer= $answer +1
			}
			if ($test -eq 'LEGACY'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Path = $Path.replace(".zdmp","")
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				create_folder
				makefoldertimeline
				create_folder
				log2timeline
				psortkape
				$answer= $answer +1
			} 
		}
	}
	promptintro
}

function prompta{
	Write-Output "List of Captures ready for Analysis:"
	Write-Output `n
		$place = 1
		$count = 0
		Get-content .\Scripts\folder.txt | ForEach-object {
			Write-Output "${place}`) $_"
			$place++
			$count++
		}
	Write-Output `n
	
	$answer = read-host -prompt "Select Capture to process or `"all`", then press ENTER"
	if ($answer -eq "a") {$answer="all"}
	if ($answer -eq "All") {$answer="all"}
	if ($answer -eq "ALL") {$answer="all"}
	if ($answer -ne "all") {
		if ($answer -gt $count -or $answer -lt 1) {
			prompta
		} else {
			$answer = $answer -1
			$test= get-content $drive\Scripts\tracker.txt | Select-Object -index ${answer}
			if ($test -eq 'CHIRON'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Path = $Path.replace(".zdmp","")
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				makefolder
				kape_analysis
						
			} 
			if ($test -eq 'LEGACY'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				makefolder
				masterlegacyanalysis
			} 
		}	
	}	
	if ($answer -eq "all") {
		$answer = 0
		foreach ($line in Get-content $drive\Scripts\path.txt) {
			$test= get-content $drive\Scripts\tracker.txt | Select-Object -index ${answer}
			if ($test -eq 'CHIRON'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Path = $Path.replace(".zdmp","")
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				makefolder
				kape_analysis	
				$answer= $answer +1
			}
			if ($test -eq 'LEGACY'){
				$Path= get-content $drive\Scripts\path.txt | Select-Object -index ${answer}
				$Folder= get-content $drive\Scripts\folder.txt | Select-Object -index ${answer}
				masterlegacyanalysis
				$answer= $answer +1	
			} 
		}
	} 
	promptintro
}





#prompts to atrifacts that have been identified to be decompressed 
function promptm{
	Write-Output "List of Captures ready for Uncompress:"
	Write-Output `n
		$place = 1
		$count = 0
		Get-content .\Scripts\mfolder.txt | ForEach-object {
			Write-Output "${place}`) $_"
			$place++
			$count++
		}
	Write-Output `n
	$answer = read-host -prompt "Select Number to Decompress or `"all`", then press ENTER"
	if ($answer -eq "a") {$answer="all"}
	if ($answer -eq "All") {$answer="all"}
	if ($answer -eq "ALL") {$answer="all"}
	if ($answer -ne "all") {
		if ($answer -gt $count -or $answer -lt 1) {
			promptm	
		} else {
			$answer = $answer -1
			$Path= get-content $drive\Scripts\mpath.txt | Select-Object -index ${answer}
			$Folder= get-content $drive\Scripts\mfolder.txt | Select-Object -index ${answer}
			makefolder
			uncompress
		}
	}
	if ($answer -eq "all") {
		$answer = 0
		foreach ($line in Get-content $drive\Scripts\mpath.txt) {
			$Path= get-content $drive\Scripts\mpath.txt | Select-Object -index ${answer}
			$Folder= get-content $drive\Scripts\mfolder.txt | Select-Object -index ${answer}
			makefolder
			uncompress
			$answer= $answer +1
		}
	}	
	promptintro
}




#select what mode to run 
function promptintro {
	Write-Output `n
	Write-Output "WHat Mode Would you like to run:"
	Write-Output `n
	Write-Output "1 : Analysis"
	Write-Output "2 : Timeline"
	Write-Output "3 : Uncompress"
	Write-Output "4 : Exit"

	Write-Output `n
	$answer = read-host -prompt "Select Mode, then press ENTER"
	
	if ($answer-eq 1){
		prompta
	}
	if ($answer-eq 2){
		promptt
	}
	if ($answer-eq 3){
		promptm
	}
	if ($answer-eq 4){
		finish
	}else {
		promptintro
	}
}

Remove-Item $drive\Scripts\*.txt
Remove-Item $drive\*.gz
Remove-Item $drive\*null*
makelist
promptintro
finish 
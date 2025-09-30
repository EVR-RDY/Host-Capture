
#MODIFIED 1DEC2021
$host.UI.RawUI.WIndowTitle = "Pegasus v1.0"

$drive = get-location
$binaries = "$drive\Binaries"
$cases = "$drive\Cases"
$ez = "$drive\EZ"
$plaso = "$drive\plaso"
$scripts = "$drive\scripts"

write-output "`n`n"
get-content ${scripts}\pegasuslogo.txt

$ask_memory = read-host ("`n`nIf found, would you like to uncompress memory dumps?`n`n1 - Yes`n2 - No`n`nSelect your choice, then press ENTER")
$ask_timeline = read-host ("`n`nWould you like to create a super timeline?`n`n1 - Yes`n2 - No`n`nSelect your choice, then press ENTER")

function amcache_recentfilecache {
    if ((test-path -literalpath "$single_collect_path\Amcache") -match "True") {
        Write-Output "Parsing Amcache.hve`/RecentFileCache.bcf..."
        if ((test-path -literalpath "$single_collect_path\Amcache\Amcache.hve") -match "True") {
            & $EZ\Amcacheparser.exe -f "$single_collect_path\Amcache\Amcache.hve" --csv "$finalsave\Amcache" --csvf amcache.csv
        }
        if ((test-path -literalpath "$single_collect_path\Amcache\Recentfilecache.bcf") -match "True") {
            & $EZ\RecentFileCacheParser.exe -f "$single_collect_path\Amcache\RecentFileCache.bcf" --csv "$finalsave\Amcache" --csvf RecentFileCache.csv --json "$finalsave\Amcache" --jsonpretty
        }
    }
}

function appcompatcache {
    Write-Output "Parsing AppCompatCache..."
	& $EZ\AppCompatCacheParser.exe -f "$single_collect_path\Registry\SYSTEM" --csv "$finalsave\Appcompatcache" 
#    if (-not((test-path -literalpath "${Path}\Registry\SYSTEM.log*") -match "True")) {
#        .\EZ\AppCompatCacheParser.exe -f "${Path}\Registry\SYSTEM" --csv "${case}\${folder}\Appcompatcache" --csvf appcompatcache.csv -nl
#    } ELSE {
#        .\EZ\AppCompatCacheParser.exe -f "${Path}\Registry\SYSTEM" --csv "${case}\${folder}\Appcompatcache" --csvf appcompatcache.csvf
#    }
}

function eventlogs {
    Write-Output "Parsing Event Logs..."
    if ((test-path -literalpath $single_collect_path\Evt) -match "True") {
#		new-item "$finalsave\Event Logs" -itemtype "directory"
#		$eventlogs = "Event Logs"
		.\binaries\evtkit.py --copy_to_dir="$finalsave\Event Logs" $single_collect_path\Evt
		start-sleep -seconds 2
		gci -literalpath "$finalsave\Event Logs" -file -filter "*.evt" -recurse | foreach-object {$_ | rename-item -newname $_.name.replace('_fixed','')}
        wevtutil export-log "$finalsave\Event Logs\AppEvent.evt" "$finalsave\Event Logs\AppEvent.evtx" /lf
        wevtutil export-log "$finalsave\Event Logs\SecEvent.evt" "$finalsave\Event Logs\SecEvent.evtx" /lf
        wevtutil export-log "$finalsave\Event Logs\SysEvent.evt" "$finalsave\Event Logs\SysEvent.evtx" /lf
        & $EZ\EvtxExplorer\EvtxECmd.exe -d "$finalsave\Event Logs" --csv "$finalsave\Event Logs" --json "$finalsave\Event Logs"
		& $drive\KAPE\Modules\bin\chainsaw\chainsaw.exe hunt --rules "$drive\KAPE\Modules\bin\chainsaw\sigma_rules" --mapping "$drive\KAPE\Modules\bin\chainsaw\mapping_files\sigma-mapping.yml" --csv "$finalsave\Event Logs" --lateral-all --full "$finalsave\Event Logs"
		Remove-Item "$finalsave\Event Logs\*.evt"
    }
    if ((test-path -literalpath $single_collect_path\Evtx) -match "True") {
        & $EZ\EvtxExplorer\EvtxECmd.exe -d "$single_collect_path\Evtx" --csv "$finalsave\Event Logs" --json "$finalsave\Event Logs"
		& $drive\KAPE\Modules\bin\chainsaw\chainsaw.exe hunt --rules "$drive\KAPE\Modules\bin\chainsaw\sigma_rules" --mapping "$drive\KAPE\Modules\bin\chainsaw\mapping_files\sigma-mapping.yml" --csv "$finalsave\Event Logs" --lateral-all --full "$single_collect_path\Evtx"
    }
}

function filesystem {
	$MFT = (Get-ChildItem -path $single_collect_path\FileSystem -filter *`$* -Recurse  | ForEach-Object {$_.fullname} ) 
	foreach ($FS_artifact in $MFT){
		if ($FS_artifact -notlike '*log*') {
			Write-Output "Parsing File System Artifact `(`$MFT `| `$J `| `$Logfile `| `$Boot `| `$SDS)..."
    		& $EZ\MFTECmd.exe -f $FS_artifact --csv "$finalsave\File_System" --csvf "$FS_artifact.csv" --json "$finalsave\File_System" --jsonf "$FS_artifact.json"
		}
	}
}

function jumplist {
    Write-Output "Parsing Jumplists..."
    foreach ($directory in (Get-ChildItem -literalpath "$single_collect_path\Jumplist").name) {
        & $EZ\JLECmd.exe -d "$single_collect_path\Jumplist\$directory" --csv "$finalsave\Jumplist\$directory" --json "$finalsave\Jumplist\$directory" --jsonpretty -q
    }
}

function lnk {
    Write-Output "Parsing Shortcut .LNKs..."
    & $EZ\LECmd.exe -d "$single_collect_path\LNK" --csv "$finalsave\LNK" --json "$finalsave\LNK" --jsonpretty
}

function memory_uncompress { 
	if (((test-path -path "$single_collect_path\*.zdmp")) -eq "True") {
		$zdmp_fullname = (gci $single_collect_path\*.zdmp).fullname
		$zdmp_basename = (gci $single_collect_path\*.zdmp).basename
		write-host "Uncompressing $zdmp_basename.zdmp; please wait..."
		& $drive\binaries\Z2DMP_uncompress_dmp64.exe "$zdmp_fullname" "$finalsave\$zdmp_basename.dmp"
	}
	write-output "`nMemory uncompress complete! Continuing in 3 seconds...`n"
	start-sleep -s 3
}

function memory_process {	
}

function prefetch {
    Write-Output "Parsing Prefetch..."
    & $EZ\PECmd.exe -d $single_collect_path\Prefetch --csv "$finalsave\Prefetch" --json "$finalsave\Prefetch" --jsonpretty
}

function registry {
    Write-Output "Parsing Registry..."
	new-item -path $finalsave\Registry -itemtype directory -force | out-null
    if ((test-path -literalpath "$single_collect_path\Registry\*.log*") -match "True") {
        & $EZ\RegistryExplorer\RECmd.exe --bn "$EZ\RegistryExplorer\BatchExamples\Kroll_batch.reb" -d "$single_collect_path\Registry" --csv "$finalsave\Registry" --json "$finalsave\Registry" --nl
        & $EZ\RegistryExplorer\RECmd.exe --bn "$EZ\RegistryExplorer\BatchExamples\CutSheet.reb" -d "$single_collect_path\Registry" --csv "$finalsave\Registry" --json "$finalsave\Registry" --nl
    } ELSE {
        & $EZ\RegistryExplorer\RECmd.exe --bn "$EZ\RegistryExplorer\BatchExamples\Kroll_batch.reb" -d "$single_collect_path\Registry" --csv "$finalsave\Registry" --json "$finalsave\Registry"
        & $EZ\RegistryExplorer\RECmd.exe --bn "$EZ\RegistryExplorer\BatchExamples\CutSheet.reb" -d "$single_collect_path\Registry" --csv "$finalsave\Registry" --json "$finalsave\Registry"
    }
}

function shellbags {
    Write-Output "Parsing Shellbags..."
	& $EZ\ShellBagsExplorer\SBECmd.exe -d "$single_collect_path\Registry" --csv "$finalsave\Shellbags" --json "$finalsave\Shellbags" --dedupe
#    if (-not((test-path -literalpath "${Path}\Registry\*.log*") -match "True")) {
#        .\EZ\ShellBagsExplorer\SBECmd.exe -d "${Path}\Registry" --csv "${case}\${folder}\Shellbags" --json "${case}\${folder}\Shellbags" --nl --dedupe
#    } ELSE {
#        .\EZ\ShellBagsExplorer\SBECmd.exe -d "${Path}\Registry" --csv "${case}\${folder}\Shellbags" --json "${case}\${folder}\Shellbags" --dedupe
#    }
}

function timeline {
    if ((test-path -literalpath "$single_collect_path\ActivitiesCache") -match "True") {
        Write-Output "Parsing Win10 Timeline..."
        foreach ($directory in (Get-ChildItem "$single_collect_path\ActivitiesCache").name) {
			foreach ($db in (Get-ChildItem "$single_collect_path\ActivitiesCache\*\*" -filter "*.db" ).fullname) {
				& $EZ\WxTCmd.exe -f "$db" --csv "$finalsave\ActivitiesCache\$directory"
            }
        }
    }
}

function log2timelinekape {
	new-item $finalsave\log2timeline -type directory
	convert-vhd -path $vhdx_search -destinationpath $vhdx_search.raw
	wsl log2timeline.py "$finalsave\timeline\$folders_nameonly.dump" "$vhdx_raw.raw"
}

function log2timeline {
	new-item $finalsave\log2timeline -type directory
	wsl log2timeline.py "$finalsave\timeline\$folders_nameonly.dump" "$single_collect_path"
}

function psort {
	wsl psort.py -z EST -o l2tcsv -w "$finalsave\timeline\$folders_nameonly.csv" "$finalsave\timeline\$folders_nameonly.dump" "date > '2020-03-01 00:00:00'"
}

function end {
	write-output "Processing complete!"
	read-host "`nPress ENTER to exit"
	remove-item $drive\*.gz
	exit
}

function process {
	if ($browse.selectedpath -like "*--*") {
		$folders = $browse.selectedpath
	} else {
		$folders = (gci $browse.selectedpath -filter "*--*" -recurse -directory).fullname
	}
	foreach ($single_collect_path in $folders) {
		$folders_nameonly = (get-item $single_collect_path).basename
		new-item -Path $cases -name $folders_nameonly -itemtype "directory" -force | out-null
		$finalsave = "$cases\$folders_nameonly"	
		$vhdx_search = gci -file "$single_collect_path\*.vhdx"
		write-output "`n`n======== Processing $folders_nameonly ========`n`n"
		if (test-path $single_collect_path\*.vhdx) {
			start-sleep -s 3
			$vhdx_drive = (Mount-diskimage -imagepath $vhdx_search -passthru | Get-Disk | Get-Partition | Get-Volume).DriveLetter
			if ($ask_memory -eq "1") {
				memory_uncompress
				memory_process
			}
			if ($ask_timeline -eq "y") {
				log2timelinekape
				psort
				$proceed = read-host "`nTimeline creation complete! Would you like to proceed with processing artifacts? (y/n)"
				if ($proceed -eq "n") {
					return
				}
			}
			& $drive\kape\kape.exe --msource "$vhdx_drive`:`\" --mdest "$finalsave" --module Chainsaw,!Centaur_Parser --mef csv
			dismount-diskimage -imagepath $vhdx_search | out-null
			copy-item -path "$single_collect_path\*" -exclude *.vhdx,*.zdmp -destination "$finalsave"
			start-sleep -s 3
		} else {
			start-sleep -s 3
			if ($ask_memory -eq "1") {
				memory_uncompress
				memory_process
			}
			if ($ask_timeline -eq "y") {
				log2timeline
				psort
				$proceed = read-host "`nTimeline creation complete! Would you like to proceed with processing artifacts? (y/n)"
				if ($proceed -eq "n") {
					return
				}
			}
			amcache_recentfilecache
			appcompatcache
			eventlogs
			filesystem
			jumplist
			lnk
			prefetch
			registry
			shellbags
			timeline
			copy-item -path "$single_collect_path\TXT" -destination "$finalsave" -recurse
			Get-ChildItem "$single_collect_path\" -File | copy-item -exclude *.vhdx,*.zdmp -destination "$finalsave"
			start-sleep -s 3
		}
	}
	end
}

function choose_folder {
	[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $browse = New-Object System.Windows.Forms.FolderBrowserDialog
    $browse.RootFolder = [System.Environment+SpecialFolder]'MyComputer'
    $browse.ShowNewFolderButton = $false
    $browse.Description = "Select Raw Artifacts to Process:"
    $loop = $true
    while ($loop) {
        if ($browse.ShowDialog() -eq "OK") {
        $loop = $false
		process
        } else {
            $res = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to cancel?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
            if ($res -eq "Cancel") {
                return
            }
        }
    }
    $browse.SelectedPath
    $browse.Dispose()
} choose_folder


@echo off
SetLocal EnableDelayedExpansion

set "startTime=%time: =0%"

if "%PROCESSOR_ARCHITECTURE%"=="x86" set rawcopy=%binaries%\rawcopy.exe
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set rawcopy=%binaries%\rawcopy64.exe
if "%PROCESSOR_ARCHITECTURE%"=="x86" set extusn=%binaries%\extractusnjournal.exe
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set extusn=%binaries%\extractusnjournal64.exe	

set robocopy=%binaries%\robocopy.exe
set grep=%binaries%\grep.exe
set mmls=%binaries%\mmls.exe
set mbrutil=%binaries%\mbrutil.exe
set sigcheck=%binaries%\sigcheck.exe
set ftk=%binaries%\ftkimager_CLI.exe

for /f "usebackq tokens=5,6" %%a in (`type "%finalsave%\%computername%--%timestamp%_systeminfo.txt" ^| find "OS Name"`) do (
	set first=%%a
	set second=%%b
)
set build=%first% %second%

echo %build% | findstr /i /c:"XP" >nul && set build=Windows_XP
echo %build% | findstr /i /c:"2003" >nul && set build=Windows_Server_2003
echo %build% | findstr /i /c:"Vista" >nul && set build=Windows_Vista
echo %build% | findstr /i /c:"2008" >nul && set build=Windows_Server_2008
echo %build% | findstr /i /c:"7" >nul && set build=Windows_7
echo %build% | findstr /i /c:"8.0" >nul && set build=Windows_8
echo %build% | findstr /i /c:"2012" >nul && set build=Windows_Server_2012
echo %build% | findstr /i /c:"8.1" >nul && set build=Windows_8.1
echo %build% | findstr /i /c:"10" >nul && set build=Windows_10
echo %build% | findstr /i /c:"2016" >nul && set build=Windows_Server_2016
echo %build% | findstr /i /c:"2019" >nul && set build=Windows_Server_2019

FOR %%a in (Windows_XP Windows_Server_2003) DO (
	if "%build%"=="%%a" (
		set style=old
	)
)

FOR %%a in (Windows_Server_2008 Windows_7 Windows_8 Windows_Server_2012 Windows_8.1 Windows_10 Windows_11 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set jump=yes
	)
)
FOR %%a in (Windows_Server_2008 Windows_7 Windows_8 Windows_Server_2012 Windows_8.1 Windows_10 Windows_11 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set amcache=yes
	)
)
FOR %%a in (Windows_8 Windows_Server_2012 Windows_8.1 Windows_10 Windows_11 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set srum=yes
	)
)
FOR %%a in (Windows_10 Windows_11 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set timeline=yes
	)
)

set regsavepath=%finalsave%\Registry
mkdir "%regsavepath%" >nul 2>&1

set ntfssavepath=%finalsave%\FileSystem
mkdir "%ntfssavepath%" >nul 2>&1

set pfsavepath=%finalsave%\Prefetch
mkdir "%pfsavepath%" >nul 2>&1

set txtsavepath=%finalsave%\TXT
mkdir "%txtsavepath%" >nul 2>&1

set shimsavepath=%finalsave%\Shim
mkdir "%shimsavepath%" >nul 2>&1

set lnksavepath=%finalsave%\LNK
mkdir "%lnksavepath%" >nul 2>&1

if "%style%"=="old" (
	set evtsavepath=%finalsave%\Evt
) ELSE (
	set evtsavepath=%finalsave%\Evtx
)
mkdir "%evtsavepath%" >nul 2>&1

if "%SRUM%"=="yes" (
	set srumsavepath=%finalsave%\SRUM
)
if "%jump%"=="yes" (
	set jumpsavepath=%finalsave%\Jumplist
)
if "%amcache%"=="yes" (
	set amsavepath=%finalsave%\Amcache
)
if "%timeline%"=="yes" (
	set actsavepath=%finalsave%\ActivitiesCache
)
if "%SRUM%"=="yes" (
	mkdir "%srumsavepath%" >nul 2>&1
)
if "%jump%"=="yes" (
	mkdir "%jumpsavepath%" >nul 2>&1
)
if "%amcache%"=="yes" (
	mkdir "%amsavepath%" >nul 2>&1
)
if "%timeline%"=="yes" (
	mkdir "%actsavepath%" >nul 2>&1
)
echo.


:: ************************ PREFETCH ************************
echo %DATE% %TIME%: Collecting Prefetch...
"%robocopy%" %SYSTEMROOT%\Prefetch "%pfsavepath%" /S /E /COPYALL >nul 2>&1

:: ************************ Shortcut .LNKs ************************
echo %DATE% %TIME%: Collecting Shortcut .LNKs... 

if "%style%"=="old" (
	for /f "usebackq" %%a in (`dir "C:\Documents and Settings\" /B/O/A:D`) do (
		if exist "C:\Documents and Settings\%%a\Recent" (
			mkdir "%lnksavepath%\%%a" >nul 2>&1
			"%robocopy%" "C:\Documents and Settings\%%a\Recent" "%lnksavepath%\%%a" /S /E /COPYALL >nul 2>&1			
		)	
	)
) ELSE (
	for /f "usebackq" %%a in (`dir "%userprofile%\..\" /B/O/A:D`) do (
		if exist "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent" (
			mkdir "%lnksavepath%\%%a" >nul 2>&1
			"%robocopy%" "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent" "%lnksavepath%\%%a" /S /E /COPYALL >nul 2>&1			
		)
	)
)

:: ************************ Enumeration Tasks ************************
echo %DATE% %TIME%: Performing Enumeration Tasks...

if  "%style%"=="old" (
	set /a "place=1"
	for /f "usebackq" %%y in (`type "%binaries%\LEGACY_CommandsXP.txt" ^| findstr /v ^; ^| find "" /v /c` ) do (set /a lines=%%y)
	for /f "usebackq tokens=1,*" %%a in (`type "%binaries%\LEGACY_CommandsXP.txt" ^| findstr /v ^;`) do (
		%SYSTEMROOT%\system32\cmd.exe /v:on /s /c %%b > "%txtsavepath%\%%a.txt" 2>nul
		echo		%%a Complete^^! [!place!/!lines!]
		set /a "place=!place!+1"
	)
) ELSE (
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		set /a "place=1"
		for /f "usebackq" %%y in (`type "%binaries%\LEGACY_Commands.txt" ^| findstr /v ^; ^| find "" /v /c` ) do (set /a lines=%%y)
		for /f "usebackq tokens=1,*" %%a in (`type "%binaries%\LEGACY_Commands.txt" ^| findstr /v ^;`) do (
			%SYSTEMROOT%\system32\cmd.exe /v:on /s /c %%b > "%txtsavepath%\%%a.txt" 2>nul
			echo		%%a Complete^^! [!place!/!lines!]
			set /a "place=!place!+1"
		)	
	) ELSE (
		set /a "place=1"
		for /f "usebackq" %%y in (`type "%binaries%\LEGACY_Commands64.txt" ^| findstr /v ^; ^| find "" /v /c` ) do (set /a lines=%%y)
		for /f "usebackq tokens=1,*" %%a in (`type "%binaries%\LEGACY_Commands64.txt" ^| findstr /v ^;`) do (
			%SYSTEMROOT%\system32\cmd.exe /v:on /s /c %%b > "%txtsavepath%\%%a.txt" 2>nul
			echo		%%a Complete^^! [!place!/!lines!]
			set /a "place=!place!+1"
		)	
	)
)

:: ************************ Event Logs ************************
echo %DATE% %TIME%: Collecting Event Logs... 
if "%style%"=="old" (																		
	set apploc=%SYSTEMROOT%\System32\config\AppEvent.evt
	set secloc=%SYSTEMROOT%\System32\config\SecEvent.evt
	set sysloc=%SYSTEMROOT%\System32\config\SysEvent.evt
) ELSE (																					
	set apploc=%SYSTEMROOT%\System32\winevt\Logs\Application.evtx
	set secloc=%SYSTEMROOT%\System32\winevt\Logs\Security.evtx
	set sysloc=%SYSTEMROOT%\System32\winevt\Logs\System.evtx
	set psloc=%SYSTEMROOT%\System32\winevt\Logs\Microsoft-Windows-PowerShell%%4Operational.evtx
	set psloc2=%SYSTEMROOT%\System32\winevt\Logs\Windows PowerShell.evtx
	set rmloc=%SYSTEMROOT%\System32\winevt\Logs\Microsoft-Windows-WinRM%%4Operational.evtx
	set wmiloc=%SYSTEMROOT%\System32\winevt\Logs\Microsoft-Windows-WMI-Activity%%4Operational.evtx
)

if NOT "%style%"=="old" (
	for /f "usebackq" %%a in (`dir "%windir%\system32\winevt\logs\*.evtx" /S/B`) do (		
		"%rawcopy%" /FileNamePath:%%a /OutputPath:"%evtsavepath%" >nul 2>&1
	)
) ELSE (
	"%rawcopy%" /FileNamePath:%apploc% /OutputPath:"%evtsavepath%" >nul 2>&1
	"%rawcopy%" /FileNamePath:%secloc% /OutputPath:"%evtsavepath%" >nul 2>&1
	"%rawcopy%" /FileNamePath:%sysloc% /OutputPath:"%evtsavepath%" >nul 2>&1
)

:: ************************ Drive Enumeration ************************
for /f "usebackq tokens=3" %%i in (`"%ftk%" --list-drives ^| "%grep%" "^\\\\\." ^| "%grep%" -v "USB" ^>nul 2^>^&1`) do (
	set drives=!drives! %%i
)
for /f "usebackq tokens=*" %%i in (`echo list volume ^| %SYSTEMROOT%\System32\diskpart.exe ^| "%grep%" "Volume [0-9]" ^| "%grep%" "Partition"`) do (
	set line=%%i
	set driveletter=!line:~13^,1!
	if !driveletter! NEQ "!~d0:~0^,1!" (set driveletters=!driveletters! !driveletter!)
)
:: ************************ MBR/Partition Tables ************************
echo %DATE% %TIME%: Collecting MBR/Partition Tables...
for %%i in (%drives%) do (
	set drive=%%i
	"%mmls%" !drive! > "%ntfssavepath%\mmls-!drive:~4!.txt" 2>&1
	"%mbrutil%" /SH="%ntfssavepath%\!drive!.dat" >nul 2>&1
)
:: ************************ $MFT/$J/$USNJRNL ************************
echo %DATE% %TIME%: Collecting $MFT/$J/$USNJRNL...
for %%i in (%driveletters%) do (
	set drive=%%i
	"%rawcopy%" /FileNamePath:!drive!:0 /OutputPath:"%ntfssavepath%" /OutputName:^$MFT_%%i >nul 2>&1
	"%rawcopy%" /FileNamePath:!drive!:2 /OutputPath:"%ntfssavepath%" /OutputName:^$MFT_%%i_^$LogFile >nul 2>&1
	if NOT "%style%"=="old" (
		"%extusn%" /DevicePath:!drive!: /OutputPath:"%ntfssavepath%" >nul 2>&1
	)
)

:: ************************ Registry ************************
echo %DATE% %TIME%: Collecting Registry...
"%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SAM /OutputPath:"%regsavepath%" >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SAM.log ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SAM.log /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SAM.log1 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SAM.log1 /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SAM.log2 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SAM.log2 /OutputPath:"%regsavepath%" >nul 2>&1)
"%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY /OutputPath:"%regsavepath%" >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SECURITY.log ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY.log /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SECURITY.log1 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY.log1 /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SECURITY.log2 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY.log2 /OutputPath:"%regsavepath%" >nul 2>&1)
"%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE /OutputPath:"%regsavepath%" >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SOFTWARE.log ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE.log /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SOFTWARE.log1 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE.log1 /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SOFTWARE.log2 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE.log2 /OutputPath:"%regsavepath%" >nul 2>&1)
"%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM /OutputPath:"%regsavepath%" >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SYSTEM.log ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM.log /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SYSTEM.log1 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM.log1 /OutputPath:"%regsavepath%" >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SYSTEM.log2 ("%rawcopy%" /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM.log2 /OutputPath:"%regsavepath%" >nul 2>&1)

:: ************************ NTUSER/USRCLASS.DAT ************************
echo %DATE% %TIME%: Collecting NTUSER + USRCLASS.dat for Users...

:: MUST KEEP "cd /d %USERPROFILE...." BELOW, BECAUSE XP = C:\Documents and Settings, AND 7+ = C:\Users
cd /d "%userprofile%\..\"

if "%style%"=="old" (
	for /f "usebackq" %%a in (`dir "C:\Documents and Settings" /B/O/A:D`) do (
		mkdir "%regsavepath%\%%a" >nul 2>&1
		"%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT" /OutputPath:"%regsavepath%\%%a" /OutputName:ntuser.dat >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG" "%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG1" "%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG1 >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG2" "%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG2 >nul 2>&1
		"%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\USRCLASS.dat" /OutputPath:"%regsavepath%\%%a" /OutputName:usrclass.dat >nul 2>&1
		if exist "C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG" "%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG >nul 2>&1
		if exist "C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG1" "%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG1 >nul 2>&1
		if exist "C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG2" "%rawcopy%" /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG2 >nul 2>&1
	)
)
if NOT "%style%"=="old" (
	for /f "usebackq" %%a in (`dir .\ /B/O/A:D`) do (
		mkdir "%regsavepath%\%%a" >nul 2>&1
		"%rawcopy%" /FileNamePath:"C:\Users\%%a\ntuser.dat" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.dat >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG" "%rawcopy%" /FileNamePath:"C:\Users\%%a\NTUSER.DAT.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG1" "%rawcopy%" /FileNamePath:"C:\Users\%%a\NTUSER.DAT.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG1 >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG2" "%rawcopy%" /FileNamePath:"C:\Users\%%a\NTUSER.DAT.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG2 >nul 2>&1
		"%rawcopy%" /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.dat >nul 2>&1
		if exist ".\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG" "%rawcopy%" /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG >nul 2>&1
		if exist ".\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG1" "%rawcopy%" /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG1 >nul 2>&1
		if exist ".\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG2" "%rawcopy%" /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG2 >nul 2>&1
	)
)

:: ************************ Timeline (ActivitiesCache.db) ************************
FOR %%a in (Windows_10 Windows_11 Windows_Server_2016) DO IF "%build%"=="%%a" (
	echo %DATE% %TIME%: Collecting ActivitiesCache.db...
	for /f "usebackq" %%a in (`dir C:\Users /B/O/A:D`) do (
		mkdir "%actsavepath%\%%a" >nul 2>&1
		dir "C:\Users\%%a\AppData\Local\*activitiescache.db" /B/O/S 2>nul > "%actsavepath%\%%a\tempact.txt"
		for /f "usebackq" %%q in (`type "%actsavepath%\%%a\tempact.txt"`) do (
			"%rawcopy%" /FileNamePath:"%%q" /OutputPath:"%actsavepath%\%%a" >nul 2>&1
		)
		del /s /q "%actsavepath%\%%a\tempact.txt" >nul 2>&1
		if NOT exist "%actsavepath%\%%a\ActivitiesCache.db" (
			rmdir /s /q "%actsavepath%\%%a" >nul 2>&1	
		)	
	)
)

:: ************************ USB (setupapi) ************************
echo %DATE% %TIME%: Collecting setupapi.log...
if "%style%"=="old" (
	"%robocopy%" %WINDIR% "%regsavepath%" setupapi* /COPYALL >nul 2>&1
) ELSE (
	"%robocopy%" %WINDIR%\Inf "%regsavepath%" setupapi.dev.log /COPYALL >nul 2>&1
)

:: ************************ Shimcache ************************
echo %DATE% %TIME%: Collecting Shimcache .SDB...
xcopy %SYSTEMROOT%\AppPatch "%shimsavepath%" /E /H /C /I >nul 2>&1

:: ************************ Jumplists ************************
echo %DATE% %TIME%: Collecting Jumplists...
if "%jump%"=="yes" (
	for /f "usebackq" %%a in (`dir "%userprofile%\..\" /B/O/A:D`) do (
		if exist "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations" (
			mkdir "%jumpsavepath%\%%a\automaticdestinations" >nul 2>&1
			copy "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\*" "%jumpsavepath%\%%a\automaticdestinations" >nul 2>&1
			mkdir "%jumpsavepath%\%%a\customdestinations" >nul 2>&1
			copy "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\*" "%jumpsavepath%\%%a\customdestinations" >nul 2>&1
		)
	)
)

:: ************************ Amcache/AppCompatCache/RecentFileCache ************************
if exist "%SYSTEMROOT%\appCompat\Programs" (
	echo %DATE% %TIME%: Collecting Amcache.hve^/RecentFileCache.bcf, please wait...
	"%rawcopy%" /FileNamePath:%SYSTEMROOT%\appcompat\programs\Amcache.hve /OutputPath:"%amsavepath%" >nul 2>&1
	"%rawcopy%" /FileNamePath:%SYSTEMROOT%\appcompat\programs\Amcache.hve.log1 /OutputPath:"%amsavepath%" >nul 2>&1
	"%rawcopy%" /FileNamePath:%SYSTEMROOT%\appcompat\programs\Amcache.hve.log2 /OutputPath:"%amsavepath%" >nul 2>&1
	"%rawcopy%" /FileNamePath:%SYSTEMROOT%\appcompat\programs\RecentFileCache.bcf /OutputPath:"%amsavepath%" >nul 2>&1
)

:: ************************ SRUM ************************
if exist "%SYSTEMROOT%\system32\sru" (
	echo %DATE% %TIME%: Collecting SRUM, please wait...
	"%rawcopy%" /Filenamepath:%SYSTEMROOT%\System32\sru\SRUDB.dat /Outputpath:"%srumsavepath%" >nul 2>&1
)
echo.
echo.
echo Finalizing triage capture...
echo.
for /f "usebackq" %%a in (`dir /a:-d /s /b "%finalsave%" ^| find /c ":\"`) do (set count=%%a)
set "endTime=%time: =0%"
set "end=!endTime:%time:~8,1%=%%100)*100+1!" & set "start=!startTime:%time:~8,1%=%%100)*100+1!"
set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100), elap-=(elap>>31)*24*60*60*100"
set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"
set elapsed=%hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1%

echo =========================================================================
echo 	%DATE% %TIME%: Legacy Collection Complete^^!
echo.
echo 		    Copied %count% File(s) in %elapsed%
echo =========================================================================
echo.
echo.

:post_LEGACY
echo Would you like to collect supplementary IR artifacts?
echo.
echo 1 - Yes
echo 2 - No
echo.
SET /P post="Select your choice, then press ENTER: "
IF "%post%"=="1" (
	echo.
	echo.
	GOTO sigcheck
) else (
	echo.
	GOTO finish
)

:sigcheck
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                                 SIGCHECK
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Would you like to conduct Sigcheck?
echo.
echo 1 - Yes
echo 2 - No
echo.
SET /P sigcheck="Select your choice, then press ENTER: "
IF "%sigcheck%"=="1" (
	echo.
	echo %DATE% %TIME%: Conducting Sigcheck...
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		if "%style%"=="old" ( 
			"%binaries%\sigcheck_xp.exe" -q /accepteula -c -h C:\windows\system32 > "%txtsavepath%\sigcheck_system32.txt"
			"%binaries%\sigcheck_xp.exe" -q /accepteula -c -h C:\windows\temp > "%txtsavepath%\sigcheck_temp.txt"
		) ELSE (
			"%binaries%\sigcheck.exe" -q -nobanner /accepteula -c -h C:\windows\system32 > "%txtsavepath%\sigcheck_system32.txt"
			"%binaries%\sigcheck.exe" -q -nobanner /accepteula -c -h C:\windows\temp > "%txtsavepath%\sigcheck_temp.txt"
		)
	) ELSE (
		if "%style%"=="old" ( 
			"%binaries%\sigcheck_xp.exe" -q /accepteula -c -h C:\windows\system32 > "%txtsavepath%\sigcheck_system32.txt"
			"%binaries%\sigcheck_xp.exe" -q /accepteula -c -h C:\windows\temp > "%txtsavepath%\sigcheck_temp.txt"
		) ELSE (
			"%binaries%\sigcheck64.exe" -q -nobanner -accepteula -c -h C:\windows\system32 > "%txtsavepath%\sigcheck_system32.txt"
			"%binaries%\sigcheck64.exe" -q -nobanner -accepteula -c -h C:\windows\temp > "%txtsavepath%\sigcheck_temp.txt"
		)
	)
	echo %DATE% %TIME% ...Sigcheck Complete^^!
	echo.
	echo.
	GOTO hashes
) ELSE (
	echo.
	echo ...Skipping Sigcheck^^!
	echo.
	echo.
	GOTO hashes
)
echo.

:hashes
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                                 HASHING
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Would you like to collect hashes?
echo.
echo 1 - Yes
echo 2 - No
echo.
SET /P hash="Select your choice, then press ENTER: "
echo.

set hash_location1="C:\Windows\system32\"
set hash_location2="C:\Windows\temp\"

if "%hash%"=="1" (
	echo %DATE% %TIME%: Hashing %hash_location1% and %hash_location2%; please wait...
	mkdir "%finalsave%\Hash" >nul 2>&1
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		"%binaries%\hashmyfiles.exe" /SaveDirect /wildcard "%hash_location1%*.exe" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\hash\exe_sys32hash.txt"
		"%binaries%\hashmyfiles.exe" /SaveDirect /wildcard "%hash_location1%*.dll" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\dll_sys32hash.txt"
		"%binaries%\hashmyfiles.exe" /SaveDirect /wildcard "%hash_location1%*.sys" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\sys_sys32hash.txt"
		
		"%binaries%\hashmyfiles.exe" /SaveDirect /wildcard "%hash_location2%*.exe" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\exe_temphash.txt"
		"%binaries%\hashmyfiles.exe" /SaveDirect /wildcard "%hash_location2%*.dll" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\dll_temphash.txt"
		"%binaries%\hashmyfiles.exe" /SaveDirect /wildcard "%hash_location2%*.sys" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\sys_temphash.txt"
	) ELSE (
		"%binaries%\hashmyfilesx64.exe" /SaveDirect /wildcard "%hash_location1%*.exe" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\exe_sys32hash.txt"
		"%binaries%\hashmyfilesx64.exe" /SaveDirect /wildcard "%hash_location1%*.dll" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\dll_sys32hash.txt"
		"%binaries%\hashmyfilesx64.exe" /SaveDirect /wildcard "%hash_location1%*.sys" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\sys_sys32hash.txt"

		"%binaries%\hashmyfilesx64.exe" /SaveDirect /wildcard "%hash_location2%*.exe" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\exe_temphash.txt"
		"%binaries%\hashmyfilesx64.exe" /SaveDirect /wildcard "%hash_location2%*.dll" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\dll_temphash.txt"
		"%binaries%\hashmyfilesx64.exe" /SaveDirect /wildcard "%hash_location2%*.sys" 1000 /MD5 1 /SHA1 1 /SHA256 1 /scomma "%finalsave%\Hash\sys_temphash.txt"
	)
	echo %DATE% %TIME%: ...Hashing Complete^^!
	GOTO finish
) else (
	echo.
	echo ...Skipping hash collection^^!
	GOTO finish
)
echo.
echo.

:finish
exit /b

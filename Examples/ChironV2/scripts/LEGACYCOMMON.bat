


echo %DATE% %TIME%:*********************** PROCESSOR ARCHITECTURE ************************* >> %logfile%
if "%PROCESSOR_ARCHITECTURE%"=="x86" set rawcopy=%binaries%\rawcopy.exe
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set rawcopy=%binaries%\rawcopy64.exe
if "%PROCESSOR_ARCHITECTURE%"=="x86" set extusn=%binaries%\extractusnjournal.exe
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set extusn=%binaries%\extractusnjournal64.exe



echo %DATE% %TIME%:*********************** Windows Versioning ************************* >> %logfile%



for /f "usebackq tokens=5,6" %%a in (`systeminfo ^| find "OS Name"`) do (
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

FOR %%a in (Windows_Server_2008 Windows_7 Windows_8 Windows_Server_2012 Windows_8.1 Windows_10 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set jump=yes
	)
)
FOR %%a in (Windows_Server_2008 Windows_7 Windows_8 Windows_Server_2012 Windows_8.1 Windows_10 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set amcache=yes
	)
)
FOR %%a in (Windows_8 Windows_Server_2012 Windows_8.1 Windows_10 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set srum=yes
	)
)
FOR %%a in (Windows_10 Windows_Server_2016 Windows_Server_2019) DO (
	IF "%build%"=="%%a" (
		set timeline=yes
	)
)
echo %DATE% %TIME%: FOLDER creation >> %logfile%

set regsavepath="%outpath%\Registry"
%binaries%\mkdir.exe -p %regsavepath% >nul 2>&1

set ntfssavepath="%outpath%\File_System"
%binaries%\mkdir.exe -p %ntfssavepath% >nul 2>&1

set pfsavepath="%outpath%\Prefetch"
%binaries%\mkdir.exe -p %pfsavepath% >nul 2>&1

set txtsavepath=%outpath%\TXT
%binaries%\mkdir.exe -p %txtsavepath% >nul 2>&1

set shimsavepath=%outpath%\Shim
%binaries%\mkdir.exe -p %shimsavepath% >nul 2>&1

if "%style%"=="old" (
	set evtsavepath="%outpath%\Evt"
) ELSE (
	set evtsavepath="%outpath%\Evtx"
)
%binaries%\mkdir.exe -p %evtsavepath% >nul 2>&1

if "%SRUM%"=="yes" (
	set srumsavepath="%outpath%\SRUM"
)

if "%jump%"=="yes" (
	set jumpsavepath="%outpath%\Jumplist"
)

if "%amcache%"=="yes" (
	set amsavepath="%outpath%\Amcache"
)

if "%timeline%"=="yes" (
	set actsavepath="%outpath%\ActivitiesCache"
)

if "%SRUM%"=="yes" (
	%binaries%\mkdir.exe -p %srumsavepath% >nul 2>&1
)

if "%jump%"=="yes" (
	%binaries%\mkdir.exe -p %jumpsavepath% >nul 2>&1
)

if "%amcache%"=="yes" (
	%binaries%\mkdir.exe -p %amsavepath% >nul 2>&1
)

if "%timeline%"=="yes" (
	%binaries%\mkdir.exe -p %actsavepath% >nul 2>&1
)
 
echo %DATE% %TIME%:*********************** Collect Shortcut .LNKs ************************* >> %logfile%

if "%style%"=="old" (
	for /f "usebackq" %%a in (`dir "C:\Documents and Settings\" /B/O/A:D`) do (
		if exist "C:\Documents and Settings\%%a\Recent" (
			%binaries%\mkdir.exe -p "%outpath%\LNK\%%a" >nul 2>&1
			%binaries%\robocopy.exe "C:\Documents and Settings\%%a\Recent" "%outpath%\LNK\%%a" /E /COPYALL >nul 2>&1			
		)	
	)
) ELSE (
	for /f "usebackq" %%a in (`dir "%userprofile%\..\" /B/O/A:D`) do (
		if exist "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent" (
			%binaries%\mkdir.exe -p "%outpath%\LNK\%%a" >nul 2>&1
			%binaries%\robocopy.exe "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent" "%outpath%\LNK\%%a" /E /COPYALL >nul 2>&1			
		)
	)
)
::************************* Networking *************************

systeminfo | findstr /L /c:"Zone:" | %binaries%\tee.exe -a %logfile% >nul 2>&1
%SYSTEMROOT%\system32\cmd.exe /c "ver" | %binaries%\tee.exe -a %logfile%
echo.
echo. >> %logfile%
echo Networking Information: | %binaries%\tee.exe -a %logfile%
%SYSTEMROOT%\system32\ipconfig.exe /all |  %binaries%\grep.exe -E "IPv4|Subnet Mask|Default Gateway|DHCP Server|DNS Server" | %binaries%\tee.exe -a %logfile%
echo.
echo. >> %logfile%
echo *************************************************************************** >> %logfile%

::************************* Disk Info *************************

for /f "usebackq tokens=1" %%i in (`%binaries%\ftkimager_CLI_version.exe --list-drives 2^>^&1 ^| %binaries%\grep.exe "^\\\\\." ^| %binaries%\grep.exe -v "USB"`) do (
	set drives=!drives! %%i
)
for /f "usebackq tokens=*" %%i in (`echo list volume ^| %SYSTEMROOT%\System32\diskpart.exe ^| %binaries%\grep.exe "Volume [0-9]" ^| %binaries%\grep.exe "Partition"`) do (
	set line=%%i
	set driveletter=!line:~13^,1!
	if !driveletter! NEQ !~d0:~0^,1! (set driveletters=!driveletters! !driveletter!)
)
::************************* List Drives *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Listing Drives... >> %logfile%
echo ******************************************************************** >> %logfile%

echo Physical Disks: | %binaries%\tee.exe -a %logfile%
echo %drives% | %binaries%\tee.exe -a %logfile%
echo.
echo. >> %logfile%
echo Logical Volume Letters: | %binaries%\tee.exe -a %logfile%
echo %driveletters% | %binaries%\tee.exe -a %logfile%
echo.
echo. >> %logfile%

::************************* Dirwalk *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Performing Dirwalk...  | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: tree C:\ /F /A ^> %ntfssavepath%\%computername%-dirwalk.txt >> %logfile%
tree C:\ /F /A > %ntfssavepath%\%computername%-dirwalk.txt 
echo. >> %logfile%

:: ************************* Enumeration Tasks *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Performing enumeration tasks...  | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

if  "%style%"=="old" (
	set /a "place=1"
	for /f "usebackq" %%y in (`type %binaries%\LEGACY_CommandsXP.txt ^| findstr /v ^; ^| find "" /v /c` ) do (set /a lines=%%y)
	for /f "usebackq tokens=1,*" %%a in (`type %binaries%\LEGACY_CommandsXP.txt ^| findstr /v ^;`) do (
		echo !DATE! !TIME!: %%b ^> %txtsavepath%\%%a.txt >> %logfile%
		%SYSTEMROOT%\system32\cmd.exe /v:on /s /c %%b > %txtsavepath%\%%a.txt 2>nul
		echo		%%a Complete^^! [!place!/!lines!]
		set /a "place=!place!+1"
	)
) ELSE (
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		set /a "place=1"
		for /f "usebackq" %%y in (`type %binaries%\LEGACY_Commands.txt ^| findstr /v ^; ^| find "" /v /c` ) do (set /a lines=%%y)
		for /f "usebackq tokens=1,*" %%a in (`type %binaries%\LEGACY_Commands.txt ^| findstr /v ^;`) do (
			echo !DATE! !TIME!: %%b ^> %txtsavepath%\%%a.txt >> %logfile%
			%SYSTEMROOT%\system32\cmd.exe /v:on /s /c %%b > %txtsavepath%\%%a.txt 2>nul
			echo		%%a Complete^^! [!place!/!lines!]
			set /a "place=!place!+1"
		)	
	) ELSE (
		set /a "place=1"
		for /f "usebackq" %%y in (`type %binaries%\LEGACY_Commands64.txt ^| findstr /v ^; ^| find "" /v /c` ) do (set /a lines=%%y)
		for /f "usebackq tokens=1,*" %%a in (`type %binaries%\LEGACY_Commands64.txt ^| findstr /v ^;`) do (
			echo !DATE! !TIME!: %%b ^> %txtsavepath%\%%a.txt >> %logfile%
			%SYSTEMROOT%\system32\cmd.exe /v:on /s /c %%b > %txtsavepath%\%%a.txt 2>nul
			echo		%%a Complete^^! [!place!/!lines!]
			set /a "place=!place!+1"
		)	
	)
)
echo.
echo. >> %logfile%

:: ************************* Collect Event Logs *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Collecting Event Logs...  | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

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
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%apploc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%apploc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%secloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%secloc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%sysloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%sysloc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%psloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%psloc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:"%psloc2%" /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:"%psloc2%" /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%rmloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%rmloc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%wmiloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%wmiloc% /OutputPath:%evtsavepath% >nul 2>&1
) ELSE (
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%apploc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%apploc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%secloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%secloc% /OutputPath:%evtsavepath% >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:%sysloc% /OutputPath:%evtsavepath% >> %logfile%
	%rawcopy% /FileNamePath:%sysloc% /OutputPath:%evtsavepath% >nul 2>&1
)

echo. >> %logfile%

:: ************************* Processing Physical Disks *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Processing Physical Disks...  | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%
for %%i in (%drives%) do (
	set drive=%%i
	echo !DATE! !TIME!: %binaries%\mmls.exe !drive! ^> %ntfssavepath%\mmls-!drive:~4!.txt >> %logfile%
	%binaries%\mmls.exe !drive! > %ntfssavepath%\mmls-!drive:~4!.txt 2>&1
	echo !DATE! !TIME!: %binaries%\MBRUtil.exe /SH=%ntfssavepath%\!drive!.dat >nul 2>&1 >> %logfile%
	%binaries%\MBRUtil.exe /SH=%ntfssavepath%\!drive!.dat >nul 2>&1
)
echo. >> %logfile%


:: ************************* Processing Logical Vol. *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Processing Logical Volumes...  | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%
for %%i in (%driveletters%) do (
	set drive=%%i
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:!drive!:0 /OutputPath:%ntfssavepath%_%%i >> %logfile%
	%rawcopy% /FileNamePath:!drive!:0 /OutputPath:%ntfssavepath% /OutputName:^$MFT_%%i >nul 2>&1
	echo !DATE! !TIME!: %rawcopy% /FileNamePath:!drive!:2 /OutputPath:%ntfssavepath%_%%i >> %logfile%
	%rawcopy% /FileNamePath:!drive!:2 /OutputPath:%ntfssavepath% /OutputName:^$MFT_%%i_^$LogFile >nul 2>&1
	if NOT "%style%"=="old" (
		echo !DATE! !TIME!: %extusn% !drive!: %ntfssavepath% >> %logfile%
		%extusn% /DevicePath:!drive!: /OutputPath:%ntfssavepath% >nul 2>&1
	)
)

echo. >> %logfile%

:: ************************* Collecting Registry *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Collecting Registry... | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%
echo !DATE! !TIME!: %rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SAM and .LOGS /OutputPath:%regsavepath% >> %logfile%
%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SAM /OutputPath:%regsavepath% >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SAM.log (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SAM.log /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SAM.log1 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SAM.log1 /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SAM.log2 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SAM.log2 /OutputPath:%regsavepath% >nul 2>&1)
echo !DATE! !TIME!: %rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY and .LOGS /OutputPath:%regsavepath% >> %logfile%
%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY /OutputPath:%regsavepath% >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SECURITY.log (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY.log /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SECURITY.log1 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY.log1 /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SECURITY.log2 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SECURITY.log2 /OutputPath:%regsavepath% >nul 2>&1)
echo !DATE! !TIME!: %rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE and .LOGS /OutputPath:%regsavepath% >> %logfile%
%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE /OutputPath:%regsavepath% >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SOFTWARE.log (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE.log /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SOFTWARE.log1 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE.log1 /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SOFTWARE.log2 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SOFTWARE.log2 /OutputPath:%regsavepath% >nul 2>&1)
echo !DATE! !TIME!: %rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM and .LOGS /OutputPath:%regsavepath% >> %logfile%
%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM /OutputPath:%regsavepath% >nul 2>&1
if exist %SYSTEMROOT%\System32\config\SYSTEM.log (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM.log /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SYSTEM.log1 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM.log1 /OutputPath:%regsavepath% >nul 2>&1)
if exist %SYSTEMROOT%\System32\config\SYSTEM.log2 (%rawcopy% /FileNamePath:%SYSTEMROOT%\System32\config\SYSTEM.log2 /OutputPath:%regsavepath% >nul 2>&1)

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Collecting NTUSER + USRCLASS.dat for Users... | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

cd /d %userprofile%\..\

if "%style%"=="old" (
	for /f "usebackq" %%a in (`dir "C:\Documents and Settings" /B/O/A:D`) do (
		%binaries%\mkdir.exe -p "%regsavepath%\%%a" >nul 2>&1
		echo !DATE! !TIME!: %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT" /OutputPath:"%regsavepath%" >> %logfile%
		%rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT" /OutputPath:"%regsavepath%\%%a" /OutputName:ntuser.dat >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG" %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG1" %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG1 >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG2" %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\NTUSER.DAT.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG2 >nul 2>&1
		echo !DATE! !TIME!: %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\USRCLASS.dat" /OutputPath:"%regsavepath%\%%a" >> %logfile%
		%rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\USRCLASS.dat" /OutputPath:"%regsavepath%\%%a" /OutputName:usrclass.dat >nul 2>&1
		if exist "C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG" %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG >nul 2>&1
		if exist "C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG1" %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG1 >nul 2>&1
		if exist "C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG2" %rawcopy% /FileNamePath:"C:\Documents and Settings\%%a\Local Settings\Application Data\Microsoft\Windows\usrclass.DAT.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG2 >nul 2>&1
	)
)
if NOT "%style%"=="old" (
	for /f "usebackq" %%a in (`dir .\ /B/O/A:D`) do (
		%binaries%\mkdir.exe -p "%regsavepath%\%%a" >nul 2>&1
		echo !DATE! !TIME!: %rawcopy% /FileNamePath:"C:\Users\%%a\ntuser.dat" /OutputPath:"%regsavepath%\%%a" >> %logfile%
		%rawcopy% /FileNamePath:"C:\Users\%%a\ntuser.dat" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.dat >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG" %rawcopy% /FileNamePath:"C:\Users\%%a\NTUSER.DAT.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG1" %rawcopy% /FileNamePath:"C:\Users\%%a\NTUSER.DAT.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG1 >nul 2>&1
		if exist ".\%%a\NTUSER.DAT.LOG2" %rawcopy% /FileNamePath:"C:\Users\%%a\NTUSER.DAT.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:NTUSER.DAT.LOG2 >nul 2>&1
		echo !DATE! !TIME!: %rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat" /OutputPath:"%regsavepath%\%%a" >> %logfile%
		%rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.dat >nul 2>&1
		if exist ".\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG" %rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG >nul 2>&1
		if exist ".\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG1" %rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG1" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG1 >nul 2>&1
		if exist ".\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG2" %rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Local\Microsoft\Windows\USRCLASS.dat.LOG2" /OutputPath:"%regsavepath%\%%a" /OutputName:USRCLASS.DAT.LOG2 >nul 2>&1
	)
)

echo. >> %logfile%

:: ************************* Collecting ActivitiesCache.db *************************

FOR %%a in (Windows_10 Windows_Server_2016) DO IF "%build%"=="%%a" (
	echo ******************************************************************** >> %logfile%
	echo %DATE% %TIME%: Collecting ActivitiesCache.db... | %binaries%\tee.exe -a %logfile%
	echo ******************************************************************** >> %logfile%
	for /f "usebackq" %%a in (`dir C:\Users /B/O/A:D`) do (
		%binaries%\mkdir.exe -p %actsavepath%\%%a >nul 2>&1
		dir "C:\Users\%%a\AppData\Local\*activitiescache.db" /B/O/S 2>nul > "%actsavepath%\%%a\tempact.txt"
		for /f "usebackq" %%q in (`type "%actsavepath%\%%a\tempact.txt"`) do (
			echo !DATE! !TIME!: %rawcopy% /FileNamePath:"%%q" /OutputPath:"%actsavepath%\%%a" >> %logfile%
			%rawcopy% /FileNamePath:"%%q" /OutputPath:"%actsavepath%\%%a" >nul 2>&1
		)
		del /s /q "%actsavepath%\%%a\tempact.txt" >nul 2>&1
		if NOT exist "%actsavepath%\%%a\ActivitiesCache.db" (
			rmdir /s /q "%actsavepath%\%%a" >nul 2>&1	
		)	
	)
)
echo. >> %logfile%

:: ************************* Collecting setupapi.log *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Collecting setupapi.log... | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

if "%style%"=="old" (
	echo !DATE! !TIME!: %binaries%\robocopy.exe %WINDIR% %regsavepath% setupapi* /COPYALL >> %logfile%
	%binaries%\robocopy.exe %WINDIR% %regsavepath% setupapi* /COPYALL >nul 2>&1
) ELSE (
	echo !DATE! !TIME!: %binaries%\robocopy.exe %WINDIR%\Inf %regsavepath% setupapi.dev.log /COPYALL >> %logfile%
	%binaries%\robocopy.exe %WINDIR%\Inf %regsavepath% setupapi.dev.log /COPYALL >nul 2>&1
)

:: ************************* Collecting Shimcache *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Collecting Shimcache .SDB... | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

echo %DATE% %TIME%: %binaries%\robocopy.exe %SYSTEMROOT%\AppPatch %shimsavepath% sysmain.sdb /COPYALL >> %logfile%
%binaries%\robocopy.exe %SYSTEMROOT%\AppPatch %shimsavepath% sysmain.sdb /COPYALL >nul 2>&1
echo %DATE% %TIME%: %binaries%\robocopy.exe %SYSTEMROOT%\AppPatch\custom %shimsavepath% /S /E >> %logfile%
%binaries%\robocopy.exe %SYSTEMROOT%\AppPatch\custom %shimsavepath% /S /E >nul 2>&1
echo %DATE% %TIME%: %binaries%\robocopy.exe %SYSTEMROOT%\AppPatch64\custom %shimsavepath% /S /E >> %logfile%
%binaries%\robocopy.exe %SYSTEMROOT%\AppPatch64\custom %shimsavepath% /S /E >nul 2>&1

:: ************************* Collecting Jumplists *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Collecting Jumplists... | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

if "%jump%"=="yes" (
	for /f "usebackq" %%a in (`dir "%userprofile%\..\" /B/O/A:D`) do (
		if exist "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations" (
			%binaries%\mkdir.exe -p "%jumpsavepath%\%%a\automaticdestinations" >nul 2>&1
			echo !DATE! !TIME!: %rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations" /OutputPath:"%jumpsavepath%\%%a\automaticdestinations" >> %logfile%
			copy "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations\*" "%jumpsavepath%\%%a\automaticdestinations" >nul 2>&1
			%binaries%\mkdir.exe -p "%jumpsavepath%\%%a\customdestinations" >nul 2>&1
			echo !DATE! !TIME!: %rawcopy% /FileNamePath:"C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations" /OutputPath:"%jumpsavepath%\%%a\customdestinations" >> %logfile%
			copy "C:\Users\%%a\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations\*" "%jumpsavepath%\%%a\customdestinations" >nul 2>&1
		)
	)
)
:: ************************* Performing Sigcheck *************************

echo ******************************************************************** >> %logfile%
echo %DATE% %TIME%: Performing Sigcheck... | %binaries%\tee.exe -a %logfile%
echo ******************************************************************** >> %logfile%

if "%PROCESSOR_ARCHITECTURE%"=="x86" (
	if "%style%"=="old" ( 
		%binaries%\sigcheck_xp.exe -q /accepteula -c -h C:\windows\system32 > %txtsavepath%\sigcheck_system32.txt
		%binaries%\sigcheck_xp.exe -q /accepteula -c -h C:\windows\temp > %txtsavepath%\sigcheck_temp.txt
	) ELSE (
		%binaries%\sigcheck.exe -q -nobanner /accepteula -c -h C:\windows\system32 > %txtsavepath%\sigcheck_system32.txt
		%binaries%\sigcheck.exe -q -nobanner /accepteula -c -h C:\windows\temp > %txtsavepath%\sigcheck_temp.txt
	)
) ELSE (
	if "%style%"=="old" ( 
		%binaries%\sigcheck_xp.exe -q /accepteula -c -h C:\windows\system32 > %txtsavepath%\sigcheck_system32.txt
		%binaries%\sigcheck_xp.exe -q /accepteula -c -h C:\windows\temp > %txtsavepath%\sigcheck_temp.txt
	) ELSE (
		%binaries%\sigcheck64.exe -q -nobanner -accepteula -c -h C:\windows\system32 > %txtsavepath%\sigcheck_system32.txt
		%binaries%\sigcheck64.exe -q -nobanner -accepteula -c -h C:\windows\temp > %txtsavepath%\sigcheck_temp.txt
	)
)	
echo %DATE% %TIME%: Collecting Prefetch, please wait...
%binaries%\robocopy.exe %SYSTEMROOT%\Prefetch %pfsavepath% /S /E >nul 2>&1

if exist "%SYSTEMROOT%\appCompat\Programs" (
	echo %DATE% %TIME%: Collecting Amcache.hve^/RecentFileCache.bcf, please wait...

	%rawcopy% /FileNamePath:%SYSTEMROOT%\appcompat\programs\Amcache.hve /OutputPath:%amsavepath% >nul 2>&1
	%rawcopy% /FileNamePath:%SYSTEMROOT%\appcompat\programs\Amcache.hve.log1 /OutputPath:%amsavepath% >nul 2>&1
	%rawcopy% /FileNamePath:%SYSTEMROOT%\appcompat\programs\Amcache.hve.log2 /OutputPath:%amsavepath% >nul 2>&1
	%rawcopy% /FileNamePath:%SYSTEMROOT%\appcompat\programs\RecentFileCache.bcf /OutputPath:%amsavepath% >nul 2>&1
)

if exist "%SYSTEMROOT%\system32\sru" (
	echo %DATE% %TIME%: Collecting SRUM, please wait...
	%rawcopy% /Filenamepath:%SYSTEMROOT%\System32\sru\SRUDB.dat /Outputpath:%srumsavepath% >nul 2>&1
)
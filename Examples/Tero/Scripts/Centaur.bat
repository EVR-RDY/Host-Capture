:: Modified 1 APR 2022

@ECHO off
title Centaur v1.0
setlocal enabledelayedexpansion

cd /D %~dp0


echo.
echo                                    ,d                                       	
echo                                    88                                       	
echo  ,adPPYba,  ,adPPYba, 8b,dPPYba, MM88MMM ,adPPYYba, 88       88 8b,dPPYba,  	
echo a8"     "" a8P_____88 88P'   `"8a  88    ""     `Y8 88       88 88P'   "Y8  	
echo 8b         8PP""""""" 88       88  88    ,adPPPPP88 88       88 88          	
echo "8a,   ,aa "8b,   ,aa 88       88  88,   88,    ,88 "8a,   ,a88 88          	
echo  `"Ybbd8"'  `"Ybbd8"' 88       88  "Y888 `"8bbdP"Y8  `"YbbdP'Y8 88             v1.0		
echo.

echo ******************************************************************************
echo %DATE% %TIME%: Running as %USERNAME% on %computername%                                  
echo ******************************************************************************

:capture
echo.
echo.
echo                              ^-^-^-^-^-^-^-^-^-^-^-^-
echo                                CAPTURE
echo                              ^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Where are you running Centaur from?
echo.
echo 1 - Drive (External or Internal)
echo 2 - Network/Share
echo 3 - CDROM/DVD
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
echo.
if %M%==1 GOTO capture_external
if %M%==2 GOTO capture_network
if %M%==3 GOTO capture_optical

echo Invalid Choice^^!
GOTO capture

:capture_external
set external=%~d0
set tero=%~dp0..
for %%a in ("%tero:~0,-1%") DO set tero=%%~dpa
set scripts=%tero%scripts
set binaries=%tero%binaries
set capture=%tero%Capture
set rawcopy=%binaries%\rawcopy.exe
goto finish

:capture_network
set tero=%~dp0..
for %%a in ("%tero:~0,-1%") DO set tero=%%~dpa
set scripts=%tero%scripts
set binaries=%tero%binaries
set capture=%tero%Capture
set rawcopy=%binaries%\rawcopy.exe
set memory=network
goto finish

:capture_optical
set external=%~d0
set tero=%~dp0..
for %%a in ("%tero:~0,-1%") DO set tero=%%~dpa
set scripts=%tero%scripts
set binaries=%tero%binaries
set capture=C:\Capture
mkdir %capture% >nul 2>&1
goto finish

:finish
set m=%DATE:~4,2%
set d=%DATE:~7,2%
set y=%DATE:~10,4%
set hh=%TIME:~0,2%
set mm=%TIME:~3,2%
if "%hh:~0,1%"==" " (set hh=0%hh:~1,1%)
set timestamp=%y%.%m%.%d%.%hh%.%mm%
set finalsave=%capture%\%computername%--%timestamp%
mkdir "%finalsave%"

:promptcritical
echo                           ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                             CRITICAL SYSTEM
echo                           ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Is this a critical system? (Skip regular memory capture) 
echo.
echo 1 - YES
echo 2 - NO
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
if %M%==1 (
	echo.
	GOTO critical
)
if %M%==2 (
	GOTO promptmem
)

echo Invalid Choice^^!
GOTO promptcritical

:promptmem
echo.
echo                           ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                             MEMORY CAPTURE
echo                           ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Would you like to capture memory?
echo.
echo 1 - YES
echo 2 - NO
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
if %M%==1 (
	echo.
	echo %DATE% %TIME%: Memory Capture in progress^; please wait...
	if "%PROCESSOR_ARCHITECTURE%"=="x86" (
		if "%memory%"=="network" (
			"%binaries%\DumpIt.exe" /R /Q /N /J /O "C:\%computername%--%timestamp%.zdmp" >nul 2>&1
		) ELSE (
			"%binaries%\DumpIt.exe" /Q /N /J /R /O "%finalsave%\%computername%--%timestamp%.zdmp" >nul 2>&1
		)
	) ELSE (
		if "%memory%"=="network" (
			"%binaries%\DumpIt64.exe" /R /Q /N /J /O "C:\%computername%--%timestamp%.zdmp" >nul 2>&1
		) ELSE (
			"%binaries%\DumpIt64.exe" /Q /N /J /R /O "%finalsave%\%computername%--%timestamp%.zdmp"	>nul 2>&1
		)
	)
	echo %DATE% %TIME%: Memory Capture Complete^^!
	if "%memory%"=="network" (
		echo.
		echo.
		echo MAKE SURE TO TRANSFER C:\%computername%--%timestamp%.zdmp BACK TO SHARE^^!
		set /p Q= Press ENTER to continue...
		echo.
	)
	GOTO promptartifact
)
if %M%==2 (
	echo ...Skipping memory capture^^!
	GOTO promptartifact
)

echo Invalid Choice^^!
GOTO promptcritical

:critical
echo                           ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                             HIBERFIL/PAGEFILE
echo                           ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Would you like to collect Hiberfil.sys and the Pagefile instead? 
echo.
echo 1 - YES
echo 2 - NO
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
if %M%==1 (
	echo.
	echo %DATE% %TIME%: Copying hiberfil.sys; please wait...
	"%rawcopy%" /FileNamePath:C:\hiberfil.sys /OutputPath:"%finalsave%" /OutputName:%computername%_hiberfil.sys >nul 2>&1
	echo %DATE% %TIME%: Copying pagefile.sys; please wait...
	"%rawcopy%" /FileNamePath:C:\pagefile.sys /OutputPath:"%finalsave%" /OutputName:%computername%_pagefile.sys >nul 2>&1
	echo.
	echo ...Hiberfil/Pagefile Collection Complete^^!
	GOTO promptartifact
) ELSE (
	echo ...Skipping all memory collection^^!
	GOTO promptartifact
)
echo.
echo Invalid Choice^^!
GOTO promptcritical

:promptartifact
echo.
echo.
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                            ARTIFACT CAPTURE
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo Would you like to conduct a Triage Capture or Full Disk image (FTK)?
echo.
echo 1 - Triage Capture
echo 2 - Full Disk Image
echo 3 - Exit to Opnotes
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
if %M%==1 GOTO prompt_capture_type
if %M%==2 GOTO FTK
if %M%==3 GOTO opnotes
echo Invalid Choice^^!
GOTO prompt_capture_type

:prompt_capture_type
echo.
echo                        ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                          ARTIFACT CAPTURE TYPE
echo                        ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo.
echo What type of artifact capture would you like?

reg query "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\full" /v version >nul 2>&1
if %errorlevel%==0 (
	for /f "usebackq tokens=2,* skip=2" %%a in (`reg query "HKLM\Software\Microsoft\NET Framework Setup\NDP\v4\full" /v version`) do (
		set "reg=%%~b"
	)
) else (
	set net="old"
)

echo %reg% | findstr /C:"4.6" /C:"4.7" /C:"4.8" /C:"4.9" /C:"5.0" >nul 2>&1 && set net=new

for %%i in (powershell.exe) do (
	if "%%~$path:i"=="" (
		set "ps=old"
	) else (
		set "ps=new"
	)
)

set "modern=^<=================== RECOMMENDED (Powershell and .NET 4.6+ INSTALLED)"

if %net%=="old" (
	GOTO recommend_legacy
) else (
	GOTO recommend_resume
)
if %ps%=="old" (
	GOTO recommend_legacy
) else (
	GOTO recommend_resume
)

:recommend_legacy
set "legacy=^<=================== RECOMMENDED (Powershell or .NET 4.6+ MISSING)"
set "modern= "

:recommend_resume
echo.
echo 1 - MODERN  %modern%
echo 2 - LEGACY  %legacy%
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
echo.
echo                            ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                              BEGIN CAPTURE
echo                            ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
systeminfo > "%finalsave%\%computername%--%timestamp%_systeminfo.txt"
ipconfig /all > "%finalsave%\%computername%--%timestamp%_ipconfig.txt"                                                                       
if %M%==1 GOTO modern
if %M%==2 GOTO legacy
echo Invalid Choice^^!
GOTO prompt_capture_type

:modern
powershell.exe -executionpolicy bypass -command "& %scripts%\kape.ps1 %finalsave% %timestamp%" /B 1
set modern="yes"
GOTO opnotes

:legacy
call "%scripts%\legacy.bat" /B 1
set modern="no"
GOTO opnotes

:FTK
echo =========================================
echo Full disk capture will take several hours 
echo    and requires free space equivalent 
echo     to the system drive. Continue?
echo =========================================
echo.
echo 1 - Continue
echo 2 - Exit
echo.
set /P M="Select your choice, then press ENTER: "
echo.
if %M%==1 (
	"%binaries%\ftkimager_CLI.exe" %systemdrive% %finalsave%
	GOTO opnotes
)
if %M%==2 (
	GOTO opnotes
)
echo Invalid Choice^^!
GOTO FTK

:opnotes
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-
echo                                 OPNOTES
echo                          ^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-^-

echo.
if NOT exist "%capture%\Opnotes.csv" (
	echo Date,Hostname,Network,OS,Build,Building,Location,Purpose,Start,Finish,HD,Analyst,Success^?,Notes >> "%capture%\Opnotes.csv"
)

set /p date="Today's Date (eg. 01Jan2020): "
set /p start="Enter Collection Start Time (REAL time; eg. 2130): "
set /p finish="Enter Collection Finish Time (REAL time; eg. 2200): "
set /p building="Enter Building and Room Number (eg. Bldg123 Rm123): "
set /p location="Enter Physical Location of system (eg. "under desk"): "
set /p purpose="Enter System Purpose (eg. Server/HMI/Production Monitoring): "
set /p harddrive="Enter Collection Hard Drive (eg. Seagate6/S6): "
set /p analyst="Enter Analyst Name: "
set /p success="Was Collection Successful? (y/n) "
set /p notes="Enter other notes (eg. chemical produced/second capture/etc.): "

type "%finalsave%\%computername%--%timestamp%_systeminfo.txt" | findstr /L /B /c:"OS Name" > "%capture%\info.txt"
for /f "usebackq tokens=2* delims=:" %%b in (`type ^"%capture%\info.txt^"`) do (set os=%%b)
type "%finalsave%\%computername%--%timestamp%_systeminfo.txt" | findstr /L /B /c:"OS Version" > "%capture%\info.txt"
for /f "usebackq tokens=2* delims=:" %%b in (`type ^"%capture%\info.txt^"`) do (set build=%%b)

for /F "usebackq tokens=*" %%a in (`type ^"%finalsave%\%computername%--%timestamp%_ipconfig.txt^"`) do (
	echo %%a | find "Description" >> "%capture%\temp.txt"
	echo %%a | find "IP Address" >> "%capture%\temp.txt"
	echo %%a | find "Physical Address" >> "%capture%\temp.txt"
)

for /F "usebackq tokens=2* delims=:" %%a in (`type ^"%capture%\temp.txt^"`) do (
	echo %%a >> "%capture%\network.txt"
)

echo. >> "%capture%\Opnotes.csv"
echo %date%,%computername%,%network%,%os%,%build%,%building%,%location%,%purpose%,%start%,%finish%,%harddrive%,%analyst%,%success%,%notes% >> "%capture%\Opnotes.csv"

type "%capture%\network.txt" >> "%capture%\Opnotes.csv"

del "%capture%\network.txt"
del "%capture%\info.txt" 
del "%capture%\temp.txt" 

GOTO finish

:finish
echo.
if %modern%=="yes" (	
	rename "%finalsave%" %computername%--%timestamp%--KAPE 
) else (
	rename "%finalsave%" %computername%--%timestamp%--LEGACY
)
SET /P leave="Press ENTER to quit..."
break


::@set /A _toc=%time:~0,2%*3600^
::	+%time:~3,1%*10*60^
::	+%time:~4,1%*60^
::	+%time:~6,1%*60^
::	+%time:~7,1% >nul
::@set /A _elapsed=%_toc%-%_tic
::
::@echo capture Time: %_elapsed% seconds.



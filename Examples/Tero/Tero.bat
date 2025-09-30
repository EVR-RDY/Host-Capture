@echo off
title Tero v1.0
setlocal enabledelayedexpansion

echo.
echo   ,d                                                         
echo   88                                                         
echo MM88MMM  ,adPPYba, 8b,dPPYba,  ,adPPYb, 
echo   88    a8P_____88 88P'   "Y8 a8"    `Y8 
echo   88    8PP""""""" 88         8b       8 
echo   88,   "8b,   ,aa 88         "8a,   ,d8
echo   "Y888  `"Ybbd8"' 88          `"YbbdP"      v1.0
echo.
echo.

cd /D %~dp0
set external=%~d0
set tero=%~dp0
set scripts=%tero%scripts
set binaries=%tero%binaries
set capture=%tero%capture

if "%path:system32;=%" equ "%path%" (
	echo ################## ERROR^: SYSTEM32 NOT IN PATH^^! ###################
	echo.
	echo   PLEASE ADD C^:\WINDOWS\SYSTEM32 TO PATH VARIABLE BEFORE PROCEEDING...
	echo.
	echo ##################################################################### 
	echo.
	pause
	exit
	) else (
		echo ...Path environment setup correctly^^!
	)
)

openfiles >nul 2>&1
if %ERRORLEVEL% == 0 (
	echo ...Admin privileges detected^^! 
) ELSE (
   echo.
   echo ################## ERROR^: ADMIN PRIVILEGES REQUIRED^^! ###################   
   echo         Tero must be ran with Admin privileges^^!
   echo       Right click the .bat file and "Run As Administrator".
   echo ########################################################################### 
   echo.
   echo.
   pause
   EXIT /B 1
)

echo.
echo.

:choice
echo Would you like to capture or process artifacts?
echo.
echo 1 - Capture with Centaur
echo 2 - Process with Pegasus
echo.
SET /P M="Select your choice, then press ENTER: "
echo.
echo.
if %M%==1 (
	call "%scripts%\centaur.bat" /B 1
	exit
)

if %M%==2 (
	powershell.exe -executionpolicy bypass "%scripts%\Pegasus.ps1" /B 1
	exit
)

echo Invalid Choice^^!
GOTO choice


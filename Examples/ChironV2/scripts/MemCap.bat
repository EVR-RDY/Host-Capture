:: Modified 24JAN21

@echo off
title MemCap  v6.0
setlocal enabledelayedexpansion
set external=%~d0


for /f "tokens=1 delims=" %%i in (%home%scripts/path.txt) do set %%i




echo.
echo *************************************************************************
echo %DATE% %TIME%: Memory Capture in progress^; please wait... | %binaries%\tee.exe -a %logfile%
if "%PROCESSOR_ARCHITECTURE%"=="x86" %binaries%\DumpIt.exe /Q /N /J /R /O %outpath%\%computername%--%timestamp%.zdmp >nul 2>&1
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" %binaries%\DumpIt64.exe /Q /N /J /R /O %outpath%\%computername%--%timestamp%.zdmp >nul 2>&1


echo.
echo *************************************************************************
echo %DATE% %TIME%: MemCap Complete^^! ::| %binaries%\tee.exe -a %logfile%
echo *************************************************************************
echo.








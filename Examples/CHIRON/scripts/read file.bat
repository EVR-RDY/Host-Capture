@echo off
title MemCap (prompts location) v4.0
setlocal enabledelayedexpansion

:: test
:: establish variables
set external=%~d0
set home=%~dp0

for /f "tokens=1 delims=" %%i in (%home%path.txt) do set %%i
echo.
echo %home%
echo %toolpath%
echo %binaries%
echo %collection%


:: delete

set /p mem="Begin Memory Capture? (y/n) "
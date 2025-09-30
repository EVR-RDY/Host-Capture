
::echo ********************************************************************
::echo %DATE% %TIME%: Performing Dirwalk...
::echo ******************************************************************** 
::echo %DATE% %TIME%: tree C:\ /F /A ^> %ntfssavepath%\%computername%-dirwalk.txt 
::tree C:\ /F /A > %ntfssavepath%\%computername%-dirwalk.txt 

@echo off

for /f "usebackq" %%b in (`echo ^"^%path^%^" ^| findstr /i /c:^"System32^;^"`) do (
	if %%b=="" (
		echo "C:\Windows\System32 NOT FOUND IN PATH ENVIRONMENT^!"
		echo Please add before proceeding...
	) else (
		echo Path environment setup correctly^!
	)
)

pause
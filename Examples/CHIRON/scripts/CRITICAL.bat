:: Modified 24JAN2021


set hiberfilsavepath="%outpath%\hiberfil"
%binaries%\mkdir.exe -p %hiberfilsavepath% >nul 2>&1
echo %DATE% %TIME%: Copying hiberfil.sys; please wait...
%rawcopy% /FileNamePath:C:\hiberfil.sys /OutputPath:%hiberfilsavepath% >nul 2>&1

set pagefilesavepath="%outpath%\pagefile"
%binaries%\mkdir.exe -p %pagefilesavepath% >nul 2>&1
echo %DATE% %TIME%: Copying pagefile.sys; please wait...
%rawcopy% /FileNamePath:C:\pagefile.sys /OutputPath:%pagefilesavepath%  >nul 2>&1
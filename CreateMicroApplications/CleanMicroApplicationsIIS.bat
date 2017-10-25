::Notes

@set appCMD=%systemroot%/system32/inetsrv/APPCMD
@set siteName=Alpha-Microsites2
@set poolName=%siteName%
@set isRemoveMicrositeSources=0

@echo off
@setlocal EnableDelayedExpansion


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Remove Web Applications 
@set appPrefix=site
@set "webApplications[0]=%appPrefix%-main"
@set "webApplications[1]=%appPrefix%-oldmain"
@set "webApplications[2]=%appPrefix%-results"
@set "webApplications[3]=%appPrefix%-totalbetsforecast"
@set "webApplications[4]=%appPrefix%-userguilde"
@set "webApplications[5]=%appPrefix%-howtouse"
@set "webApplications[6]=%appPrefix%-betlist"

@REM Get Web Applications Length
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set webApplications[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set "webApplication=!webApplications[%%i]!"
	@call %appCMD% list app /site.name:"%siteName%" /path:"/!webApplication!"
	@if "!ERRORLEVEL!"=="0" (
		@call %appCMD% delete app /app.name:"%siteName%/!webApplication!"
	)
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Remove Virtual Directories
@set virtualDirectories[0]=contents
@set virtualDirectories[1]=assets

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set virtualDirectories[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set virtualDirectory=!virtualDirectories[%%i]!
	@call %appCMD% list vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!"
	@if "!ERRORLEVEL!"=="0" (
		@call %appCMD% delete vdir /vdir.name:"%siteName%/!virtualDirectory!"
	)
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Remove Site
@call %appCMD% list site /name:"!siteName!"
@if "%ERRORLEVEL%"=="0" (
	@call %appCMD% delete site /site.name:"%siteName%"
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Remove Application Pool
@call %appCMD% list apppool /name:"%poolName%"
@if "%ERRORLEVEL%"=="0" (
	@call %appCMD% delete apppool /apppool.name:"%poolName%"	
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Remove MicrositeHost
@set micrositeHost=D:\MicrositeHost\%siteName%
@if exist !micrositeHost! rd /s /q !micrositeHost!

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Remove MicrositeSources
@if %isRemoveMicrositeSources%==1 (
	@set micrositeSources=D:\MicrositeSources
	@if exist !micrositeSources! rd /s /q !micrositeSources!
)

@pause
@exit /b













































































@REM Please put this in the same folder with all micro-site folders

@set currentFolder=%cd%
@set appCMD=%systemroot%/system32/inetsrv/APPCMD

@set siteName=Alpha-Microsites2
@set poolName=%siteName%
@set netFrameworkVersion="v4.0"

@set directory=%currentFolder%\RootSite
@set microSiteSources=D:\MicrositeSources
@set port=9999

@REM Can use List=(value1 value2) but hard to get value by index: List[index]
@set virtualDirectories[0]=contents
@set virtualDirectoryFolders[0]=alpha-contents\Alpha.Contents

@set appPrefix=site
@set webApplications[0]=%appPrefix%-main
@set webApplications[1]=%appPrefix%-oldmain
@set webApplications[2]=%appPrefix%-results
@set webApplications[3]=%appPrefix%-totalbetsforecast

@set folderIndex=
@set webApplicationFolders[0]=alpha-dashboard%folderIndex%\Alpha.Main.Site\Alpha.Main.Site
@set webApplicationFolders[1]=after-login-website%folderIndex%\Fanex_Razorbill_Website
@set webApplicationFolders[2]=alpha-results%folderIndex%\Alpha.Results
@set webApplicationFolders[3]=alpha-totalbetsforecast%folderIndex%\Alpha.TotalBetsForecast\Alpha.TotalBetsForecast

@set batchFolders[0]=alpha-dashboard%folderIndex%\Alpha.Main.Site
@set batchFolders[1]=after-login-website%folderIndex%
@set batchFolders[2]=alpha-results%folderIndex%
@set batchFolders[3]=alpha-totalbetsforecast%folderIndex%\Alpha.TotalBetsForecast

@set buildCodeTask=AutoBuildLastestCodeTask.bat
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
@setlocal EnableDelayedExpansion

@cd %microSiteSources%
@set sourceCodeFolder=%microSiteSources%\


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Application Pool
@call %appCMD% list apppool /name:"%poolName%"
@if "%ERRORLEVEL%"=="1" (
	@call %appCMD% add apppool /name:"%poolName%"
	@call %appCMD% set apppool /apppool.name:"%poolName%" /managedRuntimeVersion:"%netFrameworkVersion%"
)


@REM Create Site
@if not exist %directory% mkdir %directory%
@call %appCMD% list site /name:"%siteName%"
@if "%ERRORLEVEL%"=="1" (
	@call %appCMD% add site /name:"%siteName%" /physicalPath:"%directory%" /bindings:http/*:%port%:
	@call %appCMD% migrate config "%siteName%/"
	@call %appCMD% set site /site.name:"%siteName%" /[path='/'].applicationPool:"%poolName%"
	@call %appCMD% start site "%siteName%"
)


@REM Get Virtual Directory Length
@REM for getting List=(value1 value2) length, use for /L %%l in %List%
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set virtualDirectories[') do (
	@set /a maxIndex=maxIndex+1
)

@REM Create Virtual Directories
@for /L %%i in (0,1,!maxIndex!) do (
	@set virtualDirectory=!virtualDirectories[%%i]!
	@set virtualDirectoryFolder=!virtualDirectoryFolders[%%i]!
	
	@call %appCMD% list vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!"
	@if "!ERRORLEVEL!"=="1" (
		@REM the / following %siteName% specifies: the virtual directory should be added to the root application of the site.
		@call %appCMD% add vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!" /physicalPath:"%currentFolder%\!virtualDirectoryFolder!"
	)
)	
	
@REM Get Web Applications Length
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set webApplications[') do (
	@set /a maxIndex=maxIndex+1
)

@REM Create Web Applications 
@for /L %%i in (0,1,!maxIndex!) do (
	@set webApplication=!webApplications[%%i]!
	@set webApplicationFolder=!webApplicationFolders[%%i]!
	@call %appCMD% list app /site.name:"%siteName%" /path:"/!webApplication!"
	@if "!ERRORLEVEL!"=="1" (
		@call %appCMD% add app /apppool.name:"%poolName%" /site.name:"%siteName%" /path:"/!webApplication!" /physicalPath:"%currentFolder%\!webApplicationFolder!"
	)
)

@REM Build Code Task
@for /L %%i in (0,1,!maxIndex!) do (
	@set batchFolder=%currentFolder%\!batchFolders[%%i]!
	@cd !batchFolder!
	@for %%f in (*) do (
		@if /i "%%f"=="%buildCodeTask%" (
			@start %%f
		)
	)
)

@pause




































::Notes
::1.Must put in folder to clone/update sources
::2.Must have permission to view folder C:\Windows\System32\inetsrv\config
::3.Start w3svc Service: enable the IIS Hostable Web Core.
::4.Error the w3svc service is not available: Run file batch as Administrator
::5. Must config SSH for pulling code: http://learnaholic.me/2012/10/12/make-powershell-and-git-suck-less-on-windows/

@set currentFolder=%cd%
@for /F %%I in ("%0") do @set currentFolder=%%~dpI

@set PATH=%PATH%;C:\Program Files (x86)\Git\bin;C:\Program Files\Git\bin
@set microSiteSources=%currentFolder%

@set isCloneCode=0
@set isUpdateCode=1
@set isBuildCode=0
@set isArrangeIIS=0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
@setlocal EnableDelayedExpansion

@if %isCloneCode%==1 (
	@if not exist %microSiteSources% mkdir %microSiteSources%
	@call :CloneSources
)

@if %isUpdateCode%==1 (
	@if not exist %microSiteSources% mkdir %microSiteSources%
	@call :PullCode
)


@if %isBuildCode%==1 (
	@call :BuildCode
)

@if %isArrangeIIS%==1 (
	@call :ArrangeIIS
)

@pause
@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CloneSources
@setlocal enableDelayedExpansion

@REM Can use List=(value1 value2) but hard to get value by index: List[index]
@set gitCode[0]=git@gitlab.nexcel.vn:agency-i1/after-login-website.git
@set gitCode[1]=git@gitlab.nexcel.vn:fanex-alpha/alpha-newmain.git
@set gitCode[2]=git@gitlab.nexcel.vn:fanex-alpha/alpha-assets.git
@set gitCode[3]=git@gitlab.nexcel.vn:fanex-alpha/alpha-results.git
@set gitCode[4]=git@gitlab.nexcel.vn:fanex-alpha/alpha-totalbetsforecast.git
@set gitCode[5]=git@gitlab.nexcel.vn:fanex-alpha/alpha-betlists.git
@set gitCode[6]=git@gitlab.nexcel.vn:fanex-alpha/alpha-configurationsharing.git
@set gitCode[7]=git@gitlab.nexcel.vn:fanex-alpha/alpha-howtouse.git
@set gitCode[8]=git@gitlab.nexcel.vn:fanex-alpha/alpha-userguide.git
@set gitCode[9]=git@gitlab.nexcel.vn:fanex-alpha/alpha-reports.git
@set gitCode[10]=git@gitlab.nexcel.vn:fanex-alpha/alpha-modules.git

@set sourceCodes[0]=after-login-website
@set sourceCodes[1]=alpha-newmain
@set sourceCodes[2]=alpha-assets
@set sourceCodes[3]=alpha-results
@set sourceCodes[4]=alpha-totalbetsforecast
@set sourceCodes[5]=alpha-betlists
@set sourceCodes[6]=alpha-configurationsharing
@set sourceCodes[7]=alpha-howtouse
@set sourceCodes[8]=alpha-userguide
@set sourceCodes[9]=alpha-reports
@set sourceCodes[10]=alpha-modules


@set sourceCodeFolder=%microSiteSources%
@cd !sourceCodeFolder!

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set gitCode[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set gitCode=!gitCode[%%i]!
	@git clone !gitCode! !sourceCodeFolder!\!sourceCodes[%%i]!
)	

@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PullCode
@setlocal enableDelayedExpansion

@set sourceCodes[0]=after-login-website
@set sourceCodes[1]=alpha-newmain\Alpha.Main.Site
@set sourceCodes[2]=alpha-assets
@set sourceCodes[3]=alpha-results
@set sourceCodes[4]=alpha-totalbetsforecast\Alpha.TotalBetsForecast
@set sourceCodes[5]=alpha-betlists
@set sourceCodes[6]=alpha-configurationsharing
@set sourceCodes[7]=alpha-howtouse
@set sourceCodes[8]=alpha-userguide
@set sourceCodes[9]=alpha-reports
@set sourceCodes[10]=alpha-modules

@set sourceCodeFolder=%microSiteSources%
@cd !sourceCodeFolder!

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set sourceCodes[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@echo Pull code !sourceCodeFolder!!sourceCodes[%%i]!
	@cd !sourceCodeFolder!!sourceCodes[%%i]!
	@git pull
)	

@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:BuildCode
@setlocal enableDelayedExpansion

@set sourceCodes[0]=after-login-website
@set sourceCodes[1]=alpha-newmain\Alpha.Main.Site
@set sourceCodes[2]=alpha-assets
@set sourceCodes[3]=alpha-results
@set sourceCodes[4]=alpha-totalbetsforecast\Alpha.TotalBetsForecast
@set sourceCodes[5]=alpha-betlists
@set sourceCodes[6]=alpha-configurationsharing
@set sourceCodes[7]=alpha-howtouse
@set sourceCodes[8]=alpha-userguide
@set sourceCodes[9]=alpha-reports
@set sourceCodes[10]=alpha-modules

@set sourceCodeFolder=%microSiteSources%
@set builCodeTaskDev=BuildTask.Dev.bat
@set builCodeTask=BuildTask.Release.bat


@cd !sourceCodeFolder!

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set sourceCodes[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set sourceCode=!sourceCodes[%%i]!
    @cd !sourceCodeFolder!!sourceCode!
	@set buildTaskPath=!sourceCodeFolder!!sourceCode!\!builCodeTaskDev!
	@if exist !buildTaskPath! (
		@echo Build: !buildTaskPath!
		@call start !buildTaskPath!
	) else (	
		@set buildTaskPath=!sourceCodeFolder!!sourceCode!\!builCodeTask!
		@if exist !buildTaskPath! (
			@echo Build: !buildTaskPath!
			@call start !buildTaskPath!
		)	
	)
)	

@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ArrangeIIS
@setlocal enableDelayedExpansion

@set appCMD=%systemroot%/system32/inetsrv/APPCMD
@set netFrameworkVersion="v4.0"

@set siteName=Alpha-Microsites5
@set port=9005

@cd %currentFolder%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Application Pool
@set poolName=!siteName!
@call %appCMD% list apppool /name:"!poolName!"
@if "%ERRORLEVEL%"=="1" (
	@echo %appCMD%\!poolName!
	@call %appCMD% add apppool /name:"!poolName!"
	@call %appCMD% set apppool /apppool.name:"!poolName!" /managedRuntimeVersion:"%netFrameworkVersion%"
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Site
@set micrositeHost=!microSiteSources!alpha-configurationsharing\Alpha.ConfigurationSharing
@if not exist !micrositeHost! mkdir !micrositeHost!
@call %appCMD% list site /name:"!siteName!"
@if "%ERRORLEVEL%"=="1" (
	@call %appCMD% add site /name:"!siteName!" /physicalPath:"!micrositeHost!" /bindings:http/*:%port%:
	@call %appCMD% migrate config "!siteName!/"
	@call %appCMD% set site /site.name:"!siteName!" /[path='/'].applicationPool:"!poolName!"
	@call %appCMD% start site "!siteName!"
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Virtual Directories
@set virtualDirectories[0]=assets

@REM Get Virtual Directory Length
@REM for getting List=(value1 value2) length, use for /L %%l in %List%
@set maxIndex=-1
@set virtualDirectoryFolders[0]=alpha-assets\assets
@for /F "tokens=2 delims==" %%s in ('set virtualDirectories[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set virtualDirectory=!virtualDirectories[%%i]!
	@set virtualDirectoryFolder=!microSiteSources!!virtualDirectoryFolders[%%i]!
	
	@call %appCMD% list vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!"
	@if "!ERRORLEVEL!"=="1" (
		@REM the / following %siteName% specifies: the virtual directory should be added to the root application of the site.
		@call %appCMD% add vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!" /physicalPath:"!virtualDirectoryFolder!"
	)
)	
	
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Web Applications 
@set appPrefix=site
@set webApplications[0]=%appPrefix%-main
@set webApplications[1]=ex-main
@set webApplications[2]=%appPrefix%-results
@set webApplications[3]=%appPrefix%-totalbetsforecast
@set webApplications[4]=%appPrefix%-userguilde
@set webApplications[5]=%appPrefix%-howtouse
@set webApplications[6]=%appPrefix%-betlist
@set webApplications[7]=%appPrefix%-reports

@set webApplicationFolders[0]=alpha-newmain\Alpha.Main.Site\Alpha.Main.Site
@set webApplicationFolders[1]=after-login-website\Fanex_Razorbill_Website
@set webApplicationFolders[2]=alpha-results\Alpha.Results
@set webApplicationFolders[3]=alpha-totalbetsforecast\Alpha.TotalBetsForecast\Alpha.TotalBetsForecast.Site
@set webApplicationFolders[4]=alpha-userguide\Alpha.UserGuide
@set webApplicationFolders[5]=alpha-howtouse\Alpha.HowToUse
@set webApplicationFolders[6]=alpha-betlists\Alpha.BetLists.Site
@set webApplicationFolders[7]=alpha-reports\Alpha.Reports.Site

@REM Get Web Applications Length
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set webApplications[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set webApplication=!webApplications[%%i]!
	@set webApplicationFolder=!microSiteSources!!webApplicationFolders[%%i]!
	@call %appCMD% list app /site.name:"%siteName%" /path:"/!webApplication!"
	@if "!ERRORLEVEL!"=="1" (
		@call %appCMD% add app /apppool.name:"%poolName%" /site.name:"%siteName%" /path:"/!webApplication!" /physicalPath:"!webApplicationFolder!"
	)
)

@exit /b



























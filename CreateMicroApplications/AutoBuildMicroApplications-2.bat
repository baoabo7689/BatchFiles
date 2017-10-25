::Notes
::1.Must have driver D
::2.Must have permission to view folder C:\Windows\System32\inetsrv\config
::3.Start w3svc Service: enable the IIS Hostable Web Core.
::4.Error the w3svc service is not available: Run file batch as Administrator
::5. Must config SSH for pulling code: http://learnaholic.me/2012/10/12/make-powershell-and-git-suck-less-on-windows/


:: Configurations
@set microSiteSources=D:\MicrositeSources

@set isCloneCode=0
@set isBuildCode=0
@set isArrangeIIS=0


@REM Can use List=(value1 value2) but hard to get value by index: List[index]
:: Source codes from gitlab
@set sourceCodes[0]=git@gitlab.nexcel.vn:agency-i1/after-login-website.git

@set sourceCodes[1]=git@gitlab.nexcel.vn:fanex-alpha/alpha-configurationsharing.git
@set sourceCodes[2]=git@gitlab.nexcel.vn:fanex-alpha/alpha-assets.git

@set sourceCodes[3]=git@gitlab.nexcel.vn:fanex-alpha/alpha-results.git
@set sourceCodes[4]=git@gitlab.nexcel.vn:fanex-alpha/alpha-howtouse.git
@set sourceCodes[5]=git@gitlab.nexcel.vn:fanex-alpha/alpha-userguide.git
@set sourceCodes[6]=git@gitlab.nexcel.vn:fanex-alpha/alpha-totalbetsforecast.git
@set sourceCodes[7]=git@gitlab.nexcel.vn:fanex-alpha/alpha-extotalbetsforecast.git

@set sourceCodes[8]=git@gitlab.nexcel.vn:fanex-alpha/alpha-newmain.git
@set sourceCodes[9]=git@gitlab.nexcel.vn:fanex-alpha/alpha-viewlogs.git
@set sourceCodes[10]=git@gitlab.nexcel.vn:fanex-alpha/alpha-betlists.git
@set sourceCodes[11]=git@gitlab.nexcel.vn:fanex-alpha/alpha-reports.git
@set sourceCodes[12]=git@gitlab.nexcel.vn:fanex-alpha/alpha-memberinfo.git
@set sourceCodes[13]=git@gitlab.nexcel.vn:fanex-alpha/alpha.messages.git

@set sourceCodes[14]=git@gitlab.nexcel.vn:fanex-alpha/alpha-modules.git
@set sourceCodes[15]=git@gitlab.nexcel.vn:fanex-alpha/alpha-maintenance.git


:: Folder contains solution file/build file
:: If same structure, can loop through sub folder in microSiteSources to build
@set solutionFolders[0]=after-login-website

@set solutionFolders[1]=alpha-configurationsharing
@set solutionFolders[2]=alpha-assets

@set solutionFolders[3]=alpha-results
@set solutionFolders[4]=alpha-howtouse
@set solutionFolders[5]=alpha-userguide
@set solutionFolders[6]=alpha-totalbetsforecast\Alpha.TotalBetsForecast
@set solutionFolders[7]=alpha-extotalbetsforecast

@set solutionFolders[8]=alpha-newmain\Alpha.Main.Site
@set solutionFolders[9]=alpha-viewlogs
@set solutionFolders[10]=alpha-betlists
@set solutionFolders[11]=alpha-reports
@set solutionFolders[12]=alpha-memberinfo
@set solutionFolders[13]=alpha.messages

@set solutionFolders[14]=alpha-modules
@set solutionFolders[15]=alpha-maintenance


@set siteName=Alpha-Microsites3
@set port=9008

:: Virtual Directories
@set virtualDirectories[0]=assets
@set virtualDirectoryFolders[0]=alpha-assets\assets

:: Web Applications
@set appPrefix=site
@set webApplications[0]=%appPrefix%-main
@set webApplications[1]=ex-main
@set webApplications[2]=%appPrefix%-results
@set webApplications[3]=%appPrefix%-totalbetsforecast
@set webApplications[4]=%appPrefix%-userguilde
@set webApplications[5]=%appPrefix%-howtouse
@set webApplications[6]=%appPrefix%-betlist
@set webApplications[7]=%appPrefix%-viewlogs
@set webApplications[8]=%appPrefix%-memberinfo
@set webApplications[9]=%appPrefix%-messages
@set webApplications[10]=ex-totalbetsforecast
@set webApplications[11]=%appPrefix%-reports

@set webApplicationFolders[0]=alpha-newmain\Alpha.Main.Site\Alpha.Main.Site
@set webApplicationFolders[1]=after-login-website\Fanex_Razorbill_Website
@set webApplicationFolders[2]=alpha-results\Alpha.Results
@set webApplicationFolders[3]=alpha-totalbetsforecast\Alpha.TotalBetsForecast\Alpha.TotalBetsForecast.Site
@set webApplicationFolders[4]=alpha-userguide\Alpha.UserGuide
@set webApplicationFolders[5]=alpha-howtouse\Alpha.HowToUse
@set webApplicationFolders[6]=alpha-betlists\src\Alpha.BetLists.Site
@set webApplicationFolders[7]=alpha-viewlogs\Alpha.ViewLogs.Site
@set webApplicationFolders[8]=alpha-memberinfo\src\Alpha.MemberInfo.Site
@set webApplicationFolders[9]=alpha.messages\Alpha.Messages\Alpha.Messages.Site
@set webApplicationFolders[10]=alpha-extotalbetsforecast\Alpha.Ex.TotalBetsForecast.Site
@set webApplicationFolders[11]=alpha-reports\src\Alpha.Reports.Site


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@set currentFolder=%cd%
@set PATH=%PATH%;C:\Program Files (x86)\Git\bin


@echo off
@setlocal EnableDelayedExpansion


@if %isCloneCode%==1 (
	@if not exist %microSiteSources% mkdir %microSiteSources%
	@call :CloneSources
)

@if %isBuildCode%==1 (
	@call :BuildCodes
)

@if %isArrangeIIS%==1 (
	@call :ArrangeIIS
)

@pause
@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CloneSources
@setlocal enableDelayedExpansion

@set sourceCodeFolder=%microSiteSources%
@cd !sourceCodeFolder!

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set sourceCodes[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set sourceCode=!sourceCodes[%%i]!
	@git clone !sourceCode!
)	

@exit /b



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:BuildCodes
@setlocal enableDelayedExpansion

@set sourceCodeFolder=%microSiteSources%
@set builCodeTask=BuildTask.Release.bat

@cd !sourceCodeFolder!

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set solutionFolders[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set solutionFolder=!solutionFolders[%%i]!
	@set buildTaskPath=!sourceCodeFolder!\!solutionFolder!\!builCodeTask!
	
	@if exist !sourceCodeFolder!\!solutionFolder! (
		@cd !sourceCodeFolder!\!solutionFolder!
	)
	
	@if exist !buildTaskPath! (
		@call start !buildTaskPath!
		
		::Must separate comment and line of code above
		::Auto close batch, put exit in bottom of main code
	)
)	

@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ArrangeIIS
@setlocal enableDelayedExpansion

@set appCMD=%systemroot%/system32/inetsrv/APPCMD
@set netFrameworkVersion="v4.0"

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
@set micrositeHost=%microSiteSources%\alpha-configurationsharing\Alpha.ConfigurationSharing
@if not exist !micrositeHost! mkdir !micrositeHost!
@call %appCMD% list site /name:"!siteName!"
@if "%ERRORLEVEL%"=="1" (
	@call %appCMD% add site /name:"!siteName!" /physicalPath:"!micrositeHost!" /bindings:http/*:%port%:
	@call %appCMD% migrate config "!siteName!/"
	@call %appCMD% set site /site.name:"!siteName!" /[path='/'].applicationPool:"!poolName!"
	@call %appCMD% set site /site.name:"!siteName!" /[path='/'].preloadEnabled:"True"
	@call %appCMD% start site "!siteName!"
)


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Virtual Directories

@REM Get Virtual Directory Length
@REM for getting List=(value1 value2) length, use for /L %%l in %List%
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set virtualDirectories[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set virtualDirectory=!virtualDirectories[%%i]!
	@set virtualDirectoryFolder=!microSiteSources!\!virtualDirectoryFolders[%%i]!
	
	@call %appCMD% list vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!"
	@if "!ERRORLEVEL!"=="1" (
		@REM the / following %siteName% specifies: the virtual directory should be added to the root application of the site.
		@call %appCMD% add vdir /app.name:"%siteName%/" /path:"/!virtualDirectory!" /physicalPath:"!virtualDirectoryFolder!"
	)
)	


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@REM Create Web Applications 

@REM Get Web Applications Length
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set webApplications[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set webApplication=!webApplications[%%i]!
	@set webApplicationFolder=!microSiteSources!\!webApplicationFolders[%%i]!
	@call %appCMD% list app /site.name:"%siteName%" /path:"/!webApplication!"
	@if "!ERRORLEVEL!"=="1" (
		@call %appCMD% add app /apppool.name:"%poolName%" /site.name:"%siteName%" /path:"/!webApplication!" /physicalPath:"!webApplicationFolder!" /preloadEnabled:"True"
	)
)

@exit /b










































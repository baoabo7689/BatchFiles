:: Notes
:: 1.Version Pre-release: 3.0.2.9-BetListPermission-07 -Pre
:: 2.Must have git folder: C:\Program Files\Git\cmd
:: 3.Maybe support more: push code, install nugets, build

@set packages[0]=Sunplus.Agent.Model.Base
@set packages[1]=Alpha.SubAccount

@set versions[0]=3.0.2.7
@set versions[1]=1.0.0-BetListPermission-01 -Pre

@set updateNugets=1
@set restoreNugets=1

@cd /d "%~dp0"
@set currentFolder=%cd%

@set gitFolder=C:\Program Files\Git\cmd
@set nugetExe=%currentFolder%\tools\NuGet.exe
@set revertChanges=0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@set solutions[0]=after-login-website\Fanex.Razorbill.sln
@set solutions[1]=alpha.messages\Alpha.Messages.sln
@set solutions[2]=alpha-assets\Alpha.Assets.sln

@set solutions[3]=alpha-betlists\Alpha.BetLists.sln
@set solutions[4]=alpha-configurationsharing\Alpha.ConfigurationSharing.sln
@set solutions[5]=alpha-extotalbetsforecast\Alpha.Ex.TotalBetsForecast.sln
@set solutions[6]=alpha-howtouse\Alpha.HowToUse.sln
@set solutions[7]=alpha-memberinfo\Alpha.MemberInfo.sln

@set solutions[8]=alpha-modules\Fanex.Alpha.Modules.sln
@set solutions[9]=alpha-newmain\Alpha.Main.Site\Alpha.Main.Site.sln
@set solutions[10]=alpha-reports\Alpha.Reports.Site.sln
@set solutions[11]=alpha-results\Alpha.Results.sln
@set solutions[12]=alpha-totalbetsforecast\Alpha.TotalBetsForecast\Alpha.TotalBetsForecast.sln
@set solutions[13]=alpha-userguide\Alpha.UserGuide.sln

@set solutions[14]=alpha-viewlogs\Alpha.ViewLogs.sln


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@set solutionFolders[0]=after-login-website
@set solutionFolders[1]=alpha.messages
@set solutionFolders[2]=alpha-assets

@set solutionFolders[3]=alpha-betlists
@set solutionFolders[4]=alpha-configurationsharing
@set solutionFolders[5]=alpha-extotalbetsforecast
@set solutionFolders[6]=alpha-howtouse
@set solutionFolders[7]=alpha-memberinfo

@set solutionFolders[8]=alpha-modules
@set solutionFolders[9]=alpha-newmain
@set solutionFolders[10]=alpha-reports
@set solutionFolders[11]=alpha-results
@set solutionFolders[12]=alpha-totalbetsforecast
@set solutionFolders[13]=alpha-userguide

@set solutionFolders[14]=alpha-viewlogs

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
@setlocal EnableDelayedExpansion

@if %revertChanges%==1 (
	@call :RevertChanges
)

@if %restoreNugets%==1 (
	@call :RestoreNugets
)

@if %updateNugets%==1 (
	@set maxIndex=-1
	@for /F "tokens=2 delims==" %%s in ('set packages[') do (
		@set /a maxIndex=maxIndex+1
	)
	@for /L %%i in (0,1,!maxIndex!) do (
		@set configPackage=!packages[%%i]!
		@set configVersion=!versions[%%i]!
		@call :UpdateNugetForSolutions configPackage configVersion
	)	
)

@pause
@exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RevertChanges
@setlocal enableDelayedExpansion

@set originalPath=%PATH%
@set PATH=%originalPath%;%gitFolder%

@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set solutionFolders[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set solutionFolder=%currentFolder%\!solutionFolders[%%i]!
	@echo Reset changes !solutionFolder!
	@cd !solutionFolder!
	@call git reset --hard
	@call git clean -fdx
)

:EndRevertChanges
@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RestoreNugets
@setlocal enableDelayedExpansion
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set solutions[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set solution=%currentFolder%\!solutions[%%i]!
	@echo Restore Nugets !solution!
	@call %nugetExe% restore !solution!
)

@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:UpdateNugetForSolutions package version
@setlocal enableDelayedExpansion
@set package=!%~1!
@set version=!%~2!
@set maxIndex=-1
@for /F "tokens=2 delims==" %%s in ('set solutions[') do (
	@set /a maxIndex=maxIndex+1
)

@for /L %%i in (0,1,!maxIndex!) do (
	@set solution=%currentFolder%\!solutions[%%i]!	
	@echo Update Nugets !solution! !package! !version!
	@call %nugetExe% Update !solution! -Id !package! -Version !version!
)

:EndUpdateNugetForSolutions
@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FindSolution folder
@set folder=!%~1!
@cd !folder!

@call :FindSolution_WithoutSubFolder

@for /d /r "%folder%" %%a in (*) do (
	@cd  %%a	
	@call :FindSolution_WithoutSubFolder
)

:EndFindSolution

@exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FindSolution_WithoutSubFolder

@for %%f in (*) do (
	@set "extenstion=%%~xf"
	@if /i "!extenstion!"==".sln" (
		@echo %%f
		@goto :EndFindSolution
	)
)

:EndFindSolution

@exit /b









































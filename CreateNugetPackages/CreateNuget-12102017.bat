:: Notes
:: 1. Build Solution Before Run This
:: 2. Must have .nuget Folder
:: 3. Please set Nuget API Key with your API key got from server by command: 
::			nuget setApiKey Your-API-Key -Source http://nuget.nexcel.vn/
:: 4. Update nuget.exe >= to run command  with -Prerelease filter
:: 5. Currently some packages has name is not same with source code (case sensitive) => when get info must use case-insensitive

:: set /a a=08+1 will error
:: invalid number. numeric constants are either decimal hexadecimal octal

@set "nugetSource=http://nuget.nexdev.net"
@set "defaultPackageVersionSuffix=-BetListPermission-08"

@set webSiteFolder=Fanex_Razorbill_Website
@REM copy all change of website to temp folder to create package 

@set binFolder=bin
@REM maybe this not used

@set "nugetAuthor=Nexcel Solution"
@set commitHashTest=

@set isBuildLatestCode=0
@set waitingForEditPackages=1
@set publishPackage=0
@set deleteTempFolder=0

@REM cd /d "%~dp0"
@set currentFolder=%cd%
@set pathSeparator=\

@set solutionPath=%currentFolder%
@set autoBuildLastestCodeTask=%currentFolder%\AutoBuildLastestCodeTask.bat

@set nugetPath="%solutionPath%\.nuget\Nuget.exe"
@set baseDirectory=%solutionPath%\basenuspec
@set libDirectory=lib\net40
@set contentDirectory=Contents
@set tempGitFile=gitMessage.txt
@set PATH=%PATH%;C:\Program Files (x86)\Git\bin
@set extensionSeparator=.
@set gitPathSeparator=/
@set languageList=(ja-JP,ko-KR,th-TH,vi-VN,zh-CN,zh-TW)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
@setlocal EnableDelayedExpansion

::Pull&Build Origin Code
@if "%isBuildLatestCode%"=="1" (
	@call %autoBuildLastestCodeTask%
)

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@cd %solutionPath%

::Get Git Commit Changes
@if exist !tempGitFile! del !tempGitFile!

::git show !commitHash! > "!tempGitFile!"
@if "%commitHashTest%"=="" (
	@call git log -1 --name-only > "!tempGitFile!"	
) else (
	@call git log -1 %commitHashTest% --name-only > "!tempGitFile!"	
)

@set index=0
@set commitLineIndex=0
@set messageLineIndex=4

@set changesIndex=0

::commit prefix=7
@for /f "tokens=1* delims=:" %%A in ('type "%tempGitFile%" ^| findstr /n "^"') do (
	@if !index!==!commitLineIndex! (
		@set "commitHash=%%B"		
		@set "commitHash=!commitHash:~7,-1!"
	)
	
	@if !index!==!messageLineIndex! (
		@set commitMessage=%%B
		@call :Trim trimmedCommitMessage !commitMessage!
		@if "!trimmedCommitMessage!"=="" (
			@set messageLineIndex=5
			
		)
	)
	
	@set /a index=!index! + 1
)
 
@del !tempGitFile!

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@if "%commitHashTest%"=="" (	
	@call git diff !commitHash!~1 --name-only > "!tempGitFile!"	
) else (
	@call git diff %commitHashTest%~1 --name-only > "!tempGitFile!"	
)


@for /f "tokens=1* delims=:" %%A in ('type "%tempGitFile%" ^| findstr /n "^"') do (
	@call :Trim trimmedChange %%B
	@if "!trimmedChange!" neq "" (
		@call :ReplaceChar trimmedChange gitPathSeparator pathSeparator standardizedChange
		@set gitChanges[!changesIndex!]=!standardizedChange!
		@set /a changesIndex=!changesIndex! + 1
	)
)

@del !tempGitFile!
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::REM Prepare Nuget Folders
@if exist %baseDirectory%  RMDIR /s /q %baseDirectory%
@MKDIR %baseDirectory%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::Process Git Commit Changes
@set changeLength=!changesIndex!
@set packageIndex=1

@for /L %%i in (0,1,!changeLength!) do (
	@set gitChange=!gitChanges[%%i]!
	@if "!gitChange!" neq "" (
		@set "text=!gitChange!"
		@set "currentPath="
		@call :PackageFolder text currentPath packageFolder
		@if !packageFolder! neq "" (
			@if /i !packageFolder!==%solutionPath%%pathSeparator%%webSiteFolder% (
				@REM Copy All Files in Web Site Folder to Package		
				@REM Must have * in the end, xcopy prompt for File or Directory
				@REM We can remove file name in destination path
				@call xcopy /y %solutionPath%%pathSeparator%!gitChange! %baseDirectory%%pathSeparator%!gitChange!* >NUL
			) else (		
				@set oldPackageIndex=!packageIndex!
				@call :InitFolder packageFolder packageIndex packageName packageVersion
				@if !oldPackageIndex! neq !packageIndex! (
					@set packageNames[!oldPackageIndex!]=!packageName!
					@set packageVersions[!oldPackageIndex!]=!packageVersion!
					@set oldPackageIndex=!packageIndex!
				)
				
				@if "!packageVersion!" neq "" (
					@call :CopyPackageFile packageFolder text
				)
			)
		)
	)	
)

@if %packageIndex% LEQ 1 (
	@echo No package found.
	@goto :CompleteAllTask
)
	
@set /a endIndex=%packageIndex%-1
@if %waitingForEditPackages%==1 (
	@echo Please review package versions, edit dependencies with format ^<dependency id="dependencyId" version="dependencyVersion" /^> and press enter after that
	@echo %baseDirectory%:

	@for /l %%a in (1,1,%endIndex%) do (
		@echo    Package !packageNames[%%a]! version: !packageVersions[%%a]!
	)

	@pause
	@echo.	
)

::Create Nuget Packages
@cd %baseDirectory%
@for /l %%a in (1,1,%endIndex%) do (
	@set packagePath=%baseDirectory%%pathSeparator%!packageNames[%%a]!
	@call %nugetPath% pack !packagePath!.nuspec -BasePath !packagePath! 
	@echo    Created !packagePath!.nupkg
)

::Upload Nuget Packages
@if %publishPackage%==1 (
	@for /l %%a in (1,1,%endIndex%) do (
		@set packagePath=%baseDirectory%%pathSeparator%!packageNames[%%a]!
		@if %publishPackage%==1 (
			@call %nugetPath% push !packagePath!.!packageVersions[%%a]!.nupkg -Source %nugetSource%
		)
		
		@echo    Uploaded !packagePath!.nupkg
	)
)


:CompleteAllTask
@cd %solutionPath%
@if %deleteTempFolder%==1 (
	@RMDIR /s /q "%baseDirectory%"
)

@pause

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
:Trim
@setLocal EnableDelayedExpansion
@set Params=%*
@for /f "tokens=1*" %%a in ("!Params!") do endLocal & set %1=%%b
@exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:IndexOf  strVar  charVar  [rtnVar]
@setlocal enableDelayedExpansion

:: Get the string values
@set indexOf.char=!%~2!
@set str=!%~1!
@set chr=!indexOf.char:~0,1!

@set str2=.!str!
@call :StringLength str len

:: Find the first occurrance of chr in str
@for /l %%N in (0 1 %len%) do if "!str:~%%N,1!" equ "!chr!" (
	@set rtn=%%N
    @goto :breakIndexOf
)

@set rtn=-1
:breakIndexOf
( 
	endlocal
    @if "%~3" neq "" (
		set %~3=%rtn%
	) 
)

@exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:LastIndexOf  strVar  charVar  [rtnVar]
@setlocal enableDelayedExpansion

:: Get the string values
@set lastIndexOf.char=!%~2!
@set str=!%~1!
@set chr=!lastIndexOf.char:~0,1!
@set str2=.!str!

@call :StringLength str2 len
:: Find the last occurrance of chr in str
@for /l %%N in (%len% -1 0) do if "!str:~%%N,1!" equ "!chr!" (
	@set rtn=%%N
    @goto :breakLastIndexOf
)

@set rtn=-1
:breakLastIndexOf
( 
	endlocal
    @if "%~3" neq "" (
		set %~3=%rtn%
	) 
)

@exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:StringLength strVar [rtnVar]
:: Determine the length of str - adapted from function found at:
:: http://www.dostips.com/DtCodeCmdLib.php#Function.strLen
@setlocal enableDelayedExpansion
@set "str=A!%~1!"
@set "len=0"

@for /L %%A in (12,-1,0) do (
	@set /a "len|=1<<%%A"
	@for %%B in (!len!) do (
		@if "!str:~%%B,1!"=="" (
			set /a "len&=~1<<%%A"	
		)
	)
)

(
	endLocal 
	@if "%~2" NEQ "" (
		set /a %~2=%len%
	)
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ReplaceChar strVar charOld charNew [rtnVar]
:: http://stackoverflow.com/questions/13469939/replacing-characters-in-string
@setlocal enableDelayedExpansion
@set "str=!%~1!"
@set "charOld=!%~2!"
@set "charNew=!%~3!"
@set strResult=%str:/=!charNew!%
(
	endLocal 
	@if "%~4" NEQ "" (
		set %~4=%strResult%
	)
)

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:PackageFolder changePath parentPath [rtnVar]
@setlocal enableDelayedExpansion
@set "str=!%~1!"
@set "parentPath=!%~2!"
@call :IndexOf str pathSeparator firstIndexOf
@if !firstIndexOf!==-1 (
	@set packageFolder=""
	@goto :breakPackageFolder
)

@set packageFolder=!str:~0,%firstIndexOf%!
@set /a startIndex=!firstIndexOf!+1
@call :StringLength str changeLength

@if "!packageFolder!" neq "" (
	@set binFolder=%solutionPath%%pathSeparator%!parentPath!%pathSeparator%%packageFolder%%pathSeparator%bin
	@if exist !binFolder! (
		@set packageFolder=%pathSeparator%!packageFolder!
		@goto :breakPackageFolder
	) else (
		@set "currentPath=!parentPath!%pathSeparator%!packageFolder!"			
		@set "subPath=!str:~%startIndex%,%changeLength%!"
		if "!subPath!" neq "" (
			@call :PackageFolder subPath currentPath packageFolder	
			@set packageFolder=!currentPath!!packageFolder!
		)
	)
) else (
	@goto :breakPackageFolder
)

:breakPackageFolder
(
	endLocal 
	@set %~3=%packageFolder%
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CopyPackageFile packageFolder gitChange
@setlocal enableDelayedExpansion
@set "packageFolder=!%~1!"
@set "gitChange=!%~2!"

@call :LastIndexOf gitChange extensionSeparator lastIndexOf
@call :StringLength gitChange gitChangeLength
@set /a startIndex=!lastIndexOf!+1
@set extension=!gitChange:~%startIndex%,%gitChangeLength%!
if "!extension!"=="css" goto :DoCopyFile
if "!extension!"=="scss" goto :DoCopyFile
if "!extension!"=="js" goto :DoCopyFile
if "!extension!"=="config" goto :DoCopyFile
goto :BreakCopyPackageFile

:DoCopyFile
@call :StringLength packageFolder packageFolderLength
@set /a startIndex=!packageFolderLength!+1
@set subFolder=!gitChange:~%packageFolderLength%,%gitChangeLength%!

@call :LastIndexOf packageFolder pathSeparator lastIndexOf
@set /a startIndex=!lastIndexOf!+1
@set packageName=!packageFolder:~%startIndex%,%packageFolderLength%!

@set destinatePackageFolder=%baseDirectory%%pathSeparator%!packageName!
@set contentPath=!destinatePackageFolder!%pathSeparator%%contentDirectory%%pathSeparator%!subFolder!
@call xcopy /y %solutionPath%%pathSeparator%!gitChange! !contentPath!* >NUL

:BreakCopyPackageFile
(
	endlocal
)


exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:InitFolder packageFolder packageIndex packageName packageVersion

@setlocal enableDelayedExpansion
@set "packageFolder=!%~1!"
@set "originIndex=!%~2!"
@call :LastIndexOf packageFolder pathSeparator lastIndexOf
@call :StringLength packageFolder pathLength


@set /a startIndex=!lastIndexOf!+1
@set packageName=!packageFolder:~%startIndex%,%pathLength%!
@call :CreatePackageManifest packageName packageIndex packageName packageVersion

@if "!packageVersion!" neq "" (
	@set destinatePackageFolder=%baseDirectory%%pathSeparator%!packageName!
	@if not exist !destinatePackageFolder! mkdir !destinatePackageFolder!

	@set libPath=!destinatePackageFolder!%pathSeparator%%libDirectory%
	@if not exist !libPath! mkdir !libPath!


	@set binFolder=%solutionPath%!packageFolder!%pathSeparator%bin
	@if exist !binFolder!%pathSeparator%Debug (
		@set binFolder=!binFolder!%pathSeparator%Debug
	)

	@if exist !binFolder!%pathSeparator%!packageName!.dll (
		@set "dllFileName="
		@call :GetDllFileName !binFolder!%pathSeparator%!packageName!.dll dllFileName
		@call xcopy /y !binFolder!%pathSeparator%!packageName!.dll !libPath!%pathSeparator%!dllFileName!.dll* >NUL
		
		@for %%a in %languageList% do (
			@set language=%%a
			@set resourceFile=!binFolder!%pathSeparator%!language!%pathSeparator%!packageName!.resources.dll
			@if exist !resourceFile! (
				@call xcopy /y !resourceFile! !libPath!%pathSeparator%!language!%pathSeparator%!dllFileName!.resources.dll* >NUL
			)
		)	
	)
)

::@set contentPath=!destinatePackageFolder!%pathSeparator%%contentDirectory%
::@if not exist !contentPath! mkdir !contentPath!

(
	endlocal
	@if %originIndex%  neq %packageIndex% (
		@set %~2=%packageIndex%
		@set %~3=%packageName%
		@set %~4=%packageVersion%
	)
)

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CreatePackageManifest packageName packageIndex packageName packageVersion
@setlocal enableDelayedExpansion
@set "packageName=!%~1!"
@set "originIndex=!%~2!"

::Package name for testing
::@set "packageName1=Louis.Test.Package"

@set packageManifestPath=%baseDirectory%%pathSeparator%!packageName!.nuspec
@if not exist !packageManifestPath! (
	@call :GetPackageVersion packageName packageVersion
	@if "!packageVersion!" neq "" (
		@set /a packageIndex=%originIndex%+1
		>> !packageManifestPath! echo(^<?xml version="1.0"?^>
		>> !packageManifestPath! echo(^<package xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>
		>> !packageManifestPath! echo(    ^<metadata xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd"^>
		>> !packageManifestPath! echo(        ^<id^>!packageName!^</id^>
		>> !packageManifestPath! echo(        ^<version^>!packageVersion!^</version^>
		>> !packageManifestPath! echo(        ^<authors^>%nugetAuthor%^</authors^>
		>> !packageManifestPath! echo(        ^<owners^>^</owners^>
		>> !packageManifestPath! echo(        ^<licenseUrl^>https://some-url^</licenseUrl^>
		>> !packageManifestPath! echo(        ^<projectUrl^>https://some-url^</projectUrl^>
		>> !packageManifestPath! echo(        ^<requireLicenseAcceptance^>false^</requireLicenseAcceptance^>    
		>> !packageManifestPath! echo(        ^<summary^>^</summary^>
		>> !packageManifestPath! echo(        ^<description^>%trimmedCommitMessage%^</description^>
		>> !packageManifestPath! echo(        ^<tags^>^</tags^>
		>> !packageManifestPath! echo(        ^<dependencies^>
		>> !packageManifestPath! echo(        ^</dependencies^>
		>> !packageManifestPath! echo(    ^</metadata^>
		>> !packageManifestPath! echo(^</package^>
	)	
)

(
	endlocal
	@if %originIndex%  neq %packageIndex% (
		@set %~2=%packageIndex%
		@set %~3=%packageName%
		@set %~4=%packageVersion%
	)
)

exit /b



:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GetPackageVersion packageName packageVersion
@setlocal enableDelayedExpansion
@set "packageName=!%~1!"
@set tempVersionFile=gitPackage.txt
@call %nugetPath% list -Prerelease PackageId:[!packageName!]>%baseDirectory%%pathSeparator%!tempVersionFile!
@set "packageInfoSeparator= "

@for /f "tokens=*" %%A in (%baseDirectory%%pathSeparator%!tempVersionFile!) do (
	@set versionInfo=%%A
	@call :ProcessPackageVersionInfo versionInfo packageInfoSeparator packageName packageVersion
	@if "!packageVersion!" neq "" (
		goto :CompleteProcessPackageVersionInfo
	)
)

:CompleteProcessPackageVersionInfo
@if "!packageVersion!" neq "" (
	@call :StringLength packageVersion packageVersionLength
	@call :GetVersionSuffix packageVersion packageVersionLength versionSuffix
	@call :IncreasePackageVersion packageVersion versionSuffix packageVersionLength result
)


(
	endlocal
	@if "%~2" NEQ "" (
		set %~2=%result%
	)
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ProcessPackageVersionInfo versionInfo packageInfoSeparator packageName packageVersion
@setlocal enableDelayedExpansion
@set "versionInfo=!%~1!"
@set "packageInfoSeparator=!%~2!"
@set "packageName=!%~3!"

@call :IndexOf versionInfo packageInfoSeparator firstIndexOf	
@set /a startIndex=!firstIndexOf!+1
@call :StringLength versionInfo versionInfoLength
@set foundPackageName=!versionInfo:~0,%firstIndexOf%!

@set "packageVersion="
@if /i "!foundPackageName!"=="!packageName!" (
	@set "packageVersion=!versionInfo:~%startIndex%,%versionInfoLength%!"
)

(
	endlocal
	@if "%~4" NEQ "" (
		set "%~4=%packageVersion%"
	)
)


exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:IncreasePackageVersion packageVersion versionSuffix packageVersionLength 
@setlocal enableDelayedExpansion
@set "packageVersion=!%~1!"
@set "versionSuffix=!%~2!"
@set "packageVersionLength=!%~3!"


@call :StringLength versionSuffix versionSuffixLength
@call :RemoveLeadingZero versionSuffix versionSuffixLength leadingZeroCount formattedVersionSuffix
@call :StringLength formattedVersionSuffix formattedVersionSuffixLength

@if "!formattedVersionSuffix!" equ "" (
	@set /a nextVersion=1
) else (
	@set /a nextVersion=!formattedVersionSuffix!+1
)

@call :StringLength nextVersion nextVersionLength

@if !nextVersionLength! gtr !formattedVersionSuffixLength! (
	@set /a endLeadingIndex=!leadingZeroCount!-2
) else (
	@set /a endLeadingIndex=!leadingZeroCount!-1
)

@set "leadingZero="
@for /L %%A in (0,1,!endLeadingIndex!) do (
	@set "leadingZero=!leadingZero!0"
)

@set /a nextIndex=!packageVersionLength!-!versionSuffixLength!-1
@set /a endIndex=!nextIndex!+1	

@if !versionSuffixLength!==!packageVersionLength! (
	@set result=!nextVersion!%defaultPackageVersionSuffix%
) else (
	@set nextChar=!packageVersion:~%nextIndex%,-%versionSuffixLength%!
	@set prefix=!packageVersion:~0,%endIndex%!
	@if "!nextChar!"=="." (
		@set result=!prefix!!nextVersion!%defaultPackageVersionSuffix%
	) else (
		@set result=!prefix!!leadingZero!!nextVersion!
	)
)	

(
	endlocal
	@if "%~4" NEQ "" (
		set "%~4=%result%"
	)
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:IsNumberChar charValue isValid
@setlocal enableDelayedExpansion
@set result=0
@set "charValue=!%~1!"
@for /l %%a in (0,1,9) do (
	@if "!charValue!"=="%%a"  (
		@set result=1
		@goto :BreakIsNumberChar
	)
)

:BreakIsNumberChar
(
	endlocal
	@if "%~2" NEQ "" (
		set %~2=%result%
	)
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GetVersionSuffix versionPrefix versionPrefixLength versionSuffix
@setlocal enableDelayedExpansion
@set "versionPrefix=!%~1!"
@set "versionPrefixLength=!%~2!"
@set /a nextIndex=!versionPrefixLength!-1
@set result=
@set charValue=!versionPrefix:~%nextIndex%,%versionPrefixLength%!
@set subPrefix=!versionPrefix:~0,%nextIndex%!

@call :IsNumberChar charValue isValid
@if !isValid!==1 (
	@if !nextIndex! gtr 0 (
		@call :GetVersionSuffix subPrefix nextIndex versionSuffix
		@set "result=!versionSuffix!!charValue!"
	)
) 

(
	endlocal
	@if "%~3" NEQ "" (
		set %~3=%result%
	)
)

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CopyLanguageFile packageName language binFolder libPath
@setlocal enableDelayedExpansion
@set "packageName=!%~1!"
@set "language=!%~2!"
@set "binFolder=!%~3!"
@set "libPath=!%~4!"

@set resourceFile=!binFolder!%pathSeparator%!language!%pathSeparator%!packageName!.resources.dll
@if exist !resourceFile! (
	@call xcopy /y !resourceFile! !libPath!%pathSeparator%!language!%pathSeparator%!packageName!.resources.dll* >NUL
)

(
	endlocal
)

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:GetDllFileName filePath dllFileName
@setlocal enableDelayedExpansion
@set "filePath=!%~1!"
@set dllFileName=
@for %%? in (!filePath!) do (
	@set dllFileName=%%~n?
)

(
	endlocal
	@if "%~2" NEQ "" (
		set %~2=%dllFileName%
	)
)

exit /b
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RemoveLeadingZero versionSuffix versionSuffixLength leadingZeroCount formattedVersionSuffix
@setlocal enableDelayedExpansion
@set "versionSuffix=!%~1!"
@set "versionSuffixLength=!%~2!"
@set nextIndex=0


@call :lTrim versionSuffix 0
@call :StringLength versionSuffix newLength

@set leadingZeroCount=0
@set /a leadingZeroCount=!versionSuffixLength!-!newLength!

(
	endlocal
	@if "%~3" NEQ "" (
		set "%~3=%leadingZeroCount%"
	)
	
	@if "%~4" NEQ "" (
		set "%~4=%versionSuffix%"
	)
)

exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:lTrim string char -- strips white spaces (or other characters) from the beginning of a string
::                 -- string [in,out] - string variable to be trimmed
::                 -- char   [in,opt] - character to be trimmed, default is space
:$created 20060101 :$changed 20080227 :$categories StringManipulation
:$source http://www.dostips.com
SETLOCAL ENABLEDELAYEDEXPANSION
call set "string=%%%~1%%"
set "charlist=%~2"
if not defined charlist set "charlist= "
for /f "tokens=* delims=%charlist%" %%a in ("%string%") do set "string=%%a"
( ENDLOCAL & REM RETURN VALUES
    IF "%~1" NEQ "" SET "%~1=%string%"
)
EXIT /b
































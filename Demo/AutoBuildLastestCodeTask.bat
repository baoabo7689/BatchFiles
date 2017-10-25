@set solutionPath="%cd%"

@set msBuildDir="C:\Program Files (x86)\MSBuild\14.0\Bin"
@set visualStudioVersion=14.0

@set nugetPath="%cd%\.nuget\Nuget.exe"

@set PATH=%PATH%;C:\Program Files\Git\bin

@set vbcsCompiler=VBCSCompiler.exe
@set tgitCache=TGitCache.exe

@set isPullCode=0
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
@cd %solutionPath%
@if "%isPullCode%"=="1" (
	@call git pull origin
)
		
@for %%f in (*) do (
	setlocal EnableDelayedExpansion
	@set extenstion="%%~xf"
	
	@if /i !extenstion!==".sln" (
		@REM file extension without case sensitive
		@call %nugetPath% restore "%solutionPath%\%%f"
		@call %msBuildDir%\msbuild  /t:Build "%solutionPath%\%%f" /p:VisualStudioVersion=%visualStudioVersion% /p:Configuration=Release /p:Platform="Any CPU" /l:FileLogger,Microsoft.Build.Engine;logfile=%%f.BuildLog
				
		@tasklist /fi "imagename eq %tgitCache%" /nh |find /i /c "%tgitCache%" > "killedprocess.txt"
		@set /p hasProcess=<"killedprocess.txt"
		@if !hasProcess!==1 taskkill /f /im %tgitCache%
	)
)

@REM Terminate called processes(VBCSCompiler.exe)		
@tasklist /fi "imagename eq %vbcsCompiler%" /nh |find /i /c "%vbcsCompiler%" > "killedprocess.txt"
@set /p hasProcess=<"killedprocess.txt"
@if !hasProcess!==1 taskkill /f /im %vbcsCompiler%

@timeout 2
@REM Terminate called processes(TGitCache.exe), TGitCache keeps apprearing	
@tasklist /fi "imagename eq %tgitCache%" /nh |find /i /c "%tgitCache%" > "killedprocess.txt"
@set /p hasProcess=<"killedprocess.txt"
@if !hasProcess!==1 taskkill /f /im %tgitCache%

@del "killedprocess.txt"	


::@pause
@echo Completed Build Solution
@echo.







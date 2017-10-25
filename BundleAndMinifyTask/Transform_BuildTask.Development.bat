:: Notes
:: 1. Put in same directory of configs or change below value of configFolder
:: 2. Must Install Bundler & Minifier Add On
:: 3. Must Install WebCompiler Add On
:: 4. bundleconfig.json => BundlerMinifier.exe
::	  compilerconfig.json => WebCompiler.exe
:: 5. Commandline version of BundlerMinifier.exe&WebCompiler.exe doesn't recompile for existing file (css, min, js)
:: 6. Must install Git and this will clean source code folder when run


@set currentFolder=%cd%
@set configFolder=%currentFolder%
@set visualStudioExtensions=%UserProfile%\AppData\Local\Microsoft\VisualStudio\14.0\Extensions

@set compilerConfigFile=compilerconfig.json
@set bundleConfigFile=bundleconfig.json

@set "environment=%1"
@set "environment=uat1"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
@setlocal EnableDelayedExpansion
@call :CleanSourceFolder

@if "%environment%" neq "" (
	@call :TransformFiles
)


@call :FindBundlerMinifierApp bundleAndMinifyApp
@call :FindWebCompilerApp webCompilerApp

@cd %configFolder%
@for %%f in (*) do (
	@if /i "%%f"=="%compilerConfigFile%" (
		@echo "Compile %%f"
		@call !webCompilerApp! "%configFolder%\%%f"
	)	
)

@for %%f in (*) do (
	@if /i "%%f"=="%bundleConfigFile%" (
		@echo "Bundle&Minify %%f"
		@call !bundleAndMinifyApp! "%configFolder%\%%f"
	)	
)

@exit /b 0

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CleanSourceFolder 
@git clean -d -x -f
exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:TransformFiles

@set extensionSeparator=.
@set sourceFile=compilerconfig.json

@call :LastIndexOf sourceFile extensionSeparator lastIndexOf
@call :StringLength sourceFile nameLength

@set /a startIndex=!lastIndexOf!+1
@set extension=!sourceFile:~%startIndex%,%nameLength%!
@set fileName=!sourceFile:~0,%lastIndexOf%!
@set targetFile=!fileName!.!environment!.!extension!

@call xcopy /y ..\!targetFile! !sourceFile! >NUL

exit /b

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FindWebCompilerApp webCompilerApp

@for /d %%d in (%visualStudioExtensions%\*) do (	
	@set folder=%%d\
	@set bundleApp=!folder!WebCompiler.exe
	@for %%f in (!folder!*) do (
		@if /i "%%f"=="!bundleApp!" (
			@set webCompilerApp=%%f
			@goto :breakFindWebCompilerApp
		)	
	)	
)

:breakFindWebCompilerApp

(
	endLocal 
	@if "%~1" NEQ "" (
		set %~1=%webCompilerApp%
	)
)


exit /b


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:FindBundlerMinifierApp bundleAndMinifyApp

@for /d %%d in (%visualStudioExtensions%\*) do (	
	@set folder=%%d\
	@set bundleApp=!folder!BundlerMinifier.exe
	@for %%f in (!folder!*) do (
		@if /i "%%f"=="!bundleApp!" (
			@set bundleAndMinifyApp=%%f
			@goto :breakFindBundlerMinifierApp
		)	
	)	
)

:breakFindBundlerMinifierApp

(
	endLocal 
	@if "%~1" NEQ "" (
		set %~1=%bundleAndMinifyApp%
	)
)


exit /b

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





















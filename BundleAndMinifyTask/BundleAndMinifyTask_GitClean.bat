:: Notes
:: 1. Put in same directory of configs or change below value of configFolder
:: 2. Must Install Bundler & Minifier Add On
:: 3. Must Install WebCompiler Add On
:: 4. bundleconfig.json => BundlerMinifier.exe
::	  compilerconfig.json => WebCompiler.exe
:: 5. Commandline version of BundlerMinifier.exe&WebCompiler.exe doesn't recompile for existing file (css, min, js)
:: 6. Must install Git


@set currentFolder=%cd%
@set configFolder=%currentFolder%\assets
@set visualStudioExtensions=%UserProfile%\AppData\Local\Microsoft\VisualStudio\14.0\Extensions

@set compilerConfigFile=compilerconfig.json
@set bundleConfigFile=bundleconfig.json

@set PATH=%PATH%;C:\Program Files (x86)\Git\bin
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
@setlocal EnableDelayedExpansion
@call :CleanSourceFolder
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


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CleanSourceFolder 
@git clean -d -x -f
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






















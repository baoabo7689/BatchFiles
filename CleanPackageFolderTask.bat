:: Notes


@set "currentFolder=%cd%\Sunplus.Shared.ViewLogLib"
@set packageName=
@set directorytSeparator=\

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
@setlocal EnableDelayedExpansion


@call :LastIndexOf currentFolder directorytSeparator lastIndexOf
@call :StringLength currentFolder length
@set /a startIndex=lastIndexOf+1
@set "strTemp=!currentFolder:~%startIndex%,%length%!"
@if "%packageName%"=="" (
	@set "packageName=!strTemp!"
)

@call :CleanFolder %currentFolder%
@pause


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
:CleanFolder folderPath
@set "folderPath=!%~1!"

@cd !folderPath!

@for %%f in (*) do (
	@if /i "%%f" neq "!packageName!.dll" (
		@if /i "%%f" neq "!packageName!.resources.dll" (
			@del %%f
		)
	)
)

@for /d %%d in (*) do (
	@if "%%d" neq "" (
		@set "subFolder=%folderPath%\%%d"
		@call :CleanFolder subFolder
	)
)

exit /b






























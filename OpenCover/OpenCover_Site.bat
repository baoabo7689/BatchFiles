@set currentFolder=%cd%
@set solutionFolder=%currentFolder%\alpha-newmain\Alpha.Main.Site
@set openCover=%solutionFolder%\packages\OpenCover.4.6.519\tools\OpenCover.Console.exe
@set testRunner=%solutionFolder%\packages\NUnit.Runners.2.6.3\tools\nunit-console.exe
@set reportGenerator=%solutionFolder%\packages\ReportGenerator.2.4.4.0\tools\ReportGenerator.exe


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
@setlocal EnableDelayedExpansion

@set systemUnderTest=Alpha.Main.Site
@set testProject=!systemUnderTest!.Tests
@set codeCoverageResult=_CodeCoverageResult.xml
@set coverageReport=_CodeCoverageReport


"%openCover%" -target:"%testRunner%" -targetargs:"/nologo %solutionFolder%\Tests\!testProject!\bin\Debug\!testProject!.dll /noshadow" -filter:"+[!systemUnderTest!]!systemUnderTest!*" -excludebyattribute:"System.CodeDom.Compiler.GeneratedCodeAttribute" -register:user -output:"!codeCoverageResult!"

"%reportGenerator%" "-reports:!codeCoverageResult!" "-targetdir:!coverageReport!"

@start "report" %currentFolder%\!coverageReport!\index.htm

@del TestResult.xml
@del !codeCoverageResult!

@pause
@endlocal
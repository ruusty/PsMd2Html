@echo off
@rem ----------------------------------------------------------------------
@rem Run and log pester tests wrapper
@rem
@rem ----------------------------------------------------------------------
@echo off
@setlocal
@cd /d %~dp0
@set xname1=%~n0
@set TestName=%xname1:~13%
call :SetISOdatetime

@set l_testName=%TestName%

@set l_OutputDir=%~dp0

@set l_log_file=%l_OutputDir%%nameStr%.%iso_datetime%.log
@set l_OutputXmlFile= "%~dp0%l_testName%.xml"
@set l_OutputHtmlFile="%~dp0%l_testName%.html"

@echo ==============================================================================={

@echo.l_testName         %l_testName%
@echo.l_OutputDir        %l_OutputDir%
@echo.l_log_file         %l_log_file%
@echo.l_OutputXmlFile    %l_OutputXmlFile%
@echo.l_OutputHtmlFile   %l_OutputHtmlFile%

@echo on

@echo.MSG1000[%~nx0]^>

call Pester.bat -OutputFile %l_OutputXmlFile% -OutputFormat NUnitXml ./md2html.Module.Tests.ps1
set rv=%ERRORLEVEL%
@echo.ERRORLEVEL %ERRORLEVEL%

@NUnitHTMLReportGenerator.exe %l_OutputXmlFile%
@echo ===============================================================================}

@goto :end

:unsuccessfulEnd
@echo.ERR1005^>FAILURE
exit /b 1
@endlocal
@goto :EOF


:end
exit /b %rv%

@goto :EOF


@rem
@rem The following labels to the end of the file are used by the call command
@rem

@goto :EOF
@rem Define timestamp variables
:SetISOdatetime
@Set mm=%date:~4,2%
@Set dd=%date:~7,2%
@Set yyyy=%date:~10,4%

@set hh24=%time:~0,2%
@rem fix leading space in hours
@set hh24=%hh24: =0%
@set min=%time:~3,2%
@set sec=%time:~6,2%

@set iso_date=%yyyy%-%dd%-%mm%
@set iso_time=%hh24%-%min%-%sec%
@set iso_datetime=%iso_date%T%iso_time%

@rem clean up
@Set mm=
@Set dd=
@Set yyyy=
@set hh24=
@set min=
@set sec=
@rem set ERRORLEVEL to success
@ver >nul 2>&1

@set nameStr=%~n0
@set fullPathStr=%~f0
@set fname=%~nx0
@set base_fname=%~dp0

@goto :EOF

rem  end of file


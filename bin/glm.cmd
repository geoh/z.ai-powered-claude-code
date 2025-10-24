@echo off
rem GLM shim - calls the z.cmd wrapper script
rem This provides an alternative naming convention representing the GLM model family

rem Get the directory where this script is located
set SCRIPT_DIR=%~dp0

rem Call the z.cmd script with all arguments
call "%SCRIPT_DIR%z.cmd" %*


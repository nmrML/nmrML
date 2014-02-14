@echo off
SET mypath=%~dp0
SET JAVA=java -Xmx512m
SET CONVERTER=%JAVA% -cp %mypath% -jar "%mypath%/converter.jar"

IF "%1"=="" GOTO Help
SET OUTPUTARG=

IF "%2"=="" GOTO Continue
SET OUTPUTARG=-o %2
echo %OUTPUTARG%

:Continue
%CONVERTER% -i %1 %OUTPUTARG%
EXIT /B
 
:Help
%CONVERTER% -h

@echo off
SET mypath=%~dp0
SET JAVA=java -Xmx512m
SET CONVERTER=%JAVA% -jar "%mypath%/nmrml_converter.jar"

IF "%1"=="" GOTO Help
SET OUTPUTARG=

IF "%2"=="" GOTO Continue
SET OUTPUTARG=-o %2

:Continue
%CONVERTER% -i %1 %OUTPUTARG%
EXIT /B
 
:Help
%CONVERTER% -h

@echo off
SET mypath=%~dp0
SET JAVA=java -Xmx512m
SET CONVERTER=%JAVA% -cp %mypath% -jar "%mypath%/converter.jar"

%CONVERTER% -l proc %*

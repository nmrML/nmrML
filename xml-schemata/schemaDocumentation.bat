@echo off

echo Script file for generating XML Schema documentation
echo using oXygen XML Editor schema documentation generator.

SET BASE_DIR=%~dp0

SET CP="%BASE_DIR%;%BASE_DIR%/classes;%BASE_DIR%/lib;%BASE_DIR%/lib/oxygen.jar;%BASE_DIR%/lib/oxygenDeveloper.jar;%BASE_DIR%/lib/fop.jar;%BASE_DIR%/lib/xmlgraphics-commons-1.5.jar;%BASE_DIR%/lib/batik-all-1.7.jar;%BASE_DIR%/lib/saxon.jar;%BASE_DIR%/lib/saxon9ee.jar;%BASE_DIR%/lib/xercesImpl.jar;%BASE_DIR%/lib/xml-apis.jar;%BASE_DIR%/lib/org.eclipse.wst.xml.xpath2.processor_1.2.0.jar;%BASE_DIR%/lib/icu4j.jar;%BASE_DIR%/lib/resolver.jar;%BASE_DIR%/lib/oxygen-emf.jar;%BASE_DIR%/lib/log4j.jar;%BASE_DIR%/lib/commons-httpclient-3.1.jar;%BASE_DIR%/lib/commons-codec-1.3.jar;%BASE_DIR%/lib/commons-logging-1.0.4.jar;%BASE_DIR%/lib/httpcore-4.2.1.jar;%BASE_DIR%/lib/httpclient-cache-4.2.1.jar;%BASE_DIR%/lib/httpclient-4.2.1.jar;%BASE_DIR%/lib/fluent-hc-4.2.1.jar;%BASE_DIR%/lib/httpmime-4.2.1.jar;%BASE_DIR%/lib/commons-logging-1.1.1.jar;%BASE_DIR%/lib/commons-codec-1.6.jar"

SET OXYGEN_JAVA=java.exe

if exist "%~dp0\jre\bin\java.exe" SET OXYGEN_JAVA="%~dp0\jre\bin\java.exe"

%OXYGEN_JAVA% -cp %CP% -Djava.awt.headless=true ro.sync.xsd.documentation.XSDSchemaDocumentationGenerator %*
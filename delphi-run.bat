:: https://github.com/guimaraes-lucas/delphi-run

:: Just execute '.\delphi-run' to compile and execute the delphi project

REM Find the compiler
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
REM Find project
FOR /F "delims=" %%i IN ('dir /b "*.dproj"') DO set projeto=%%i
REM Compile project
msbuild %projeto% /p:Config=Debug /t:Build
@echo off
REM Extract project name
set nome_projeto=%projeto:.dproj=%
REM Find executable
FOR /F "delims=" %%i IN ('dir /s /b "%nome_projeto%.exe"') DO set executavel=%%i
REM Execute
%executavel%
@echo on
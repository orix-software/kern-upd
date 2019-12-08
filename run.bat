@echo off

SET ORICUTRON="..\..\..\oricutron-iss\"

SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

For /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)


SET MYDATE=%mydate% %mytime%

echo %MYDATE%


%CC65%\cl65 -ttelestrat src\kern-upd.c src\eeprom.s src\loadfile.s  -o kernupd

IF "%1"=="NORUN" GOTO End
mkdir %ORICUTRON%\usbdrive\usr\share\kernupd

copy kernupd %ORICUTRON%\sdcard\bin\a > NUL

cd %ORICUTRON%
oricutron -mt 


:End
cd %ORIGIN_PATH%
rem %OSDK%\bin\MemMap "%ORIGIN_PATH%\src\xa_labels.txt" docs/memmap.html Telemon docs/telemon.css

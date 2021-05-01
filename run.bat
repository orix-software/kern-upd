@echo off

SET ORICUTRON="D:\users\plifp\Onedrive\oric\oricutron_twilighte"


SET RELEASE="30"
SET UNITTEST="NO"

SET ORIGIN_PATH=%CD%

For /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set mytime=%%a:%%b)


SET MYDATE=%mydate% %mytime%

echo %MYDATE%


%CC65%\cl65 -I libs/usr/include/ -ttelestrat  src/orixcfg.c src/eeprom.s -o orixcfg libs/lib8/ch376.lib libs/lib8/twil.lib


IF "%1"=="NORUN" GOTO End
mkdir %ORICUTRON%\usbdrive\usr\share\orixcfg

copy orixcfg %ORICUTRON%\sdcard\bin\orixcfg > NUL
copy src/etc/orixcfg/carts.cfg %ORICUTRON%\sdcard\etc\orixcfg\ > NUL



cd %ORICUTRON%
oricutron


:End
cd %ORIGIN_PATH%
rem %OSDK%\bin\MemMap "%ORIGIN_PATH%\src\xa_labels.txt" docs/memmap.html Telemon docs/telemon.css

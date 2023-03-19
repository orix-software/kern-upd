# export DISPLAY=172.17.160.1:0
ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"
cl65 -I libs/usr/include/ -ttelestrat --start-addr 0x800 src/orixcfg.c src/common/_println.s src/common/_xcrlf.s src/common/_xexec.s src/common/_print.s src/eeprom.s src/39SF040/_program_bank_38SF040.s src/39SF040/_erase_sector_39SF040.s src/39SF040/_sequence_39sf040.s src/39SF040/select_bank_39sf040.s src/39SF040/write_byte_39SF040.s -o orixcfg libs/lib8/ch376.lib libs/lib8/twil.lib libs/lib8/pbar.lib
#make clean && make orixcfg
cp orixcfg $ORICUTRON_PATH/sdcard/bin/

cd $ORICUTRON_PATH
./oricutron
cd -


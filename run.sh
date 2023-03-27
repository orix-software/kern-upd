# export DISPLAY=172.17.160.1:0
ORICUTRON_PATH="/mnt/c/Users/plifp/OneDrive/oric/oricutron_wsl/oricutron"
cl65 -I libs/usr/include/ -ttelestrat --start-addr 0x800  src/common/_XWRSTR0_internal.s src/common/_read_eeprom_manufacturer.s src/common/restore_twil_registers.s src/common/save_twil_registers.s src/common/progress_bar/progress_bar_run.s src/orixcfg.c src/common/_println.s src/common/_xcrlf.s src/common/scrollup.s src/common/_XCRLF_internal.s src/common/progress_bar/progress_bar_init.s src/common/progress_bar/progress_bar_display_100_percent.s src/common/progress_bar/inc_progress_bar.s src/common/_cputc_custom.s src/common/_cputhex16_custom.s src/common/_xexec.s src/common/_print.s src/29F040/_program_sector_29F040.s src/29F040/sequence_29F040.s src/29F040/select_bank.s src/29F040/_erase_sector_29F040.s src/common/progress_bar/vars.s src/29F040/write_byte_29F040.s src/39SF040/_program_bank_39SF040.s src/39SF040/_erase_sector_39SF040.s src/39SF040/_sequence_39sf040.s src/common/vars.s src/39SF040/select_bank_39sf040.s src/39SF040/erase_39SF040_bank.s src/39SF040/write_byte_39SF040.s src/39SF040/_program_kernel_39SF040.s -o orixcfg libs/lib8/ch376.lib libs/lib8/twil.lib libs/lib8/pbar.lib 
#make clean && make orixcfg
cp orixcfg $ORICUTRON_PATH/sdcard/bin/

cd $ORICUTRON_PATH
#./oricutron
cd -


LDFILES=src/eeprom.s src/39SF040/_program_bank_38SF040.s src/39SF040/_erase_sector_39SF040.s src/39SF040/_sequence_39sf040.s src/39SF040/select_bank_39sf040.s src/39SF040/write_byte_39SF040.s


cl65 -I libs/usr/include/ -ttelestrat src/orixcfg.c src/eeprom.s src/39SF040/_program_bank_38SF040.s src/39SF040/_erase_sector_39SF040.s src/39SF040/_sequence_39sf040.s src/39SF040/select_bank_39sf040.s src/39SF040/write_byte_39SF040.s
 -o orixcfg libs/lib8/ch376.lib libs/lib8/twil.lib libs/lib8/pbar.lib
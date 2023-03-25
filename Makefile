AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=orixcfg
LDFILES=src/common/_println.s src/common/progress_bar/progress_bar_run.s src/common/_xcrlf.s src/29F040/sequence_29F040.s src/39SF040/erase_39SF040_bank.s src/common/_print.s src/common/_read_eeprom_manufacturer.s src/common/scrollup.s src/common/save_twil_registers.s src/common/restore_twil_registers.s src/common/progress_bar/progress_bar_init.s src/common/_XCRLF_internal.s src/29F040/_program_sector_29F040.s src/common/progress_bar/progress_bar_display_100_percent.s src/29F040/_erase_sector_29F040.s src/common/_cputc_custom.s src/common/_cputhex16_custom.s src/common/progress_bar/vars.s src/common/progress_bar/inc_progress_bar.s src/29F040/write_byte_29F040.s src/29F040/select_bank.s src/39SF040/_program_bank_39SF040.s src/39SF040/_erase_sector_39SF040.s src/common/vars.s src/39SF040/_sequence_39sf040.s src/39SF040/select_bank_39sf040.s src/39SF040/write_byte_39SF040.s src/39SF040/_program_kernel_39SF040.s

ifeq ($(CC65_HOME),)
        CC = cl65
        AS = ca65
        LD = ld65
        AR = ar65
else
        CC = $(CC65_HOME)/bin/cl65
        AS = $(CC65_HOME)/bin/ca65
        LD = $(CC65_HOME)/bin/ld65
        AR = $(CC65_HOME)/bin/ar65
endif

all : init orixcfg srccode
.PHONY : all

SOURCE=src/$(PROGRAM).c

init: $(SOURCE)
	./configure

orixcfg: $(SOURCE)
	echo build orixcfg2
	$(CC) -I libs/usr/include/ $(CFLAGS)  $(SOURCE) $(LDFILES) -o $(PROGRAM) -l pouet.s --start-addr 0x800 libs/lib8/ch376.lib libs/lib8/twil.lib libs/lib8/pbar.lib
	#relocation
	#rm src/eeprom.o
	$(CC) -I libs/usr/include/ $(CFLAGS) $(SOURCE) $(LDFILES)  -o 1000 --start-addr 2048 libs/lib8/ch376.lib libs/lib8/twil.lib libs/lib8/pbar.lib
	$(CC) -I libs/usr/include/ $(CFLAGS) $(SOURCE) $(LDFILES) -o 1256 --start-addr 2304 libs/lib8/ch376.lib libs/lib8/twil.lib libs/lib8/pbar.lib
	# Reloc
	chmod +x dependencies/orix-sdk/bin/relocbin.py3
	dependencies/orix-sdk/bin/relocbin.py3 -o romupd -2 1000 1256

srccode: $(SOURCE)
	mkdir -p build/usr/src/$(PROGRAM)/
	mkdir -p build/usr/src/$(PROGRAM)/src/
	mkdir -p build/bin
	cp $(PROGRAM)  build/bin/
	cp romupd  build/bin/
	cp README.md build/usr/src/$(PROGRAM)/
	cp -adpR src/* build/usr/src/$(PROGRAM)/src/
	sh docs/builddocs.sh

clean:
	rm -f $(PROGRAM)

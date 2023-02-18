AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=orixcfg
LDFILES=src/eeprom.s src/39SF040/_program_sector_38SF040.s src/39SF040/_erase_sector_39SF040.s  src/39SF040/_sequence_39sf040.s

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

all : init code srccode
.PHONY : all

SOURCE=src/$(PROGRAM).c

init: $(SOURCE)
	./configure

code: $(SOURCE)
	$(CC) -I libs/usr/include/ $(CFLAGS)  $(SOURCE) $(LDFILES) -o $(PROGRAM) libs/lib8/ch376.lib libs/lib8/twil.lib
	#relocation
	#rm src/eeprom.o
	$(CC) -I libs/usr/include/ $(CFLAGS) $(SOURCE) $(LDFILES)  -o 1000 --start-addr 2048 libs/lib8/ch376.lib libs/lib8/twil.lib
	$(CC) -I libs/usr/include/ $(CFLAGS) $(SOURCE) $(LDFILES) -o 1256 --start-addr 2304 libs/lib8/ch376.lib libs/lib8/twil.lib
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



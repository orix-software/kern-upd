AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=orixcfg
LDFILES=src/eeprom.s

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

all : code srccode
.PHONY : all


SOURCE=src/$(PROGRAM).c


code: $(SOURCE)
	./configure
	$(CC) -I libs/usr/include/ $(CFLAGS)  $(SOURCE) $(LDFILES) -o $(PROGRAM) libs/lib8/ch376.lib libs/lib8/twil.lib


srccode: $(SOURCE)
	mkdir -p build/usr/src/$(PROGRAM)/
	mkdir -p build/usr/src/$(PROGRAM)/src/
	mkdir  build/bin
	cp  $(PROGRAM)  build/bin
	#cp configure build/usr/src/$(PROGRAM)/
	#cp Makefile build/usr/src/$(PROGRAM)/
	cp README.md build/usr/src/$(PROGRAM)/
	cp -adpR src/* build/usr/src/$(PROGRAM)/src/



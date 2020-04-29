AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=orixcfg
LDFILES=src/eeprom.s src/_display_signature_bank.s src\loadfile.s 


ifdef $(TRAVIS_BRANCH)
ifeq ($(TRAVIS_BRANCH), master)
RELEASE:=$(shell cat VERSION)
else
RELEASE=alpha
endif
endif


all : srccode code
.PHONY : all

HOMEDIR=/home/travis/bin/

SOURCE=src/$(PROGRAM).c

MYDATE = $(shell date +"%Y-%m-%d %H:%m")
  
code: $(SOURCE)
	$(CC) $(CFLAGS)  $(SOURCE) $(LDFILES)

srccode: $(SOURCE)
	mkdir -p build/usr/src/$(PROGRAM)/
	mkdir -p build/usr/src/$(PROGRAM)/src/
	cp configure build/usr/src/$(PROGRAM)/
	cp Makefile build/usr/src/$(PROGRAM)/
	cp README.md build/usr/src/$(PROGRAM)/	
	cp -adpR src/* build/usr/src/$(PROGRAM)/src/

test:
	mkdir -p build/usr/share/$(PROGRAM)/
	mkdir -p build/usr/share/ipkg/
	mkdir -p build/usr/share/man/  
	mkdir -p build/usr/share/doc/$(PROGRAM)/
	mkdir -p build/bin/$(PROGRAM)/
	cp $(PROGRAM) build/bin/$(PROGRAM)/
	cd build && tar -c * > ../$(PROGRAM).tar &&	cd ..
	filepack  $(PROGRAM.tar $(PROGRAM).pkg
	gzip $(PROGRAM).tar
	mv $(PROGRAM).tar.gz $(PROGRAM).tgz
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM).tgz ${hash} 6502 tgz $(RELEASE)

  
  

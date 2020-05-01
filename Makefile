AS=xa
CC=cl65
CFLAGS=-ttelestrat
LDFILES=
PROGRAM=orixcfg
LDFILES=src/eeprom.s


all : srccode code
.PHONY : all

HOMEDIR=/home/travis/bin/

SOURCE=src/$(PROGRAM).c



ifeq ($(TRAVIS_BRANCH), master)
RELEASE:=$(shell cat VERSION)
$(shell cat VERSION)
$(shell ls)
else
RELEASE:=alpha
endif




MYDATE = $(shell date +"%Y-%m-%d %H:%m")
  
code: $(SOURCE)
	$(CC) $(CFLAGS)  $(SOURCE) $(LDFILES) -o $(PROGRAM)
  

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
	filepack  $(PROGRAM).tar $(PROGRAM).pkg
	gzip $(PROGRAM).tar
	mv $(PROGRAM).tar.gz $(PROGRAM).tgz
	echo Branch $(TRAVIS_BRANCH) Release   $(RELEASE)
	cat VERSION
	php buildTestAndRelease/publish/publish2repo.php $(PROGRAM).tgz ${hash} 6502 tgz $(RELEASE)

  
  

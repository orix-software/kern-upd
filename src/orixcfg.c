#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <telestrat.h>

#include "twil.h"

extern unsigned char program_sector(unsigned char *file, unsigned char sector, unsigned char counterdisplay);

extern unsigned char program_bank_ram(unsigned char *file, unsigned char idbank, unsigned char bank64id);

extern unsigned int read_eeprom_manufacturer(unsigned char sector);

extern unsigned char * display_signature_bank(unsigned char sector,unsigned char bank);


#define MAX_SLOT 4
#define MAX_LENGTH_OF_PATH 50

unsigned char current_set=0;

FILE *fp;

void usage() {
  printf("usage:\n");
  printf("orixcfg -i : displays info\n");
  printf("orixcfg -v : displays version\n");
  printf("orixcfg -h : displays help\n");
  printf("orixcfg -r -s X romfile64KB.r64 : Load romfile into set X\n");
  printf("orixcfg -w -s X -b Y romfile16KB : Load romfile in bank Y into set X in RAM slot\n");
  printf("orixcfg -w -s X -b Y -c : Clear RAM in set X and bank Y\n");
  //printf("orixcfg -w -s X -b Y -t : Display RAM signature in set X and bank Y\n");
  return;
}

void version() {
	printf("v2021.2\n");
}

void getEEPROMId() {
	unsigned char manufacturer_code;
	unsigned char device_code;
	static unsigned int status;
	
	status=read_eeprom_manufacturer(0);
	device_code=status>>8;
	manufacturer_code=status&0xFF;
	printf("Manufacturer : ");
	switch (manufacturer_code) {
		case 1: printf("(AMD)\n"); break;
		case 31:printf("(Atmel)\n"); break;
		case 32:printf("(ST Microelectronics)\n"); break;
		default:printf("(unknown)\n");
	}
			
	printf("Device Id: %x ",device_code);
	switch (device_code) {
		case 0x20: printf("(29F010)\n"); break;
		case 0xA4:
		case 0xE2: printf("(29F040)\n"); break;
		default: printf("(unknown)\n"); break;
	}
}


int main(int argc,char *argv[]) {
	unsigned char i=0;
	unsigned char ret=0;
	unsigned char mykey=0;


  	if (argc==1) {
   		usage();
	    return 0;
	}

	if (argc==2 && strcmp(argv[1],"-v")==0)  {
    	version();
    	return 0;
   	}
 
  	if (argc==2 && strcmp(argv[1],"-h")==0)  {
    	usage();
    	return 0;
  	} 
 
  	if (argc==2 && strcmp(argv[1],"-i")==0)  {
    	getEEPROMId();
    	return 0;
  	} 
  
  /*
	if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-s")==0 && strcmp(argv[4],"-b")==0 && strcmp(argv[6],"-t")==0 ) {
		printf("%s",twil_display_signature_bank(TWIL_BANK_TYPE_RAM, atoi(argv[3]),  atoi(argv[5]) ) );
    	return 0;
	} 
*/
	if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-s")==0 && strcmp(argv[4],"-b")==0 && strcmp(argv[6],"-c")==0 ) {
		twil_clear_rambank(atoi(argv[5]), atoi(argv[3]));
	    return 0;
	} 

	if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-s")==0 && strcmp(argv[4],"-b")==0 )  {
		printf("Loading : %s into set %s, bank %s in ram\n",argv[6],argv[3],argv[5]);
		ret=twil_program_rambank(atoi(argv[5]), argv[6], atoi(argv[3]));
		if (ret==1) printf("File not found");
    	return 0;
	} 

	if (strcmp(argv[1],"-r")==0 && strcmp(argv[2],"-s")==0)  {
		if (strcmp(argv[4],"")==0) {
			printf("Missing file set of 64KB\n");
		}
	  
		if (atoi(argv[3])==4) {
			printf("You have selected kernel set, if you press 'y', it will update the kernel with %s\n",argv[4]);
			printf("Would you like to continue y/N (Oric will reboot)?\n");
			mykey=cgetc();
			if (mykey!='y') return 0;
		}

	printf("Loading : %s into set %s of rom\n",argv[4],argv[3]);
	printf("Please wait ... \n");
	ret=program_sector(argv[4],atoi(argv[3]),1);
    if (ret==1) printf("File not found : %s\n",argv[4]);
    
    return 0;
  	} 

				
}
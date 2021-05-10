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
  //printf("orixcfg -w -s X -b Y romfile16KB : Load romfile in bank Y into set X in RAM slot\n");
  printf("orixcfg -w -s X -b Y -c : Clear RAM in set X and bank Y\n");
  printf("orixcfg -w -f : Clear all rams\n");
  //printf("orixcfg -w -s X -b Y romfiles : Load 16kbfile into bank X\n");
  //printf("orixcfg -k [file] : Update kernel with file\n");
  printf("orixcfg -b XX -l file : Load file into XX bank\n");

  return;
}

void version() {
	printf("v2021.3\n");
}

void check_format_kernel_set() {

	// # orixcfg -k myfile
	// .byte "KERNELSET"
	// .res 20 header (in the future)
}

void check_format_rom_bank() {
	// # orixcfg -l monitor.ROR -b 15
	// .byte "ROMORIX" or "ROMSTAND"
	// for ROMORIX :
	//  .res 2 ; kernel min version
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

unsigned char str_bank[5];

int main(int argc,char *argv[]) {
	static unsigned char i=0;
	static unsigned char j=0;
	unsigned char ret=0;
	unsigned char mykey=0;
	unsigned char bank;
	unsigned char physical_bank;
	unsigned int register_bank;
	unsigned char twil_register;
	FILE *fp;


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

	if (strcmp(argv[1],"-k")==0) {
		if (argv[2]=="") {
			printf("Missing rol file");
			return 0;
		}
		fp=fopen(argv[2],"r");
		if (fp==NULL)  {
			printf("Can't open %s",argv[2]);
			return 0;
		}
		fclose(fp);
/*

		printf("You have selected kernel set, if you press 'y', it will update the kernel with %s\n",argv[4]);
		printf("Would you like to continue y/N (Oric will reboot)?\n");
		mykey=cgetc();
		if (mykey!='y') return 0;
		printf("Updating kernel ... );
		printf("Please wait ... \n");
		ret=program_sector(argv[4],atoi(argv[3]),1);
    	if (ret==1) printf("File not found : %s\n",argv[4]);
*/
 
	}


	if (strcmp(argv[3],"-l")==0 && strcmp(argv[1],"-b")==0 ) {
		if (argv[2]=="") {
			printf("Missing bank id");
			return 0;
		}

		if (argv[4]=="") {
			printf("Missing file to load");
			return 0;
		}

		bank=atoi(argv[2]);
		if (bank>64) {
			printf("There is only 64 banks\n");
			return 1;
		}
		if (bank>32) {
			fp=fopen(argv[4],"r");
			if (fp==NULL)  {
				printf("Can't open %s\n",argv[4]);
				return 0;
			}
			fclose(fp);

			register_bank=twil_get_registers_from_id_bank(bank);
			twil_register=register_bank>>8;
			physical_bank=register_bank&0xFF;
			printf("Loading : %s into bank %d\n",argv[4],bank);
			//twil_program_rambank(unsigned char bank, char *file, unsigned char set); 
			ret=twil_program_rambank(physical_bank, argv[4], twil_register);
			if (ret==1) printf("File not found %s\n",argv[4]);
    		return 0;
		}
		else {
			printf("Impossible to program rom bank with this switch, use '-r -s X romfile64KB.r64' flags for EEPROM management %s %s\n",argv[3],argv[1]);
		}
	}

	// Flush all
	if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-f")==0) {
		//twil_clear_rambank(unsigned char bank, unsigned char set);
		for (j=0;j<8;j++)
			for (i=1;i<5;i++) {
				bank=twil_get_id_bank(i,j);
				
				sprintf(str_bank, "Empty RAM %d", bank);
				printf("Flush RAM bank %d\n",bank);
				
				twil_set_bank_signature(str_bank);
				
				twil_clear_rambank(i, j);
			}
	    return 0;
	} 

	if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-s")==0 && strcmp(argv[4],"-b")==0 && strcmp(argv[6],"-c")==0 ) {
		twil_clear_rambank(atoi(argv[5]), atoi(argv[3]));
	    return 0;
	} 

	if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-s")==0 && strcmp(argv[4],"-b")==0 )  {
		printf("Loading : %s into set %s, bank %s in ram\n",argv[6],argv[3],argv[5]);
		ret=twil_program_rambank(atoi(argv[5]), argv[6], atoi(argv[3]));
		if (ret==1) printf("File not found\n");
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
	if (atoi(argv[3])==4)  {
		clrscr();
		cputsxy(0,0,"Updating kernel ...");
	}
	else {
		printf("Loading : %s into set %s of rom\n",argv[4],argv[3]);
		printf("Please wait ... \n");
	}
	ret=program_sector(argv[4],atoi(argv[3]),1);
    if (ret==1) printf("File not found : %s\n",argv[4]);
    
    return 0;
  	}
    printf("Wrong parameters\n"); 

				
}
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <telestrat.h>

#include <errno.h>
#include <unistd.h>
//#include "_file.h"

#include "twil.h"

#define VERSION "v2023.X"

#define EEPROM_29F040  0x01
#define EEPROM_39SF040 0x02

extern unsigned char program_sector_29F040(unsigned char *file, unsigned char sector, unsigned char counterdisplay);
extern unsigned char program_bank_39SF040(unsigned char *file, unsigned char sector);
extern unsigned char program_kernel_39SF040(unsigned char *file);
extern unsigned char program_bank_ram(unsigned char *file, unsigned char idbank, unsigned char bank64id);
extern unsigned int read_eeprom_manufacturer();
extern unsigned char * display_signature_bank(unsigned char sector,unsigned char bank);


extern void xexec(char *str);
extern void crlf();
extern void print(char *string);
extern void println(char *string);

#define MAX_SLOT 4
#define MAX_LENGTH_OF_PATH 50

unsigned char current_set=0;

FILE *fp;

void usage() {
  println("usage:");
  println("orixcfg -i : displays info");
  println("orixcfg -v : displays version");
  println("orixcfg -h : displays help");
  println("orixcfg -r -s X romfile64KB.r64 : Load romfile into set X");
  println("orixcfg -w -s X -b Y -c : Clear RAM in set X and bank Y");
  println("orixcfg -w -f : Clear all rams");
  println("orixcfg -b XX -l file : Load file into XX bank");

  return;
}

void version() {
    printf(VERSION);
	printf("\n");
}

unsigned char checkEeprom() {
	/* Returns 0 if device is not supported*/
	/* Return 1 if it's 29F040*/
	/* Return 2 if it's 39SF040*/
    unsigned char manufacturer_code;
    unsigned char device_code;
    static unsigned int status;
	unsigned char supported_device = 0;

    status = read_eeprom_manufacturer();
    device_code=status>>8;
    manufacturer_code=status&0xFF;
    switch (manufacturer_code) {
        case 1:
			// Amd
            supported_device = 1;
            break;
        case 31:
            // Atmel
            break;
        case 32:
            // ST Microelectronics
			supported_device = 2;
            break;
        case 0xBF:
            // Microchip
            break;
    }

    switch (device_code) {
        case 0xA4:
			// 29F040
            supported_device = EEPROM_29F040;
            break;
        case 0xB7:
			// 39SF040
            supported_device = EEPROM_39SF040;
            break;
        default:
            supported_device = 0;
            break;
    }

    return supported_device;
}

unsigned char getEEPROMId() {
	/* Returns 0 if device is not supported*/
    unsigned char manufacturer_code;
    unsigned char device_code;
    static unsigned int status;
	unsigned char supported_device = 0;

    status=read_eeprom_manufacturer();
    device_code=status>>8;
    manufacturer_code=status&0xFF;
    print("Manufacturer : ");
    switch (manufacturer_code) {
        case 1:
            supported_device = 1;
            println("AMD");
            break;
        case 31:
            println("Atmel");
            break;
        case 32:
            println("ST Microelectronics");
            break;
        case 0xBF:
            println("Microchip");
            break;
        default:
            println("unknown");
    }

    print("Device Id : ");
    switch (device_code) {
        case 0x20:
            println("29F010");
            supported_device = 0;
            break;
        case 0xA4:
            println("29F040");
            supported_device = 1;
            break;
        case 0xB7:
			println("39SF040");
            supported_device = 0;
            break;
        case 0xE2:
            supported_device = 0;
            break;
        default:
            supported_device = 0;
            println("unknown");
            break;
    }

    return supported_device;
}

FILE *fp;

unsigned char buffer2[20];
static unsigned char i=0;

void update_kernel(char *filekernel) {
	char mkey;
	unsigned long signature_offset;
	unsigned char header_kernel[20];
    fp=fopen(filekernel, "r");

	if (fp==NULL) {
		print("Impossible to read : ");
		println(filekernel);
		return;
	}

	// Get Signature offset
	fseek(fp, 0xbff0, SEEK_SET);
	fread( header_kernel, 1, 15, fp );

	signature_offset =  (unsigned int)((header_kernel[9]-0x40) * 256) + header_kernel[8];
	fseek(fp,  signature_offset, SEEK_SET);
	// print Signature
	fread( buffer2, 1, 15, fp );
	fclose(fp);
	// Checking if signature start with K
	if (buffer2[0]!='K') {
		println("Error, this file is not a valid .r64 archive for kernel update");
		return;
	}

	print("Update kernel with this version : ");
	println(buffer2);
	println("Would you like to update now ?");
	mkey = cgetc();
	if (mkey!='y') {
		println("Operation aborted!");
	}

	mkey = checkEeprom();



	if (mkey == EEPROM_39SF040) {
		program_kernel_39SF040(filekernel);
		//println("Eeprom not supported");
		return;
	}

	if (mkey == 0) {
        println("Unsupported device : abort");
        return;
	}

	mkey = program_sector_29F040(filekernel,4,1);

	return;
}

unsigned char str_bank[5];

static unsigned char filename[200];

int main(int argc,char *argv[]) {

    static unsigned char j=0;
    unsigned char ret=0;
	unsigned char eeprom_type=0;
    unsigned char mykey=0;
    unsigned char bank;
    unsigned char physical_bank;
    unsigned int register_bank;
    unsigned char twil_register;

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

	if (strcmp(argv[1],"-k")==0) {
		update_kernel(argv[2]);
		return 0;
	}

	if (strcmp(argv[3],"-l")==0 && strcmp(argv[1],"-b")==0) {
		if (argv[2]=="") {
			print("Missing bank id");
			return 0;
		}

		strcpy(filename, argv[4]);
		if (strcpy(argv[4],"")==0) {
			println("Missing file to load");
			return 0;
		}

		bank=atoi(argv[2]);
		if (bank>64) {
			println("There is only 64 banks");
			return 1;
		}
		if (bank>32) {
			fp=fopen(filename,"r");
			if (fp==NULL) {
				printf("Can't open %s\n",filename);
				return 0;
			}
			fclose(fp);

			register_bank=twil_get_registers_from_id_bank(bank);
			twil_register=register_bank>>8;
			physical_bank=register_bank&0xFF;
			printf("Loading : %s into bank %d\n",filename,bank);

			ret=twil_program_rambank(physical_bank, filename, twil_register);
			if (ret==1) printf("File not found %s\n",filename);
    		return 0;
		}
		else {
			ret = checkEeprom();
			if (ret == EEPROM_39SF040) {
				if (bank < 9 && bank > 4) {
					println("Can not program bank 8, 7, 6, 5, use -r and -s flag");
					return(1);
				}
				if (bank == 0) {
					print("Can not program bank 0 flag");
					crlf();
					return(1);
				}
				printf("Programming bank %d ...\n",bank);
				fp=fopen(filename,"r");
				if (fp==NULL) {
					printf("Can't open ");
					println(filename);
					return 0;
				}
				fclose(fp);
				program_bank_39SF040(filename, bank);
				return(1);
			}
			else {
				printf("Impossible to program rom bank with this switch, use '-r -s X romfile64KB.r64' flags for EEPROM management %s %s\n",argv[3],argv[1]);
				return(1);
			}
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

	/* Program kernel or set (for 29F040)*/

	if (strcmp(argv[1],"-r")==0 && strcmp(argv[2],"-s")==0) {

		ret = checkEeprom();

		if (ret == 0) {
            printf("Unsupported device : abort\n");
            return(1);
		}

		if (ret == EEPROM_39SF040) {
			println("Eeprom does not support set mode : use -b & -l flag to load one bank");
			return(1);
		}

		// At this step only EEPROM_29F040 can be here

		if (strcmp(argv[4],"")==0) {
			if (ret==2)
				println("Missing 16KB file");
			else
				println("Missing file set of 64KB");
		}

		if (atoi(argv[3]) == 4) {
			printf("You have selected kernel set, if you press 'y', it will update the kernel with %s\n",argv[4]);
			println("Would you like to continue y/N (Oric will reboot)?");
			mykey=cgetc();
			if (mykey!='y') return 0;
		}

		if (atoi(argv[3]) ==4 )  {
			clrscr();
			cputsxy(0,0,"Updating kernel ...");
		}
		else {
			println("Please wait ...");
			printf("Loading : %s into set %s of rom\n",argv[4],argv[3]);
		}

		ret = program_sector_29F040(argv[4],atoi(argv[3]),1);

		if (ret==1) printf("File not found : %s\n",argv[4]);
			return 0;
  	}
    printf("Wrong parameters\n");
}

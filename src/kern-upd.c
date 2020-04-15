#include <stdio.h>
#include <conio.h>
#include <string.h>

#define TRUE -1
#define FALSE 0

extern  unsigned char program_kernel();

extern unsigned int read_eeprom_manufacturer();

extern  unsigned char twil_fetch_set();

extern unsigned char kernupd_change_set();

extern unsigned char loadAndProgram(unsigned char *filename,unsigned int length);

extern unsigned char write_flash();

int get_bank() {
	int b=0;
	while (b<1 || b>4) {
		printf("Hit Bank [1-4] :");
		b=getchar()-'0';
	}
	putchar('\n');
	return b;
}

	
int main() {
	unsigned int sect,bank,choice;
	unsigned char manufacturer_code;
	unsigned char device_code;
	static unsigned int status;
	unsigned char filenametoload[50];
	unsigned i=0;
	FILE *fp;

	strcpy(filenametoload,"");
	while (1) {
        clrscr();
		bgcolor(COLOR_BLUE);
		textcolor(COLOR_WHITE);
		cputsxy(1,1,"+-------------------------------------+");
		cputsxy(1,2,"|         Kernel update v2020.1       | ");
		cputsxy(1,3,"+-------------------------------------+");
		
		bgcolor(COLOR_BLACK);
		cputsxy(0,5,"This tool can only update kernel, shell and basic11");

        //printf("Current set of bank : %d \n\n",twil_fetch_set());
		//if (twil_fetch_set()==4)
			//printf("Be careful you will update kernel and shell\n");
		printf("\n\n\ni. Identify device\n");
		printf("\n");
		printf("p. Program Kernel, Shell and basic11 banks\n");
		//printf("l. Load file\n");
		//printf("s. Save file\n");
		printf("\n");
		//printf("w. Write bank : %s\n",filenametoload);
		//printf("r. Read bank \n");
		//printf("v. Verify bank\n");
		//printf("f. Change set of 64KB\n");

		//printf("c. Change set\n");
		printf("q. Quit\n\n");
		choice=cgetc();
		printf("\n\n");
		switch(choice) {
			case 'i':
				status=read_eeprom_manufacturer();
				device_code=status>>8;
				manufacturer_code=status&0xFF;
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
				break;

			// case 'l':
			// 	i=0;
			// 	strcpy(filenametoload,"");
			// 	printf("File to load : ");
			// 	//textcolor(1);
			// 	while (1) {
			// 		choice=cgetc();
			// 		if (choice!=0x0D && i!=14 && choice!=0x1b) {
			// 			// del
			// 			if (choice==0x7f)  {
			// 				if (i!=0) i--;
			// 			}
			// 			else {
			// 			filenametoload[i]=choice;
			// 			//printf("%c",choice);
						
			// 			i++;
						
			// 			}
			// 			filenametoload[i]=0;
			// 			cputsxy(15,16,filenametoload);
			// 		}
			// 		if (choice==0x0D || choice==0x1B) break;
			// 	}
			// 	if (choice==0x0D) {
			// 		filenametoload[i]=0;
			// 		fp=fopen(filenametoload,"r");
			// 		if (fp==NULL)
			// 			printf("Not found : %s\n",filenametoload);
			// 		else
			// 		{
			// 			printf("Opened");
			// 		}
					
			// 	}
			// 	break;


			case    'p':
				clrscr();
				printf("orix.r64 must be present at the root of the sdcard.\n\n");
				printf("Confirm programmation of the kernel (don't stop the oric until it finished): Y/n\n");
			    choice=cgetc();
				if (choice=='Y') {
					status=program_kernel();
					if (status==1)
						printf("Can't open /kernelsd.r64\n");
					else 
						printf("Finished\n");
				printf("Press a key\n");
			    choice=cgetc();						
				}
				break;
			// case 'w':
			// 	if (strlen(filenametoload)!=0) {
			// 		clrscr();
			// 		printf("We will write this file to ROM; don't turn off the oric.\n");
			// 		if (twil_fetch_set()==4)
			// 			printf("Be careful you will update kernel and shell : if something is wrong, you will not restart the oric or some command will be broken !!!");
			// 		printf("Confirm : Y/N\n");
			// 		choice=cgetc();
			// 		if (choice=='Y') {
			// 			cputs("Program : ...");
			// 			write_flash();
			// 		}
			// 		else
			// 			cputs("Cancelled");
					
			// 	}
			// 	else
			// 		printf("File to load not set, use 'l' option to set\n");

			// //	bank=get_bank();
			// //	erase_sector(bank);
			// //	write_flash(bank);
			// 	break;

			case 'q': 
				return 0;
			default:
				printf("Bad command\n");
		}
		printf("Press a key ");
		cgetc();
	}
	return 0;
}
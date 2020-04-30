#include <stdio.h>
#include <conio.h>
#include <string.h>

#define TRUE -1
#define FALSE 0

extern  unsigned char program_sector(unsigned char *file, unsigned char sector);

extern unsigned char program_bank_ram(unsigned char *file, unsigned char idbank, unsigned char bank64id);

extern unsigned int read_eeprom_manufacturer(unsigned char sector);

extern unsigned char * display_signature_bank(unsigned char sector,unsigned char bank);

int get_bank() {
	int b=0;
	while (b<1 || b>4) {
		printf("Hit Bank [1-4] :");
		b=getchar()-'0';
	}
	putchar('\n');
	return b;
}

unsigned char displayroms() {
	unsigned char *signature;
	signature=display_signature_bank(0,4);
	cputsxy(2,10,signature);


}


void menu (unsigned char current_menu) {
	unsigned char posy=4;
    unsigned char version;

    unsigned char key;
    unsigned char validate=1;
    unsigned char redraw=1;

    while (1) {

    if (current_menu==0)
        bgcolor (COLOR_RED);
    else
        bgcolor (COLOR_BLACK); 

    cputsxy(2,posy,"ROM");

    if (current_menu==1)
        bgcolor (COLOR_RED);
    else
        bgcolor (COLOR_BLACK); 
    
    cputsxy(7,posy,"RAM");

    if (current_menu==2)
        bgcolor (COLOR_RED);
    else
        bgcolor (COLOR_BLACK); 

    cputsxy(12,posy,"Quit");
    
    bgcolor(COLOR_BLACK);
    gotoxy(23,posy);
    cputc(' '); 


        if (current_menu==0 && validate==0) {
            key=displayroms();
            redraw=0;
        }    

       if (current_menu==1 && validate==0) {
            //key=tools();
            redraw=0;
        }     

        if (current_menu==2 && validate==0) break;
        if (validate==0) validate=1;

        if (redraw==1) 
            key=cgetc();
        else
            redraw=1;

        if (key==9) {
            if (current_menu!=2)
                current_menu++;
        }
        if (key==8) {
            if (current_menu!=0)
                current_menu--;
        }
        if (key==13)
            validate=0;

        if (key==27) break;
    }

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
		cputsxy(1,2,"|          Orixcfg v2020.2            |");
		cputsxy(1,3,"+-------------------------------------+");
		menu (0);
		/*
		bgcolor(COLOR_BLACK);
		cputsxy(0,5,"This tool can only update kernel, shell and basic11");

		printf("\n\n\ni. Identify device\n");
		printf("\n");
		printf("p. Program Kernel, Shell and basic11 banks\n");
		printf("\n");
		printf("x. Program 4,3,2,1 banks\n");
		printf("\n");
		//printf("w. load a bank into ram\n");
		//printf("\n");
		printf("q. Quit\n\n");
		choice=cgetc();
		printf("\n\n");
		*/
		switch(choice) {
			case 'i':
				status=read_eeprom_manufacturer(0);
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
				
			case 'w':
				status=program_bank_ram("monitor.rom",1,0);
				if (status==1) {
					printf("File not found : monitor.rom");
					break;

				}
				status=program_bank_ram("monitor.rom",2,0);
				status=program_bank_ram("monitor.rom",3,0);
				status=program_bank_ram("monitor.rom",4,0);
				break;
				

			case    'p':
				printf("kernelsd.r64 must be present in sdcard root folder.\n\n");
				printf("Confirm programmation of the kernel (don't stop the oric until it finished): Y/n\n");
			    choice=cgetc();
				if (choice=='Y') {
					clrscr();
					cputsxy(0,0,"Offset :");
					cputsxy(14,0,"Bank :");
					status=program_sector("kernelsd.r64",4);
					if (status==1)
						cputsxy(20,20,"Can't open /kernelsd.r64");

					else 
						cputsxy(20,20,"Finished");
				

			    choice=cgetc();						
				}
				break;

			case    'x':
				printf("bank4321.r64 must be present in sdcard root folder.\n\n");
				printf("Confirm programmation (don't stop the oric until it finished): Y/n\n");
			    choice=cgetc();
				if (choice=='Y') {
					clrscr();
					cputsxy(0,0,"Offset :");
					cputsxy(14,0,"Bank :");
					status=program_sector("bank4321.r64",0);
					if (status==1)
						cputsxy(20,20,"Can't open /bank4321.r64");

					else 
						cputsxy(20,20,"Finished");
				

			    choice=cgetc();						
				}
				break;

			case    't':
				printf("bank4321.r64 must be present in sdcard root folder.\n\n");
				printf("Confirm programmation (don't stop the oric until it finished): Y/n\n");
			    choice=cgetc();
				if (choice=='Y') {
					clrscr();
					cputsxy(0,0,"Offset :");
					cputsxy(14,0,"Bank :");
					status=program_sector("bank4321.r64",1);
					if (status==1)
						cputsxy(20,20,"Can't open /bank4321.r64");

					else 
						cputsxy(20,20,"Finished");
				

			    choice=cgetc();						
				}
				break;

			case 'q': 
				return 0;
			default:
				printf("Bad command\n");
		}
		cputsxy(20,26,"<Press a key>");

		cgetc();
	}
	return 0;
}
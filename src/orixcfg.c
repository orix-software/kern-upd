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
	unsigned char setstring[41];
	unsigned char i;
	unsigned char current_set=0;
	unsigned char key;
	unsigned char current_menu=1;
	unsigned char draw=1;
	unsigned char posx_label_menu[3]={2,14,24};
	char label_menu_gen[3][12] =
			{ "Prev. set",
  			"Next set",
			"Program set"
			};
	
	for (i=7;i>0;i--) {
		signature=display_signature_bank(0,i);
		if (i<5)
			cputsxy(2,17-i,signature);
		else
			cputsxy(2,14-i,signature);
	}

	cputsxy(0,6,"+---Main-------------------------------+");

	cputsxy(0,7,"|");
	cputsxy(39,7,"|");

	cputsxy(0,8,"|");
	cputsxy(39,8,"|");	

	cputsxy(0,9,"|");
	cputsxy(39,9,"|");
	

	cputsxy(0,11,"|");	
	cputsxy(0,12,"|");	
	cputsxy(0,13,"|");	
	cputsxy(0,14,"|");
	cputsxy(0,15,"|");	
	cputsxy(0,16,"|");				

/*
	cputsxy(31,11,"|");	
	cputsxy(31,12,"|");	
	cputsxy(31,13,"|");	
	cputsxy(31,14,"|");	
*/
	cputsxy(39,11,"|");	
	cputsxy(39,12,"|");	
	cputsxy(39,13,"|");	
	cputsxy(39,14,"|");	
	cputsxy(39,15,"|");	
	cputsxy(39,16,"|");		


	current_menu=2;
	cputsxy(0,17,  "+--------------------------------------+");
	cputsxy(0,12,  "+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+");



	while (1) {
		if (draw==1) {
			sprintf(setstring, "+---Set %d------------------------------+", current_set);
			cputsxy(0,10, setstring);

			if (current_menu==1)
				bgcolor(COLOR_RED);
			else
				bgcolor(COLOR_BLACK);
			if (current_set!=0) {
				cputsxy(posx_label_menu[0],11,label_menu_gen[0]);	
				cputsxy(0,11,"|");	
			}

			if (current_menu==2)
				bgcolor(COLOR_RED);
			else
				bgcolor(COLOR_BLACK);
			cputsxy(posx_label_menu[1],11,label_menu_gen[1]);	

			if (current_menu==3)
				bgcolor(COLOR_RED);
			else
				bgcolor(COLOR_BLACK);
			cputsxy(posx_label_menu[2],11,label_menu_gen[2]);					

			draw=0;
		}

		key=cgetc();
		if (key==13) {
			if (current_menu==2 && current_set!=7) current_set++;
			if (current_menu==1 && current_set!=0) current_set--;
			draw=1;
		}

		// gauche
		if (key==8 && current_menu!=1) {
			 if (current_set==0 && current_menu==2) 
			 	draw=0;
			 else {
				current_menu--;
				draw=1;
			 }
		}		

		//droote
		if (key==9 && current_menu!=3) {
			current_menu++;
			draw=1;
		}
	

		if (key==11) {
			bgcolor(COLOR_BLACK);			
			cputsxy(posx_label_menu[current_menu],11,label_menu_gen[current_menu]);				
			return 0;
		}		


		if (key==27) {
			bgcolor(COLOR_BLACK);			
			cputsxy(posx_label_menu[current_menu],11,label_menu_gen[current_menu]);	
			return 0;
		}	

	}
	//cputsxy(0,8,"|");
	//cputsxy(39,8,"|");	
/*
//cputsxy(0,10,  "+--------------------------------------+");


	cputsxy(0,14-5,"|");
	cputsxy(39,14-5,"|");		
	
	cputsxy(0,20,  "+--------------------------------------+");
	
*/	

}


void menu (unsigned char current_menu) {
	unsigned char posy=4;
    unsigned char version;

    unsigned char key;
    unsigned char validate=1;
    unsigned char redraw=1;
	unsigned char posx_label_menu[2]={2,7};
	char label_menu_gen[2][6] =
			{ "ROM",
  			"Quit"
			};

    while (1) {

		if (current_menu==0)
			bgcolor (COLOR_RED);
		else
			bgcolor (COLOR_BLACK); 

		cputsxy(posx_label_menu[0],posy,label_menu_gen[0]);

		if (current_menu==1)
			bgcolor (COLOR_RED);
		else
			bgcolor (COLOR_BLACK); 
	/* 
		cputsxy(7,posy,"RAM");

		if (current_menu==2)
			bgcolor (COLOR_RED);
		else
			bgcolor (COLOR_BLACK); 
	*/
		cputsxy(posx_label_menu[1],posy,label_menu_gen[1]);
		
		bgcolor(COLOR_BLACK);
		gotoxy(13,posy);
		cputc(' '); 


        if (current_menu==0 && validate==0) {
			bgcolor (COLOR_BLACK); 
			cputsxy(posx_label_menu[0],posy,label_menu_gen[0]);						
            key=displayroms();
            redraw=0;
        }    
/*
       if (current_menu==1 && validate==0) {
            //key=tools();
            redraw=0;
        }     
*/
        if (current_menu==1 && validate==0) break;
        if (validate==0) validate=1;

        if (redraw==1) 
            key=cgetc();
        else
            redraw=1;

        if (key==9) {
            if (current_menu!=1)
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
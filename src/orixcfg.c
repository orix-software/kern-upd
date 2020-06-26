#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <telestrat.h>

#include "../dependencies/twilighte-lib/src/include/twilighte.h"

#define TRUE -1
#define FALSE 0

extern unsigned char program_sector(unsigned char *file, unsigned char sector, unsigned char counterdisplay);

extern unsigned char program_bank_ram(unsigned char *file, unsigned char idbank, unsigned char bank64id);

extern unsigned int read_eeprom_manufacturer(unsigned char sector);

extern unsigned char * display_signature_bank(unsigned char sector,unsigned char bank);

#define MAX_SIZE_CONTENT_CONF 1000
#define MAX_SLOT 4

unsigned char content_conf[MAX_SIZE_CONTENT_CONF];
unsigned char current_set=0;

FILE *fp;

int get_bank() {
	int b=0;
	while (b<1 || b>4) {
		printf("Hit Bank [1-4] :");
		b=getchar()-'0';
	}
	putchar('\n');
	return b;
}

#define MAX_LENGTH_OF_PATH 50

	unsigned char label[MAX_SLOT][20];
	unsigned char path[MAX_SLOT][MAX_LENGTH_OF_PATH];

// Return next position or 0 if we reach end of line or end of file

unsigned char getLabel(unsigned int posStart, unsigned char maxChars,unsigned char cart) {
	unsigned int i,j;
	j=0;
	for (i=posStart;i<maxChars;i++) {
		if (content_conf[i]==0x0a) {
			//i++;
			return 0;
		}
			
		if (content_conf[i]!=';') {
			label[cart][j]=content_conf[i];
			j++;
		}
		else {
			label[cart][j]=0;
			cputsxy(6,18+cart,label[cart]);	
			i++;
			break;
		}
	}
	if (i>maxChars) {
			return 0;
		}

	return i;
}


unsigned char getPath(unsigned int posStart, unsigned char maxChars,unsigned char cart) {
	unsigned int i,j;
	j=0;
	for (i=posStart;i<maxChars;i++) {
		if (i>maxChars) {
			return 0;
		}
			
		if (content_conf[i]!=0x0a) {
			path[cart][j]=content_conf[i];
			j++;
		}
		else {
			if (j>MAX_LENGTH_OF_PATH) return 0; // Overflow
			path[cart][j]=0;
			i++;
			break;
		}
	}
	//path[cart][j]=0;
	//if (content_conf[i]==0x0A) i++;
	return i;
}


unsigned char displays_and_program() {

	//static char line[100];
	unsigned char setstring[80];
	unsigned int nb,i;
	unsigned char *filename="/etc/orixcfg/carts.cnf";
	unsigned char key,status;
	unsigned char current_cart;
	static unsigned char cart;
	unsigned char label_found=0;

	fp=fopen(filename,"r");
	if (fp==NULL) {
		printf("Can not open %s\n",filename);
		clrscr();
		return 0;
	}
	bgcolor(COLOR_BLACK);
	cputsxy(2,17,"+--Choose the set to load------+");	
	cputsxy(2,24,"+------------------------------------+");	
	cputsxy(2,18,"|");	
	cputsxy(2,19,"|");	
	cputsxy(2,20,"|");
	cputsxy(2,21,"|");
	cputsxy(2,22,"|");	
	cputsxy(2,23,"|");	
	//cputsxy(2,24,"|");

	cputsxy(39,18,"|");	
	cputsxy(39,19,"|");	
	cputsxy(39,20,"|");
	cputsxy(39,21,"|");
	cputsxy(39,22,"|");	
	cputsxy(39,23,"|");	
	//cputsxy(39,24,"|");

	nb=fread(content_conf,MAX_SIZE_CONTENT_CONF,1,fp);
	//Monitor-Forth;/usr/share/carts/mfee.r64;Monitor 2020.1, Forth 2020.1, Empty Rom 2020.1, Empty Rom 2020.1;mfee.hlp
	//printf("Number of bytes : %d",nb);

	cart=0;
	label_found=0;
	i=0;
	bgcolor(COLOR_RED);
	while (i<nb) {
		if (cart!=0)
			bgcolor(COLOR_BLACK);
		i=getLabel(i, nb,cart);
		if (i==0) {
			textcolor(COLOR_RED);
			cputsxy(3,26,"Error cannot found label");	
			return 1;
		}
		i=getPath(i, nb,cart);
		if (i==0) {
			printf("Return");
			break;
		}
		if (strlen(label[cart])!=0) cart++;
		if (cart>MAX_SLOT) break;
	}
	cart--;
	current_cart=0;
	while (1) {
		key=cgetc();

		if (key==10 && current_cart!=cart) {
			bgcolor(COLOR_BLACK);
			cputsxy(5,18+current_cart," ");	
			current_cart++;
			bgcolor(COLOR_RED);
			cputsxy(5,18+current_cart," ");				
		}		

		if (key==11 && current_cart!=0 ) {
			bgcolor(COLOR_BLACK);
			cputsxy(5,18+current_cart," ");	
			current_cart--;
			bgcolor(COLOR_RED);
			cputsxy(5,18+current_cart," ");		
		}

		if (key==13) {
			bgcolor(COLOR_BLACK);
			if (current_set==4)
				sprintf(setstring, "Do you want to load this cart !KERNEL! into sector %d of the eeprom  [y/N]? ",current_set);
			else
				sprintf(setstring, "Load this cart into %d ROM set with file %s [y/N] ? ",current_set,path[current_cart]);
			cputsxy(2,25,setstring);
			key=cgetc();
			if (key=='Y') {

				//Program
					status=program_sector(path[current_cart],current_set,0);
					cclearxy (0, 25, 40);
					cclearxy (0, 26, 40);
					cclearxy (0, 27, 40);
					if (status==1) {
						cputsxy(20,25,"Can't open file");
					}

					else 
						cputsxy(20,25,"Finished");

			}
			else {
				cclearxy (0, 25, 40);
				cclearxy (0, 26, 40);
				cclearxy (0, 27, 40);
			}
		}

		if (key==27) {
			bgcolor(COLOR_BLACK);
			cputsxy(2,17,  "+------------------------------------+");
			for (i=0;i<8;i++)
				cclearxy (0, 18+i, 40);
			
			return 0;
		}	

	}
}

unsigned char displayroms() {
	unsigned char *signature;
	unsigned char setstring[41];
	unsigned char i;

	unsigned char key;
	unsigned char current_menu_rom=1;
	unsigned char draw=1;
	static unsigned char posx_label_menu[3]={4,15,25};
	static char label_menu_gen[3][12] =
			{ "Prev. set",
  			"Next set",
			"Program set"
			};
	

	textcolor(COLOR_WHITE);
	cputsxy(2,6,"+---Main-----------------------------+");

	cputsxy(2,7,"|");

	cputsxy(39,7,"|");

	cputsxy(2,8,"|");
	cputsxy(39,8,"|");	

	cputsxy(2,9,"|");
	cputsxy(39,9,"|");
	

	cputsxy(2,11,"|");	
	cputsxy(2,12,"|");	
	cputsxy(2,13,"|");	
	cputsxy(2,14,"|");
	cputsxy(2,15,"|");	
	cputsxy(2,16,"|");	
		

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


	current_menu_rom=2;
	cputsxy(2,17,  "+------------------------------------+");
	cputsxy(2,12,  "+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+");



	while (1) {
		if (draw==1) {
			bgcolor(COLOR_BLACK);
			if (current_set==4)
				sprintf(setstring, "+---Set %d Kernel Set be careful ! ---+", current_set);
			else
				sprintf(setstring, "+---Set %d----------------------------+", current_set);
			cputsxy(2,10, setstring);

			for (i=7;i>0;i--) {
				signature=display_signature_bank(current_set,i);
				sprintf(setstring, "|%s", signature);
				if (i<5) {
					cclearxy (2, 17-i, 34);
					cputsxy(2,17-i,setstring);
				}
				else {
					cclearxy (2, 14-i, 34);
					cputsxy(2,14-i,setstring);
				}
	}

			if (current_menu_rom==1)
				bgcolor(COLOR_RED);
			else
				bgcolor(COLOR_BLACK);

			if (current_set!=0) {
				cputsxy(posx_label_menu[0],11,label_menu_gen[0]);	
				cputsxy(2,11,"|");	
			}

			if (current_menu_rom==2)
				bgcolor(COLOR_RED);
			else
				bgcolor(COLOR_BLACK);

			cputsxy(posx_label_menu[1],11,label_menu_gen[1]);	

			if (current_menu_rom==3)
				bgcolor(COLOR_RED);
			else
				bgcolor(COLOR_BLACK);
			cputsxy(posx_label_menu[2],11,label_menu_gen[2]);					

			draw=0;
		}

		key=cgetc();
		if (key==13) {
			if (current_menu_rom==2 && current_set!=7) current_set++;
			if (current_menu_rom==1 && current_set!=0) current_set--;
			if (current_menu_rom==3) displays_and_program();
			
			draw=1;
		}

		// gauche
		if (key==8 && current_menu_rom!=1) {
			 if (current_set==0 && current_menu_rom==2) 
			 	draw=0;
			 else {
				current_menu_rom--;
				draw=1;
			 }
		}		

		//droote
		if (key==9 && current_menu_rom!=3) {
			current_menu_rom++;
			draw=1;
		}
	

		if (key==11) {
			bgcolor(COLOR_BLACK);			
			cputsxy(posx_label_menu[current_menu_rom],11,label_menu_gen[current_menu_rom]);				
			return 0;
		}		


		if (key==27) {
			bgcolor(COLOR_BLACK);			
			//cputsxy(posx_label_menu[current_menu_rom],11,label_menu_gen[current_menu_rom]);	
			return 0;
		}	

	}


}


void menu () {
	static unsigned char posy=4;
	static unsigned char current_menu=0;
    static unsigned char key;
    static unsigned char validate=1;
    static unsigned char redraw=1;
	static unsigned char posx_label_menu_gen[2]={2,7};
	static char label_menu_gen[2][6] =
			{ "ROM",
  			"Quit"
			};

    while (1) {

		if (current_menu==0)
			bgcolor (COLOR_RED);
		else
			bgcolor (COLOR_BLACK); 

		cputsxy(posx_label_menu_gen[0],4,label_menu_gen[0]);

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
		cputsxy(posx_label_menu_gen[1],4,label_menu_gen[1]);
		
		bgcolor(COLOR_BLACK);
		gotoxy(13,4);
		cputc(' '); 


        if (current_menu==0 && validate==0) {
			bgcolor (COLOR_BLACK); 
			cputsxy(posx_label_menu_gen[0],4,label_menu_gen[0]);						
            displayroms();

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

        if (redraw==1) {
            key=cgetc();

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
        else
            redraw=1;

    }

}

void usage()
{
  printf("usage:\n");
  //printf("orixcfg : Launch menu\n");
  printf("orixcfg -i : displays info\n");
  //printf("orixcfg -A : Init all SRAM banks with empty signature\n");
  printf("orixcfg -v : displays version\n");
  printf("orixcfg -h : displays help\n");
  printf("orixcfg -r -s X romfile64KB.r64 : Load romfile into set X\n");
  printf("orixcfg -w -s X -b Y romfile16KB : Load romfile in bank Y into set X in RAM slot\n");
  printf("orixcfg -w -s X -b Y -c : Clear RAM in set X and bank Y\n");
  //printf("orixcfg -w -s X -b Y -t : Display RAM signature in set X and bank Y\n");
  return;
}
    

void version() {
	printf("v2020.3\n");
}

void getEEPROMId() {
		unsigned char manufacturer_code;
	unsigned char device_code;
	static unsigned int status;
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
}

void initRAM() {

}

int main(int argc,char *argv[]) {
	unsigned char i=0;
	unsigned char ret=0;
	unsigned char mykey=0;


  	if (argc==1)  {
    usage();
    return 0;
   }

  	if (argc==2 && strcmp(argv[1],"-v")==0)  {
    version();
    return 0;
   }
 
  if (argc==2 && strcmp(argv[1],"-h")==0)
  {
    usage();
    return 0;
  } 
 
  if (argc==2 && strcmp(argv[1],"-i")==0)
  {
    getEEPROMId();
    return 0;
  } 

  if (argc==2 && strcmp(argv[1],"-A")==0)
  {
    initRAM();
    return 0;
  } 
  //printf("orixcfg -w -s X -b Y romfile16KB : Load romfile into set X in bank Y\n");
//twil_program_rambank(unsigned char bank, char *file, unsigned char set);
//
//;unsigned char twil_clear_rambank(unsigned char bank, unsigned char set);

if (strcmp(argv[1],"-w")==0 && strcmp(argv[2],"-s")==0 && strcmp(argv[4],"-b")==0 && strcmp(argv[6],"-t")==0 ) {
	printf("%s",twil_display_signature_bank(TWIL_BANK_TYPE_RAM, atoi(argv[3]),  atoi(argv[5]) ) );
    return 0;
  } 

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
		printf("Missing file set of 64KB");
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
    //initRAM();
    return 0;
  } 

return 0;					
		

    clrscr();
	bgcolor(COLOR_BLUE);
	textcolor(COLOR_WHITE);
	cputsxy(2,1,"+-----------------------------------+");
	cputsxy(2,2,"|          Orixcfg v2020.4          |");
	cputsxy(2,3,"+-----------------------------------+");

	menu ();
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
	/*
		switch(choice) {
			case 'i':
				getEEPROMId();
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
	*/
	clrscr();
	return 0;
}
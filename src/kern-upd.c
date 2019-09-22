#include <stdio.h>
#include <conio.h>

#define TRUE -1
#define FALSE 0

extern unsigned char read_eeprom_manufacturer();

extern  unsigned char twil_fetch_set();

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
	unsigned int sect,bank,choice,device_code;
	unsigned char manufacturer_code,status;

	while (1) {
        clrscr();
		printf("Kernel update v0.1\n\n");

        printf("Current set of bank : %d \n\n",twil_fetch_set());
		printf("i. Identify device\n");
		printf("\n");
		printf("l. Load file\n");
		printf("s. Save file\n");
		printf("\n");
		printf("w. Write (program) bank\n");
		printf("r. Read bank \n");
		printf("v. Verify bank\n");
		printf("\n");
		printf("c. Erase Chip\n");
		printf("q. Quit\n\n");
		choice=cgetc();
		printf("\n\n");
		switch(choice) {
			case 'i':
				status=read_eeprom_manufacturer();
				manufacturer_code=status>>8;
				device_code=status&0xFF;
				printf("Manufacturer : %d ",manufacturer_code);
			
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
			case 'c':
				printf("Erase complete chip (Y/N) ? ");
				//status=getchar();
				if (status=='Y' || status=='y')
				//	erase_chip();
				break;

			case 'w':
			//	bank=get_bank();
			//	erase_sector(bank);
			//	write_flash(bank);
				break;
			case 'r':
//				bank=get_bank();
	//			read_flash(bank);
				break;
			case 'v':
			//	bank=get_bank();
		//		status=verify_flash(bank);
				if (status) printf("Verify error in #%x\n",status);
				else printf("Verify OK\n");
				break;

			case 'q': //exit(0);
			default:
				printf("Bad command\n");
		}
		printf("Press a key ");
		cgetc();
	}
	return 0;
}

.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65




.include "dependencies/ch376-lib/src/include/ch376.inc"
.include "dependencies/ch376-lib/src/_ch376_wait_response.s"
.include "dependencies/ch376-lib/src/_ch376_set_bytes_read.s"
.include "dependencies/ch376-lib/src/_ch376_set_file_name.s"
.include "dependencies/ch376-lib/src/_ch376_file_open.s"

.export _read_eeprom_manufacturer
.export _twil_fetch_set
.export _kernupd_change_set

.export _program_kernel

.importzp ptr1,ptr2,ptr3

.importzp tmp1,tmp2,tmp3

nb_bytes_read:=tmp3

twilighte_banking_register := $343
twilighte_register         := $342

.proc _program_kernel
	sei
	lda		#$00
	sta		posx
	jsr		save_twil_registers
	; on swappe pour que les banques 8,7,6,5 se retrouvent en bas en id : 1, 2, 3, 4
	
	
	lda  	#$03 ; pour debug FIXME, cela devrait être à 4
	sta  	twilighte_banking_register

	lda		twilighte_register
	and		#%11011111
	sta		twilighte_register

	lda		#$01
	sta		current_bank

    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND
    lda     #'/'

    sta     CH376_DATA
	lda		#$00
    sta     CH376_DATA
	jsr		_ch376_file_open


reset_label:

    lda     #CH376_SET_FILE_NAME        ;$2f
    sta     CH376_COMMAND

	ldy		#$00
@L1:	
	lda		str_rom,y
    beq 	@S1
  	
  	cmp     #'a'                        ; 'a'
  	bcc     @do_not_uppercase
  	cmp     #'z'+1                        ; 'z'
  	bcs     @do_not_uppercase
  	sbc     #$1F
@do_not_uppercase:
	sta		CH376_DATA
	iny
	bne		@L1
	lda		#$00
@S1:
	sta		CH376_DATA
	
	jsr		_ch376_file_open

    cmp		#CH376_ERR_MISS_FILE
    bne 	start
	jsr		restore_twil_registers
	lda		#01
	cli
	rts


start:
	lda		#$11
	sta		$bb80

	lda		#$00
	sta		ptr2

	lda		#$00
	sta		ptr2+1	

	lda		#$00
	sta		ptr3

	lda		#$C0
	sta		ptr3+1	



    lda		#$FF
    tay
    jsr		_ch376_set_bytes_read

@loop:
    cmp		#CH376_USB_INT_DISK_READ
    bne		@finished

    lda		#CH376_RD_USB_DATA0
    sta		CH376_COMMAND
    lda		CH376_DATA
	sta		tmp1
    ; Tester si userzp == 0?

  @read_byte:
	
    lda		CH376_DATA
	pha
	jsr		write_kernel
	pla

  	cmp     #'A'                        ; 'a'
  	bcc     @display
  	cmp     #'z'+1                        ; 'z'
  	bcs     @display
	lda     #'.'
@display:
	ldx		posx
  	sta		$bb80+40,x
	inx
	stx		posx

	inc		ptr2
	bne		@skip_inc
	inc		ptr2+1
	lda		ptr2
	cmp		#$C0
	bne		@skip_inc

; On 
	lda		#$00
	sta		ptr3

	lda		#$C0
	sta		ptr3+1	


	ldx		current_bank
	inx		
	cpx     #$05
	bne		@skip_inc
	; end we stop
	lda		#00
	cli
	rts

@skip_inc:	

  ;  BRK_TELEMON XWR0

  @next:
    dec		tmp1
    bne		@read_byte

    lda		#CH376_BYTE_RD_GO
    sta		CH376_COMMAND
    jsr		_ch376_wait_response

    ; _ch376_wait_response renvoie 1 en cas d'erreur et le CH376 ne renvoie pas de valeur 0
    ; donc le bne devient un saut inconditionnel!
    bne		@loop
 @finished:
	jsr		restore_twil_registers

	lda		#$00
	cli
	rts
str_rom:	
	.asciiz "kernelsd.r64"

str_slash:
	.asciiz "/"
posx:
	.res 1	
.endproc
current_bank:
.res	1

.proc write_kernel


write_loop:
	pha
	
	lda		#$A0
	jsr		sequence

	lda  	#$03 ; pour debug FIXME, cela devrait être à 4
	sta  	twilighte_banking_register


	lda		current_bank ; Switch to bank
	jsr		select_bank


	lda		#$12
	sta		$bb81

	pla
	ldy		#$00
	sta		(ptr3),y
wait_write:
	cmp		(ptr3),y
	bne		wait_write
	inc		ptr3
	bcc		@S1
	inc		ptr3+1
@S1:

	
	rts
.endproc


.proc	save_twil_registers
    lda		VIA2::PRA   
	sta		save
	lda		twilighte_banking_register
	sta		twilighte_banking_register_save

	lda		twilighte_register
	sta		twilighte_register_save
    rts
.endproc	

.proc	restore_twil_registers
    lda		save
	sta		VIA2::PRA 
	lda		twilighte_banking_register_save
	sta		twilighte_banking_register
	lda		twilighte_register_save
	sta		twilighte_register
	rts
.endproc


.proc _kernupd_change_set
    sta		twilighte_banking_register
.endproc

.proc  _twil_fetch_set
    lda		twilighte_banking_register
	ldx		#$00
	rts
.endproc

.proc _read_eeprom_manufacturer
	sei
	php
    lda		VIA2::PRA   
	sta		save


	lda		twilighte_banking_register
	sta		twilighte_banking_register_save

	lda		twilighte_register
	sta		twilighte_register_save
	

	;jsr	_program_eeprom
	lda		#$90
	jsr		sequence
	lda		$C000 ; manufacturer
	sta		tmp

	lda		$C001 ; device ID
	sta		tmp+1
	
	; Reset eeprom autoselect
	lda		#$F0
	sta		$C000

    lda		save
	sta		VIA2::PRA 
	lda		twilighte_banking_register_save
	sta		twilighte_banking_register
	lda		twilighte_register_save
	sta		twilighte_register
	
	lda		tmp ; manufacturer
	ldx		tmp+1 ; 

	plp
	cli	

	rts
tmp:
	.res 2	

.endproc

.proc _program_eeprom
    lda     twilighte_register
    and     #%00000000
    sta     twilighte_register
	rts
.endproc

.proc _activate_eeprom
    lda     twilighte_register
    ora     #%10000000
    sta     twilighte_register
    rts
.endproc


.proc select_bank
  
  sta	VIA2::PRA
  rts
.endproc


.proc sequence
	pha
	lda		#$00
	sta		twilighte_banking_register
	; $5555 
	lda		#$01
	jsr		select_bank
	
	lda		#$AA
	sta		$D555

	; $2AAA
	lda		#04
	sta		twilighte_banking_register

	lda		#$04
	jsr		select_bank
	
	lda		#$55
	sta		$EAAA

	; $5555
	lda		#$00
	sta		twilighte_banking_register

	lda		#$01
	jsr		select_bank
	pla
	sta		$D555
	rts
.endproc



save:
    .res 1	
twilighte_banking_register_save:
    .res 1		
twilighte_register_save:
    .res 1		
default_string:
    .asciiz "empty.r64"

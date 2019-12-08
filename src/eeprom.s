
.include "telestrat.inc"

.export _read_eeprom_manufacturer
.export _twil_fetch_set

.importzp ptr1

.proc  _twil_fetch_set
    lda	$343
	ldx	#$00
	rts
.endproc

.proc enter
.endproc

.proc exit
.endproc


.proc _read_eeprom_manufacturer
	sei
	php
    lda  VIA2::PRA   
	sta	 save
	lda  $343
	sta  twilighte_banking_register_save

	lda  $342
	sta  twilighte_register_save
	

	;jsr	_program_eeprom
	lda #$90
	jsr sequence
	lda $C000 ; manufacturer
	sta tmp
	;sta $5000

	lda $C001 ; device ID
	sta tmp+1
	;sta $5001

	lda #$F0
	sta $C000
	
	;jsr _activate_eeprom


    lda  save
	sta	 VIA2::PRA 
	lda  twilighte_banking_register_save
	sta  $343
	lda  twilighte_register_save
	sta  $342
	
	lda tmp ; manufacturer
	ldx tmp+1 ; 

	plp
	cli	

	rts
tmp:
	.res 2	

.endproc

.proc _program_eeprom
    lda     $342
    and     #%00000000
    sta     $342
	rts
.endproc

.proc _activate_eeprom
    lda     $342
    ora     #%10000000
    sta     $342
    rts
.endproc


.proc select_bank
  
  sta	VIA2::PRA
  rts
.endproc


.proc sequence
	pha
	lda	 #00
	sta	 $343
	; $5555 
	lda #1
	jsr select_bank
	
	lda #$AA
	sta $D555

	; $2AAA
	lda	 #04
	sta	 $343

	lda #4
	jsr select_bank
	
	lda #$55
	sta $EAAA

	; $5555
	lda	 #00
	sta	 $343

	lda #1
	jsr select_bank
	pla
	sta $D555
	rts
.endproc
save:
    .res 1	
twilighte_banking_register_save:
    .res 1		
twilighte_register_save:
    .res 1		

    ; Device ID
;    lda     #$AA
 ;   sta     $C555

  ;  lda     #$55
    ;sta     $C2AA

    ;lda     #$90
    ;sta     $C555
    
;    lda     #$01
 ;   sta     $C000

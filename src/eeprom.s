
.export _read_eeprom_manufacturer
.export _twil_fetch_set

.importzp ptr1

.proc  _twil_fetch_set
    lda	$343
	ldx	#$00
	rts
.endproc

.proc _read_eeprom_manufacturer
	php
	sei
	jsr	_program_eeprom
	lda #$90
	jsr sequence
	lda $C000
	sta tmp
	lda $C001
	sta tmp+1
	lda #$F0
	sta $C000
	jsr _activate_eeprom
	lda tmp
	ldy tmp+1
	
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


.proc sequence
	pha
	;jsr select_bank
	lda #$AA
	sta $C555

	lda #$55
	sta $C2AA

	pla
	sta $C555
	rts
.endproc


    ; Device ID
;    lda     #$AA
 ;   sta     $C555

  ;  lda     #$55
    ;sta     $C2AA

    ;lda     #$90
    ;sta     $C555
    
;    lda     #$01
 ;   sta     $C000

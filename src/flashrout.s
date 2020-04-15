select_sector
	asl a
	asl a
select_bank
	bit _external
	bpl internal
	ora #$80
	sta $0380
	rts
internal
	sta $030F
	lda $0300
	and #$DF
	sta $0300
	ora #$20
	sta $0300
	rts

disable_flash
	lda #0
	bit _external
	bpl internal
	sta $0380
	rts

sequence
	pha
	lda #1
	jsr select_bank
	lda #$AA
	sta $D555
	lda #0
	jsr select_bank
	lda #$55
	sta $EAAA
	lda #1
	jsr select_bank
	pla
	sta $D555
	rts

_erase_sector
	php
	sei
	ldy #0
	lda (sp),y
	jsr select_sector
	lda #$AA
	sta $C555
	lda #$55
	sta $C2AA
	lda #$80
	sta $C555
	lda #$AA
	sta $C555
	lda #$55
	sta $C2AA
	lda #$30
	sta $C000
wait_erase
	bit $C000
	bpl wait_erase
	jsr disable_flash
	plp
	rts

_erase_chip
	php
	sei
	lda #$80
	jsr sequence
	lda #$10
	jsr sequence
wait_complete
	bit $D555
	bpl wait_complete
	jsr disable_flash
	plp
	rts



_write_flash
	php
	sei
	ldy #0
	lda (sp),y
	sta tmp
	jsr select_bank
	ldy #0
	sty op1
	sty op2
	lda #$40
	sta op1+1
	lda #$C0
	sta op2+1
write_loop
	lda #$A0
	jsr sequence
	lda tmp
	jsr select_bank
	lda (op1),y
	sta (op2),y
wait_write
	cmp (op2),y
	bne wait_write
	iny
	bne write_loop
	inc op1+1
	inc op2+1
	bne write_loop
	jsr disable_flash
	plp
	rts
	
_read_flash
	php
	sei
	ldy #0
	lda (sp),y
	jsr select_bank
	ldy #0
	lda #$40
	sty op1
	sta op1+1
	lda #$C0
	sty op2
	sta op2+1
read_loop
	lda (op2),y
	sta (op1),y
	iny
	bne read_loop
	inc op1+1
	inc op2+1
	bne read_loop
	jsr disable_flash
	plp
	rts

_blank_check
	php
	sei
	ldy #0
	lda (sp),y
	jsr select_bank
	ldy #0
	lda #$C0
	sty op2
	sta op2+1
blank_loop
	lda (op2),y
	cmp #$FF
	bne end_blank
	iny
	bne blank_loop
	inc op2+1
	bne blank_loop
end_blank
	sty op2
	jsr disable_flash
	ldx op2
	lda op2+1
	plp
	rts

_verify_flash
	php
	sei
	ldy #0
	lda (sp),y
	jsr select_bank
	ldy #0
	lda #$40
	sty op1
	sta op1+1
	lda #$C0
	sty op2
	sta op2+1
verify_loop
	lda (op2),y
	cmp (op1),y
	bne end_verify
	iny
	bne verify_loop
	inc op1+1
	inc op2+1
	bne verify_loop
end_verify
	sty op2
	jsr disable_flash
	ldx op2
	lda op2+1
	plp
	rts

_read_flash_id
	php
	sei
	lda #$90
	jsr sequence
	lda $C000
	sta tmp
	lda $C001
	sta tmp+1
	lda #$F0
	sta $C000
	jsr disable_flash
	lda tmp
	ldx tmp+1
	plp
	rts

_check_flash_protection
	php
	sei
	ldy #0
	lda (sp),y
	jsr select_sector
	lda #$AA
	sta $C555
	lda #$55
	sta $C2AA
	lda #$90
	sta $C555
	ldx $C002
	lda #$F0
	sta $C000
	jsr disable_flash
	lda #0
	plp
	rts

_read_disk_sector
	jsr $0477	; bascule ram overlay Sedoric
	ldy #3
	lda (sp),y
	sta $C004	; adr buffer MSB
	dey
	lda (sp),y
	sta $C003	; adr buffer LSB
	dey
	lda (sp),y	; secteur linéaire MSB
	tax
	dey
	sty $C000	; disk 0
	lda (sp),y	; secteur linéaire LSB
comp_track
	iny		; track dans Y
	sec
	sbc #18
	bcs comp_track
	dex
	bpl comp_track
	dey
	adc #19
	cmp #10
	bcc comp_sector
	sbc #9
	pha
	tya
	ora #$80
	tay
	pla
comp_sector
	sta $C002	; sector
	sty $C001	; track
	ldx #$80	; lecture secteur
	jsr $CFCD
	ldx $C017
	lda #0
	jmp $0477
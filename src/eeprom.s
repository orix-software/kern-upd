.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65

.define PROGRESS_BAR_CART_COUNT 1950

.include "../libs/usr/arch/include/ch376.inc"

.import _ch376_set_bytes_read
.import _ch376_wait_response
.import _ch376_set_file_name
.import _ch376_file_open

.export _check_flash_protection

.export _read_eeprom_manufacturer

.export _program_sector

.export select_bank,write_kernel,_erase_sector,value_to_display,twilighte_register,sector_to_update,pos_bar,save_twil_registers, _read_eeprom_manufacturer, progress_bar,pos_cputc, restore_twil_registers,counter_display, twilighte_banking_register, current_bank

.importzp ptr1,ptr2,ptr3

.import popax,popa
.importzp tmp1
.import sequence_39sf040

twilighte_banking_register := $343
twilighte_register         := $342

.proc _program_sector
    sei
    sta     counter_display

    jsr     popa
    sta     sector_to_update

    lda     #$00
    sta     pos_cputc

    jsr     popax ; Get filepath
    sta     ptr1
    stx     ptr1+1

    lda     #$00
    sta     posx
    jsr     save_twil_registers
    ; on swappe pour que les banques 8,7,6,5 se retrouvent en bas en id : 1, 2, 3, 4
    lda     #$01
    sta     pos_bar
    lda     #<PROGRESS_BAR_CART_COUNT
    sta     progress_bar
    lda     #>PROGRESS_BAR_CART_COUNT
    sta     progress_bar+1

    lda     sector_to_update ; pour debug FIXME, cela devrait être à 4
    sta     twilighte_banking_register

    lda     twilighte_register
    and     #%11011111
    sta     twilighte_register

    lda     #$01
    sta     current_bank

reset_label:

    ldy     #O_RDONLY

    lda     ptr1
    ldx     ptr1+1
    .byte   $00,XOPEN

    cmp     #$FF
    bne     @start
    cpx     #$FF
    bne     @start

    jmp     @exit
@error:


@exit:
    jsr     restore_twil_registers
    lda     #$01
    cli
    rts


@start:
    ; display progress bar
    lda     #'|'
    sta     $bb80+40
    sta     $bb80+39+40
    sta     $bb80+35+40
    lda     #'%'
    sta     $bb80+38+40
    lda     #'0'
    sta     $bb80+37+40

    lda     counter_display
    bne     @skip_line

    lda     #' '
    ldx     #$00
@L5:
    sta     $bb80+25*40,x
    inx
    cpx     #40*3
    bne     @L5

@skip_line:
    ; Erase
    lda     sector_to_update
    sta     twilighte_banking_register

    lda     #'1'
    sta     value_to_display

    lda     #$00
    sta     ptr3

    lda     #$C0
    sta     ptr3+1

    lda     #$FF
    tay
    jsr     _ch376_set_bytes_read

; This two lines are used to avoid to load a wrong file
    cmp     #CH376_USB_INT_DISK_READ ; do we read something ? No output
    bne     @error ;
    jsr     _erase_sector
    jmp     @start_without_check

@loop:
    cmp     #CH376_USB_INT_DISK_READ
    bne     @finished

@start_without_check:
    lda     #CH376_RD_USB_DATA0
    sta     CH376_COMMAND
    lda     CH376_DATA
    sta     tmp1
    ; Tester si userzp == 0?

    lda     counter_display
    bne     @skip_line2

    lda     current_bank
    clc
    adc     #$30
    sta     $bb80+25*40+21
@skip_line2:

@read_byte:

    lda     CH376_DATA
    pha
    jsr     write_kernel
    pla

    lda     value_to_display
@display:
    ldx     posx

    inx
    stx     posx

    lda     ptr3+1
    bne     @skip_change_bank

    lda     ptr3
    bne     @skip_change_bank

    inc     value_to_display

    lda     #$00
    sta     ptr3

    lda     #$C0
    sta     ptr3+1

    ldx     current_bank
    inx
    stx     current_bank
    cpx     #$05
    bne     @skip_change_bank
    ; end we stop

    jsr     restore_twil_registers
    lda     sector_to_update
    cmp     #$04
    bne     @not_kernel_update
    ; Reset now
    lda     #$07
    jsr     select_bank
    jmp     ($fffa)
@not_kernel_update:
    lda     #$00
    cli
    rts

@skip_change_bank:
    dec     tmp1
    bne     @read_byte

    lda     #CH376_BYTE_RD_GO
    sta     CH376_COMMAND
    jsr     _ch376_wait_response

    ; _ch376_wait_response renvoie 1 en cas d'erreur et le CH376 ne renvoie pas de valeur 0
    ; donc le bne devient un saut inconditionnel!
    bne     @loop
 @finished:

    jsr     restore_twil_registers

    lda     sector_to_update
    cmp     #$04
    bne     @not_kernel_update2
    lda     #$11
    sta     $bb80
    ; Reset now
    lda     #$07
    jsr     select_bank
    jmp     ($fffa)

@not_kernel_update2:
    lda     #$00
    cli
    rts

str_slash:
    .asciiz "/"
posx:
    .res 1
savey:
    .res 1
.endproc



.proc write_kernel
write_loop:
    pha

    lda     #$A0
    jsr     sequence

    lda     sector_to_update ; pour debug FIXME, cela devrait être à 4
    sta     twilighte_banking_register

    lda     current_bank ; Switch to bank
    jsr     select_bank

    lda     counter_display
    bne     @skip_line

    lda     #'#'
    jsr     _cputc_custom

    lda     ptr3
    ldx     ptr3+1
    jsr     _cputhex16_custom

@skip_line:
    pla
    ldy     #$00
    sta     (ptr3),y
wait_write:
    cmp     (ptr3),y
    bne     wait_write
    inc     ptr3
    bne     @S1
    inc     ptr3+1
@S1:
    lda     progress_bar
    bne     @again
    dec     progress_bar+1

@again:
    dec     progress_bar

    lda     progress_bar+1
    bne     @S3

    lda     progress_bar
    bne     @S3

    ldx     pos_bar
    lda     #'='
    sta     $bb80+40,x
    inc     pos_bar

    lda     #<PROGRESS_BAR_CART_COUNT
    sta     progress_bar
    lda     #>PROGRESS_BAR_CART_COUNT
    sta     progress_bar+1

    jsr     inc_progress_bar
    jsr     inc_progress_bar
    jsr     inc_progress_bar
@S3:

    rts
.endproc

.proc inc_progress_bar
    inc     $bb80+37+40
    lda     $bb80+37+40
    cmp     #':'
    bne     @S3
    lda     #'0'
    sta     $bb80+37+40
    lda     $bb80+36+40
    cmp     #' '
    bne     @S4
    lda     #'0'
    sta     $bb80+36+40
@S4:
    inc     $bb80+36+40

@S3:
    rts
.endproc

.proc wait
    ldy     #$02
@S3:
    ldx     #$05
@S1:
    dex
    bne     @S1
    dey
    bne     @S3
    rts
.endproc

_cputc_custom:
    ldx     pos_cputc
    sta     $bb80+25*40+8,x
    inx
    stx     pos_cputc

    cpx     #$05
    bne     @out
    ldx     #$00
    stx     pos_cputc
@out:
    rts

    .import         __hextab

_cputhex16_custom:
    pha                     ; Save low byte
    txa                     ; Get high byte into A
    jsr     _cputhex8_custom       ; Output high byte
    pla                     ; Restore low byte and run into _cputhex8

_cputhex8_custom:
    pha                     ; Save the value
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    tay
    lda     __hextab,y
    jsr     _cputc_custom
    pla
    and     #$0F
    tay
    lda     __hextab,y
    jmp     _cputc_custom

pos_cputc:
    .res 1


.proc save_twil_registers
    lda     VIA2::PRA
    sta     save

    lda     twilighte_banking_register
    sta     twilighte_banking_register_save

    lda     twilighte_register
    sta     twilighte_register_save
    rts
.endproc

.proc restore_twil_registers
    lda     save
    sta     VIA2::PRA

    lda     twilighte_banking_register_save
    sta     twilighte_banking_register

    lda     twilighte_register_save
    sta     twilighte_register
    rts
.endproc

.proc _read_eeprom_manufacturer
    sei
    php
    sta     sector_to_update

    lda     VIA2::PRA
    sta     save

    lda     twilighte_banking_register
    sta     twilighte_banking_register_save

    lda     twilighte_register
    sta     twilighte_register_save

    lda     #$00
    sta     twilighte_banking_register

    lda     VIA2::PRA
    and     #%11111000
    ora     #%00000001
    sta     VIA2::PRA

    lda     twilighte_register
    and     #%11011111
    sta     twilighte_register


	lda     #$90
	jsr		sequence_39sf040

    lda     $C000 ; manufacturer
    sta     tmp

    lda     $C001 ; device ID
    sta     tmp+1

    ; Reset eeprom autoselect
    lda     #$F0
    sta     $C000

    lda     save
    sta     VIA2::PRA
    lda     twilighte_banking_register_save
    sta     twilighte_banking_register
    lda     twilighte_register_save
    sta     twilighte_register

    lda     tmp ; manufacturer
    ldx     tmp+1 ;

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
    sta     VIA2::PRA
    rts
.endproc

.proc sequence
    pha
    lda     sector_to_update
    sta     twilighte_banking_register ; Set to the first 64KB bank
    ; $5555
    lda     #$01   ; set first bank
    jsr     select_bank

    lda     #$AA
    sta     $D555 ; $5555

    lda     #$04
    jsr     select_bank

    lda     #$55
    sta     $EAAA                  ; $2AAA

    lda     #$01
    jsr     select_bank          ;$5555
    pla
    sta     $D555
    rts
.endproc

.proc _erase_sector
    php
    sei

    lda     #$80
    jsr     sequence

    lda     #$AA
    sta     $D555

    lda     #$04
    jsr     select_bank

    lda     #$55
    sta     $EAAA                  ; $2AAA

    lda     #$30
    sta     $C000
wait_erase:
    bit     $C000
    bpl     wait_erase
    plp
    rts
.endproc

; unsigned int check_flash_protection(unsigned char sector)
.proc _check_flash_protection
    php
    sei

    lda     #$AA
    sta     $C555
    lda     #$55
    sta     $C2AA
    lda     #$90
    sta     $C555
    ldx     $C002
    lda     #$F0
    sta     $C000
    ;jsr disable_flash
    lda     #$00
    plp
    rts
.endproc

save:
    .res 1
twilighte_banking_register_save:
    .res 1
twilighte_register_save:
    .res 1
sector_to_update:
    .res 1
value_to_display:
    .res 1
idbank:
    .res 1
current_bank:
    .res 1
counter_display:
    .res 1
progress_bar:
    .res 2
pos_bar:
    .res 1

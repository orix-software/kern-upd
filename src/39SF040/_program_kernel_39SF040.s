.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65

.include "../../libs/usr/arch/include/ch376.inc"

.export _program_kernel_39SF040

.export init_display_for_bank

.import bank_to_update

.import _ch376_set_bytes_read
.import _ch376_wait_response
.import _ch376_set_file_name
.import _ch376_file_open

.import erase_39SF040_bank
.import _erase_sector_39SF040
.import select_bank_39sf040
.import write_byte_39SF040

.import save_twil_registers
.import restore_twil_registers

.import _XWRSTR0_internal
.import _XCRLF_internal

.import progress_bar_run
.import progress_bar_init
.import progress_bar_display_100_percent

.importzp ptr1,ptr3
.importzp tmp1

.import str_programming_shell
.import str_programming_basic
.import str_programming_kernel
.import str_programming_kernel_reserved

.import tab_str_low
.import tab_str_high

twilighte_banking_register := $343
twilighte_register         := $342

.proc _program_kernel_39SF040
    sei

    sta     ptr1
    stx     ptr1+1

    lda     #$05
    sta     bank_to_update

    jsr     save_twil_registers

    ; BANK0_ROMRAM : A14
    ; BANK1_ROMRAM : A15
    ; BANK2_ROMRAM : A16
    ; BANK3_ROMRAM : A17 ; 0 if twilighte bank_register = 0
    ; BANK4_ROMRAM : A18 ; 0 if twilighte bank_register = 0

    lda     #$00
    sta     twilighte_banking_register ; Set

    lda     twilighte_register
    and     #%11011111
    sta     twilighte_register

    jsr     init_display_for_bank

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

    ; Erase 4 sectors
    lda     bank_to_update
    jsr     erase_39SF040_bank

    ; Erase

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
    ;
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

@read_byte:
    lda     CH376_DATA
    pha
    jsr     write_byte_39SF040
    pla

@display:
    jsr     progress_bar_run

    lda     ptr3+1
    bne     @skip_change_bank

    lda     ptr3
    bne     @skip_change_bank


    lda     #$00
    sta     ptr3

    lda     #$C0
    sta     ptr3+1

    jsr     progress_bar_display_100_percent

    inc     bank_to_update

    ; Erase 4 sectors
    lda     bank_to_update
    jsr     erase_39SF040_bank
    jsr     init_display_for_bank
    jmp     @skip_change_bank


@finished_ok:
    jsr     restore_twil_registers


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

@not_kernel_update2:
    jsr     progress_bar_display_100_percent
    ; Rebooting
    lda     #$07
    jsr     select_bank_39sf040
    jmp     ($fffa)

str_slash:
    .asciiz "/"

savey:
    .res 1
.endproc

.proc init_display_for_bank
    lda     bank_to_update
    sec
    sbc     #05
    tax

    lda     tab_str_low,x
    ldy     tab_str_high,x

    jsr     _XWRSTR0_internal
    jsr     _XCRLF_internal

    jsr     progress_bar_init
    rts
.endproc


.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65

.export _program_sector_29F040

.import popax,popa

.import sector_to_update
.import current_bank
.import bank_to_update

.import init_display_for_bank

.import save_twil_registers
.import restore_twil_registers

.import write_byte_29F040
.import _erase_sector_29F040

.import _ch376_set_bytes_read
.import _ch376_wait_response
.import _ch376_set_file_name
.import _ch376_file_open

.import progress_bar_run
.import progress_bar_init
.import progress_bar_display_100_percent

.import _XWRSTR0_internal
.import _XCRLF_internal

.importzp tmp1
.import select_bank

.import str_programming_shell
.import str_programming_basic
.import str_programming_kernel
.import str_programming_kernel_reserved

.import tab_str_low
.import tab_str_high

.include "../../libs/usr/arch/include/ch376.inc"

.importzp ptr1,ptr3

twilighte_banking_register := $343
twilighte_register         := $342

.proc _program_sector_29F040
    sei
    sta     sector_to_update

    jsr     popax ; Get filepath
    sta     ptr1
    stx     ptr1+1

    lda     #$01
    sta     current_bank

    jsr     save_twil_registers
    ; on swappe pour que les banques 8,7,6,5 se retrouvent en bas en id : 1, 2, 3, 4

    lda     sector_to_update
    cmp     #$04
    bne     @not_kernel_update3

    ; bank_to_update

    lda     current_bank
    clc
    adc     #$04
    sta     bank_to_update





    jsr     init_display_for_bank

    jmp     @start_config

@not_kernel_update3:
    jsr     init_display_for_bank_29F040_normal_sector

@start_config:
    lda     sector_to_update ; pour debug FIXME, cela devrait être à 4
    sta     twilighte_banking_register

    lda     twilighte_register
    and     #%11011111
    sta     twilighte_register

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

@skip_line:
    ; Erase
    lda     sector_to_update
    sta     twilighte_banking_register

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
    jsr     _erase_sector_29F040
    jmp     @start_without_check

@loop:
    cmp     #CH376_USB_INT_DISK_READ
    bne     @finished

@start_without_check:
    lda     #CH376_RD_USB_DATA0
    sta     CH376_COMMAND
    lda     CH376_DATA
    sta     tmp1

@read_byte:
    jsr     progress_bar_run
    lda     CH376_DATA
    pha
    jsr     write_byte_29F040
    pla

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

    ldx     current_bank
    inx
    stx     current_bank

    lda     sector_to_update
    cmp     #$04
    beq     @displays_kernel_set

    jsr     init_display_for_bank_29F040_normal_sector
    jmp     @compare_bank

@displays_kernel_set:
    inc     bank_to_update
    jsr     init_display_for_bank

@compare_bank:
    lda     current_bank
    cmp     #$05
    bne     @skip_change_bank
    ; end we stop

    jsr     progress_bar_display_100_percent

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
    jsr     progress_bar_display_100_percent
    lda     sector_to_update
    cmp     #$04
    bne     @not_kernel_update2

    ; Reset now
    lda     #$07
    jsr     select_bank
    jmp     ($fffa)

@not_kernel_update2:
    lda     #$00
    sta     SCRX
    lda     #$00
    cli
    rts

str_slash:
    .asciiz "/"
.endproc

.proc init_display_for_bank_29F040_normal_sector

    lda     #<str_programming_bank
    ldy     #>str_programming_bank

    jsr     _XWRSTR0_internal
    jsr     _XCRLF_internal

    jsr     progress_bar_init
    rts
str_programming_bank:
    .asciiz "Programming bank ..."
.endproc

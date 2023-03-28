.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65

.include "../../libs/usr/arch/include/ch376.inc"

.export _program_kernel_39SF040

.import bank_to_update
.import erase_39SF040_bank


.import _XWRSTR0_internal
.import _erase_sector_39SF040
.import _ch376_set_bytes_read
.import _ch376_wait_response
.import _ch376_set_file_name
.import _ch376_file_open
.import write_byte_39SF040
.import _check_flash_protection
.import value_to_display
.import pos_bar
.import save_twil_registers
.import progress_bar
.import pos_cputc
.import restore_twil_registers
.import counter_display
.import restore_twil_registers
.import _XCRLF_internal
.import progress_bar_run
.import progress_bar_init
.import progress_bar_display_100_percent
.importzp ptr1,ptr3

.importzp tmp1

twilighte_banking_register := $343
twilighte_register         := $342

.proc _program_kernel_39SF040
    sei

    sta     ptr1
    stx     ptr1+1

    lda     #$05
    sta     bank_to_update

    lda     #$00
    sta     pos_cputc

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

    inc     value_to_display

    lda     #$00
    sta     ptr3

    lda     #$C0
    sta     ptr3+1

    lda     #$00
    sta     pos_cputc

    jsr     progress_bar_display_100_percent



;    jsr     _XCRLF_internal

    inc     bank_to_update
    lda     bank_to_update
    cmp     #$09
    beq     @finished_ok
    jsr     init_display_for_bank
    jmp     @skip_change_bank


@finished_ok:
    jsr     restore_twil_registers

@not_kernel_update:
    jsr     _XCRLF_internal
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
    lda     #$00
    cli
    ;brk XCRLF
    rts

init_display_for_bank:
    lda     bank_to_update
    sec
    sbc     #05
    tax
    lda     #'A'
    sta     $bb80,x

    lda     tab_str_low,x
    ldy     tab_str_high,x

    jsr     _XWRSTR0_internal
    jsr     _XCRLF_internal

    jsr     progress_bar_init
    rts

str_slash:
    .asciiz "/"



savey:
    .res 1
str_programming_shell:
    .asciiz "Programming shell ..."
str_programming_basic:
    .asciiz "Programming Basic ..."
str_programming_kernel:
    .asciiz "Programming Kernel ..."
str_programming_kernel_reserved:
    .asciiz "Programming Kernel reserved..."

tab_str_low:
    .byt <str_programming_shell
    .byt <str_programming_basic
    .byt <str_programming_kernel
    .byt <str_programming_kernel_reserved

tab_str_high:
    .byt >str_programming_shell
    .byt >str_programming_basic
    .byt >str_programming_kernel
    .byt >str_programming_kernel_reserved
.endproc


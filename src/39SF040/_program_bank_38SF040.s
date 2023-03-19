.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65

.include "../../libs/usr/arch/include/ch376.inc"

.export _program_bank_38SF040

.export bank_to_update

.import _erase_sector_39SF040
.import _ch376_set_bytes_read
.import _ch376_wait_response
.import _ch376_set_file_name
.import _ch376_file_open
.import write_byte_39SF040
.import _check_flash_protection
.import value_to_display
.import twilighte_register
.import pos_bar
.import save_twil_registers
.import progress_bar
.import pos_cputc
.import restore_twil_registers
.import counter_display
.import twilighte_banking_register


.importzp ptr1,ptr2,ptr3

.import popax,popa
.importzp tmp1

.proc _program_bank_38SF040
    sei

    sta     bank_to_update

    lda     #$00
    sta     pos_cputc

    jsr     popax ; Get file
    sta     ptr1
    stx     ptr1+1

    jsr     progress_bar_init

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

@skip_line:
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

@skip_line2:

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

    jsr     restore_twil_registers

@not_kernel_update:
    jsr     progress_bar_display_100_percent
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
    .byte $00,XCRLF
    rts

str_slash:
    .asciiz "/"

savey:
    .res 1

.endproc

.proc progress_bar_run

    lda     progress_bar_counter+1
    bne     @dec

    lda     progress_bar_counter
    bne     @dec

    lda     number_of_values_needed_for_inc_progress_bar
    sta     progress_bar_counter

    lda     number_of_values_needed_for_inc_progress_bar+1
    sta     progress_bar_counter+1

    ldy     posx_progress_bar
    lda     #'='
    sta     (ADSCR),y

    iny
    lda     #'>'
    sta     (ADSCR),y

    lda     progress_bar_current_percentage
    clc
    adc     progress_bar_inc_value
    sta     progress_bar_current_percentage

    ldx     #$FF
@L2:
    inx
    sec
    sbc     #10
    bpl     @L2
    clc
    adc     #10
    sta     progress_bar_tmp

    txa
    clc
    adc     #$30

    iny
    sta     (ADSCR),y

    iny
    lda     progress_bar_tmp
    clc
    adc     #$30
    sta     (ADSCR),y

    lda     #'%'
    iny
    sta     (ADSCR),y

@skip:
    inc     posx_progress_bar


    rts

@dec:
    lda     progress_bar_counter
    bne     @out
    dec     progress_bar_counter+1

@out:
    dec     progress_bar_counter

    rts

wait:
    ; Wait
    ldx     #$00
    ldy     #$80
@L1:
    dex
    bne     @L1
    dey
    bne     @L1
    rts
.endproc

.proc progress_bar_display_100_percent
    ldy     posx_progress_bar
    lda     #'|'
    sta     (ADSCR),y
    iny
    lda     #'1'
    sta     (ADSCR),y

    iny
    lda     #'0'
    sta     (ADSCR),y

    iny
    lda     #'0'
    sta     (ADSCR),y

    iny
    lda     #'%'
    sta     (ADSCR),y
    iny
    sty     SCRX

    BRK_TELEMON(XCRLF)

    rts
.endproc


.proc progress_bar_init
    lda     #$01
    sta     posx_progress_bar

    ldy     #$00
    lda     #'|'
    sta     (ADSCR),y

    iny
    lda     #'0'
    sta     (ADSCR),y

    iny
    lda     #'0'
    sta     (ADSCR),y

    iny
    lda     #'%'
    sta     (ADSCR),y


    lda     #<512
    sta     number_of_values_needed_for_inc_progress_bar
    sta     progress_bar_counter
    lda     #>512
    sta     number_of_values_needed_for_inc_progress_bar+1
    sta     progress_bar_counter+1

    lda     #$03
    sta     progress_bar_inc_value

    lda     #$00
    sta     progress_bar_current_percentage

    lda     #<16384
    lda     #>16384

    rts



.endproc


.proc erase_39SF040_bank
    ; A contains the id bank to erase
    ; It erase 4 sectors
    ; Remove 1

    sec
    sbc     #$01
    ; and multiply by 4
    asl
    asl


    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    clc
    adc     #$01
    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    clc
    adc     #$01
    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    clc
    adc     #$01
    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    rts

.endproc

posx_progress_bar:
    .res 1

number_of_values_needed_for_inc_progress_bar:
    .res 2
progress_bar_counter:
    .res 2

progress_bar_percent_decimal:
    .res 4

progress_bar_current_percentage:
    .res 1

progress_bar_inc_value:
    .res 1

progress_bar_tmp:
    .res 1

bank_to_update:
    .byt 1


.include "telestrat.inc"
.include "fcntl.inc"              ; from cc65
.include "errno.inc"              ; from cc65
.include "cpu.mac"                ; from cc65


.export _program_sector_29F040

.import progress_bar
.import counter_display
.import sector_to_update
.import pos_cputc
.import posx
.import pos_bar
.import sector_to_update
.import current_bank
.import restore_twil_registers
.import popax,popa
.import save_twil_registers
.import value_to_display
.import restore_twil_registers


.import write_byte_29F040
.import _erase_sector_29F040

.import _ch376_set_bytes_read
.import _ch376_wait_response
.import _ch376_set_file_name
.import _ch376_file_open

.importzp tmp1
.import select_bank

.include "../common/progress_bar/progress_bar.inc"
.include "../../libs/usr/arch/include/ch376.inc"

.importzp ptr1,ptr3

twilighte_banking_register := $343
twilighte_register         := $342

.proc _program_sector_29F040
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
    jsr     write_byte_29F040
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

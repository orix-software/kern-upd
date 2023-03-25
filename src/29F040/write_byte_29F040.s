.export write_byte_29F040

.import inc_progress_bar
.import sequence_29F040
.import current_bank
.import sector_to_update
.import select_bank
.import counter_display
.import progress_bar
.import pos_bar
.importzp ptr3
.import _cputc_custom
.import _cputhex16_custom

.include "../common/progress_bar/progress_bar.inc"

twilighte_banking_register := $343
twilighte_register         := $342

.proc write_byte_29F040
write_loop:
    pha

    lda     #$A0
    jsr     sequence_29F040

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

.export write_byte_29F040

;.import inc_progress_bar
.import sequence_29F040
.import current_bank
.import sector_to_update
.import select_bank
.import counter_display
;.import progress_bar
;.import pos_bar

.importzp ptr3

.import _cputc_custom
.import _cputhex16_custom

.include "../common/progress_bar/progress_bar.inc"

twilighte_banking_register := $343
twilighte_register         := $342

.proc write_byte_29F040
    pha

    lda     #$A0
    jsr     sequence_29F040

    lda     sector_to_update ; pour debug FIXME, cela devrait être à 4
    sta     twilighte_banking_register

    lda     current_bank ; Switch to bank
    jsr     select_bank

    lda     counter_display
    bne     @skip_line


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
    rts
.endproc

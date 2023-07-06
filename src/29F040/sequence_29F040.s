.export sequence_29F040

.import sector_to_update
.import select_bank

twilighte_banking_register := $343
twilighte_register         := $342

.proc sequence_29F040
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

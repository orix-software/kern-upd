
.export sequence_39sf040


.import sector_to_update, twilighte_banking_register, select_bank

.proc sequence_39sf040

; 5555H AAH 2AAAH 55H 5555H 90H
    pha
    ;lda     sector_to_update
    ;sta     twilighte_banking_register ; Set to the first 64KB bank
    ; $5555
    lda     #$02   ; set first bank
    jsr     select_bank

    lda     #$AA
    sta     $D555                  ; $5555

    lda     #$01
    jsr     select_bank

    lda     #$55
    sta     $EAAA                  ; $2AAA

    lda     #$02
    jsr     select_bank            ; $5555
    pla
    sta     $D555
    rts
.endproc

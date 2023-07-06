
.export sequence_39sf040

.import twilighte_banking_register, select_bank

.proc sequence_39sf040

    ; 5555H AAH 2AAAH 55H 5555H 90H
    pha

    ; $5555
    lda     #$02         ; set 2nd bank
    jsr     select_bank

    lda     #$AA
    sta     $D555        ; $5555

    lda     #$01
    jsr     select_bank

    lda     #$55
    sta     $EAAA         ; $2AAA

    lda     #$02
    jsr     select_bank   ; $5555
    pla
    sta     $D555
    rts
.endproc

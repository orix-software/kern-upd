.export _erase_sector_29F040

.import select_bank
.import sequence_29F040

.proc _erase_sector_29F040
    php
    sei

    lda     #$80
    jsr     sequence_29F040

    lda     #$AA
    sta     $D555

    lda     #$04
    jsr     select_bank

    lda     #$55
    sta     $EAAA                  ; $2AAA

    lda     #$30
    sta     $C000

wait_erase:
    bit     $C000
    bpl     wait_erase
    plp
    rts
.endproc

.export _erase_sector_39SF040

.import sequence_39sf040
.import twilighte_banking_register
.import select_bank_39sf040

 ; SAX for Sector-Erase; uses AMS-A12 address lines
.proc _erase_sector_39SF040
    ; A : 4K sector id
    ; X : the bank to update
    php
    sei
    sta     tmp ; Store the sector to erase

    ; reset to addr_tab
    tax
    lda     sector_39SF040_adress_high,x
    sta     __modify1+2
    sta     __modify2+2

    ; set sector address
    lda     #$80
    jsr     sequence_39sf040

    lda     #$AA
    sta     $D555

    lda     #$01
    jsr     select_bank_39sf040

    lda     #$55
    sta     $EAAA                  ; $2AAA

@no_inc_twilighte_banking_register:
    ldx     tmp
    lda     sector_39SF040_bank,x
    jsr     select_bank_39sf040

    lda     sector_39SF040_banking_register,x
    sta     twilighte_banking_register

@not_next_bank:
    lda     #$30

__modify1:
    sta     $C000
wait_erase:
__modify2:
    bit     $C000
    bpl     wait_erase

    plp
    rts

tmp:
    .byte 0

.endproc

.include "sector_table.s"

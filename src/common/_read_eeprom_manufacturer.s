.export _read_eeprom_manufacturer

.include "telestrat.inc"

twilighte_banking_register := $343
twilighte_register         := $342

.import save
.import twilighte_banking_register_save
.import twilighte_register_save
.import sequence_39sf040
.import sector_to_update

.proc _read_eeprom_manufacturer
    sei
    php
    sta     sector_to_update

    lda     VIA2::PRA
    sta     save

    lda     twilighte_banking_register
    sta     twilighte_banking_register_save

    lda     twilighte_register
    sta     twilighte_register_save

    lda     #$00
    sta     twilighte_banking_register

    lda     VIA2::PRA
    and     #%11111000
    ora     #%00000001
    sta     VIA2::PRA

    lda     twilighte_register
    and     #%11011111
    sta     twilighte_register


	lda     #$90
	jsr		sequence_39sf040

    lda     $C000 ; manufacturer
    sta     tmp

    lda     $C001 ; device ID
    sta     tmp+1

    ; Reset eeprom autoselect
    lda     #$F0
    sta     $C000

    lda     save
    sta     VIA2::PRA
    lda     twilighte_banking_register_save
    sta     twilighte_banking_register
    lda     twilighte_register_save
    sta     twilighte_register

    lda     tmp ; manufacturer
    ldx     tmp+1 ;

    plp
    cli

    rts
tmp:
    .res 2

.endproc

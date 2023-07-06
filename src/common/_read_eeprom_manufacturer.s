.export _read_eeprom_manufacturer

.include "telestrat.inc"

twilighte_banking_register := $343
twilighte_register         := $342

.import save
.import twilighte_banking_register_save
.import twilighte_register_save
.import sequence_39sf040
.import sector_to_update

.import save_twil_registers
.import restore_twil_registers

.proc _read_eeprom_manufacturer
    sei

    lda     sector_to_update
    sta     sector_to_update

    jsr     save_twil_registers

    lda     twilighte_register
    and     #%11011111
    sta     twilighte_register

    lda     #$90
    jsr     sequence_39sf040

    ldy     $C000 ; manufacturer
    ldx     $C001 ; device ID


    ; Reset eeprom autoselect
    lda     #$F0
    sta     $C000

    jsr     restore_twil_registers

    tya

    cli

    rts
tmp:
    .res 2

.endproc

.export save_twil_registers

.include "telestrat.inc"

twilighte_banking_register := $343
twilighte_register         := $342

.import save
.import twilighte_banking_register_save
.import twilighte_register_save

.proc save_twil_registers
    lda     VIA2::PRA
    sta     save

    lda     twilighte_banking_register
    sta     twilighte_banking_register_save

    lda     twilighte_register
    sta     twilighte_register_save
    rts
.endproc

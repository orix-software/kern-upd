.export restore_twil_registers

.include "telestrat.inc"

twilighte_banking_register := $343
twilighte_register         := $342

.export save
.export twilighte_banking_register_save
.export twilighte_register_save

.proc restore_twil_registers
    lda     save
    sta     VIA2::PRA

    lda     twilighte_banking_register_save
    sta     twilighte_banking_register

    lda     twilighte_register_save
    sta     twilighte_register
    rts
.endproc

save:
    .res 1
twilighte_banking_register_save:
    .res 1
twilighte_register_save:
    .res 1


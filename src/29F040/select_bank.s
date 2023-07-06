.include "telestrat.inc"

.export select_bank

.proc select_bank
    sta     VIA2::PRA
    rts
.endproc

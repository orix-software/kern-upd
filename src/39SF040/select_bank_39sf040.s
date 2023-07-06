.include "telestrat.inc"

.export select_bank_39sf040

.proc select_bank_39sf040
    sta     VIA2::PRA
    rts
.endproc

.include "telestrat.inc"

.export _xexec

.importzp tmp1

.proc _xexec
    stx tmp1
    ldy tmp1

    BRK_TELEMON $63
    rts
.endproc
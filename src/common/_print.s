.include "telestrat.inc"

.export _print

.proc _print
    pha
    txa
    tay
    pla
    BRK_TELEMON XWSTR0
    rts
.endproc


.include "telestrat.inc"

.export _println

.proc _println
    pha
    txa
    tay
    pla
    BRK_TELEMON XWSTR0
    BRK_TELEMON XCRLF
    rts
.endproc

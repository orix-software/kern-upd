.include "telestrat.inc"

.export _crlf

.proc _crlf
    BRK_TELEMON XCRLF
    rts
.endproc

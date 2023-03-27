.export _XWRSTR0_internal

.include "telestrat.inc"

.proc _XWRSTR0_internal
    sta     str+1
    sty     str+2

    ldy     #$00
str:
    lda     $dead,y
    beq     @out
    sta     (ADSCR),y
    iny
    bne     str
@out:
    rts
.endproc


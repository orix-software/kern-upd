.export _XWRSTR0_internal

.include "telestrat.inc"

.proc _XWRSTR0_internal
    sta     str+1
    sty     str+2

    ldy     #$00
; $822
loop:


str:
    lda     $dead,y
    beq     @out
    cmp     #' '-1
    bcc     @skip_char
    cmp     #'z'+1
    bcs     @skip_char
    sta     (ADSCR),y
@skip_char:

    iny
    bne     loop
@out:
    rts
.endproc


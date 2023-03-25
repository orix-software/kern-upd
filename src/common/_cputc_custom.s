.export _cputc_custom

.export pos_cputc

.proc _cputc_custom
    ldx     pos_cputc
    sta     $bb80+25*40+8,x
    inx
    stx     pos_cputc

    cpx     #$05
    bne     @out
    ldx     #$00
    stx     pos_cputc
@out:
    rts

.endproc

pos_cputc:
    .res 1

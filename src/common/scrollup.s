.export scrollup

.proc scrollup
    ldx     #$00
@loop_scroll:
    lda     $bb80+40,x
    sta     $bb80,x
    inx
    cpx     #240
    bne     @loop_scroll

    ldx     #$00
@loop_scroll2:
    lda     $bb80+40+40*6,x
    sta     $bb80+40*6,x
    inx
    cpx     #240
    bne     @loop_scroll2

    ldx     #$00
@loop_scroll3:
    lda     $bb80+40+40*12,x
    sta     $bb80+40*12,x
    inx
    cpx     #240
    bne     @loop_scroll3

    ldx     #$00
@loop_scroll4:
    lda     $bb80+40+40*18,x
    sta     $bb80+40*18,x
    inx
    cpx     #240
    bne     @loop_scroll4

    ldx     #$00
@loop_scroll5:
    lda     $bb80+40+40*24,x
    sta     $bb80+40*24,x
    inx
    cpx     #120
    bne     @loop_scroll5


    rts
.endproc

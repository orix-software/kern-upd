.export inc_progress_bar

.import  scrollup

.proc inc_progress_bar
    inc     $bb80+37+40
    lda     $bb80+37+40
    cmp     #':'
    bne     @S3
    lda     #'0'
    sta     $bb80+37+40
    lda     $bb80+36+40
    cmp     #' '
    bne     @S4
    lda     #'0'
    sta     $bb80+36+40
@S4:
    inc     $bb80+36+40
@S3:
    rts
.endproc

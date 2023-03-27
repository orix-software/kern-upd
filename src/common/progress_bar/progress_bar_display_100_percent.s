.include "telestrat.inc"

.export progress_bar_display_100_percent

.import posx_progress_bar
.import _XCRLF_internal

.proc progress_bar_display_100_percent
    ldy     posx_progress_bar
    lda     #'|'
    sta     (ADSCR),y
    iny
    lda     #'1'
    sta     (ADSCR),y

    iny
    lda     #'0'
    sta     (ADSCR),y

    iny
    lda     #'0'
    sta     (ADSCR),y

    iny
    lda     #'%'
    sta     (ADSCR),y
    iny
    sty     SCRX

    jsr     _XCRLF_internal

    rts
.endproc

.include "telestrat.inc"

.export _XCRLF_internal

.import scrollup

.proc _XCRLF_internal
    lda     SCRY
    cmp     #26
    bne     @no_scroll

    jsr     scrollup
    jmp     @nocompute_SCRY

@no_scroll:
    inc     SCRY
    lda     ADSCR
    clc
    adc     #$28
    bcc     @skip_inc
    inc     ADSCR+1
@skip_inc:
    sta     ADSCR
@nocompute_SCRY:
    rts
.endproc

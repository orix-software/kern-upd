.export progress_bar_run

.include "telestrat.inc"

.import progress_bar_counter
.import progress_bar_current_percentage
.import progress_bar_inc_value
.import number_of_values_needed_for_inc_progress_bar
.import posx_progress_bar
.import progress_bar_tmp

.proc progress_bar_run

    lda     progress_bar_counter+1
    bne     @dec

    lda     progress_bar_counter
    bne     @dec

    lda     number_of_values_needed_for_inc_progress_bar
    sta     progress_bar_counter

    lda     number_of_values_needed_for_inc_progress_bar+1
    sta     progress_bar_counter+1

    ldy     posx_progress_bar
    lda     #'='
    sta     (ADSCR),y

    iny
    lda     #'>'
    sta     (ADSCR),y

    lda     progress_bar_current_percentage
    clc
    adc     progress_bar_inc_value
    sta     progress_bar_current_percentage

    ldx     #$FF
@L2:
    inx
    sec
    sbc     #10
    bpl     @L2
    clc
    adc     #10
    sta     progress_bar_tmp

    txa
    clc
    adc     #$30

    iny
    sta     (ADSCR),y

    iny
    lda     progress_bar_tmp
    clc
    adc     #$30
    sta     (ADSCR),y

    lda     #'%'
    iny
    sta     (ADSCR),y

@skip:
    inc     posx_progress_bar
    rts

@dec:
    lda     progress_bar_counter
    bne     @out
    dec     progress_bar_counter+1

@out:
    dec     progress_bar_counter

    rts
.endproc

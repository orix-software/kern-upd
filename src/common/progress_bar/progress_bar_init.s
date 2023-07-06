.export progress_bar_init

.include "telestrat.inc"

.import progress_bar_counter
.import progress_bar_current_percentage
.import progress_bar_inc_value
.import number_of_values_needed_for_inc_progress_bar
.import posx_progress_bar

.proc progress_bar_init
    lda     #$01
    sta     posx_progress_bar

    ldy     #$00
    lda     #'|'
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

    lda     #<1024
    sta     number_of_values_needed_for_inc_progress_bar
    sta     progress_bar_counter
    lda     #>1024
    sta     number_of_values_needed_for_inc_progress_bar+1
    sta     progress_bar_counter+1

    lda     #$03
    sta     progress_bar_inc_value

    lda     #$00
    sta     progress_bar_current_percentage

    rts

.endproc

.export _displays_eeprom

.proc _displays_eeprom
    sei
;    lda     $342
 ;   and     #%00000000
  ;  sta     $342

    ; Device ID
    lda     #$11
    sta     $bb80

    lda     #$AA
    sta     $C555

    lda     #$55
    sta     $C2AA

    lda     #$90
    sta     $C555
    
    lda     #$01
    sta     $C000

    ; and
   ; lda     $342
;    ora     #%10000000
    ;sta     $342
    
    lda     #<str
    ldy     #>str
    cli
    rts
str:
    .res 100    
.endproc 
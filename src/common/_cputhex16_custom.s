    .export         _cputhex16_custom

    .import         __hextab
    .import         _cputc_custom

.proc _cputhex16_custom
    pha                     ; Save low byte
    txa                     ; Get high byte into A
    jsr     _cputhex8_custom       ; Output high byte
    pla                     ; Restore low byte and run into _cputhex8

_cputhex8_custom:
    pha                     ; Save the value
    lsr     a
    lsr     a
    lsr     a
    lsr     a
    tay
    lda     __hextab,y
    jsr     _cputc_custom
    pla
    and     #$0F
    tay
    lda     __hextab,y
    jmp     _cputc_custom
.endproc

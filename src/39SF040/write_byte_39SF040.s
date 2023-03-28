.include "telestrat.inc"

.export write_byte_39SF040

.import select_bank_39sf040
.import bank_to_update
.import sequence_39sf040
.import sector_39SF040_banking_register
.import sector_39SF040_bank
.import sector_39SF040_adress_high
.import bank_to_update

.importzp ptr3

twilighte_banking_register := $343
twilighte_register         := $342

.proc write_byte_39SF040
write_loop:
    pha

    lda     #$A0
    jsr     sequence_39sf040

    lda     bank_to_update
    sec
    sbc     #$01
    ; and multiply by 4
    asl
    asl
    tax
    lda     sector_39SF040_banking_register,x
    sta     twilighte_banking_register

    lda     sector_39SF040_bank,x
    jsr     select_bank_39sf040


    pla
    ldy     #$00
    sta     (ptr3),y
wait_write:
    ; ldx     ptr3
    ; stx     $6000
    ; ldx     ptr3+1
    ; stx     $6001
    ; sta     $6002
    cmp     (ptr3),y
    bne     wait_write
skip_debug:
    inc     ptr3
    bne     @S1
    inc     ptr3+1
@S1:

@S3:

    rts

.endproc

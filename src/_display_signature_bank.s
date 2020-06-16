.importzp ptr1,ptr2
.import popa

.export  _display_signature_bank

.define MAX_SIGNATURE_LENGTH 100

; unsigned char * display_signature_bank(unsigned char sector,unsigned char bank)

.proc _display_signature_bank
    sei
    ldx     $321
    stx     save_bank
    and     #%00000111
    sta     $321

    lda     $343
    sta     save_twil_banking_register

    jsr     popa ; sector
    sta     $343


    lda     #<$FFF8
    sta     ptr1
    lda     #>$FFF8
    sta     ptr1+1

    ldy     #$00

    lda     (ptr1),y
    sta     ptr2
    iny
    lda     (ptr1),y
    sta     ptr2+1


    ldy     #$00
@L1:    
    lda     (ptr2),y
    beq     @out
    cmp     #$0A ; skip return line
    beq     @out    
    cmp     #$0D
    beq     @out
    sta     bank_signature,y
   ; sta     $bb80,y
    iny
    cpy     #MAX_SIGNATURE_LENGTH
    bne     @L1

@out:
    lda     #$00
    sta     bank_signature,y

    ldx     save_twil_banking_register
    stx     $343


    ldx     save_bank
    stx     $321
    cli 
    lda     #<bank_signature
    ldx     #>bank_signature
    rts
save_twil_banking_register:
    .res 1
save_bank:
    .res 1    
bank_signature:    
    .res MAX_SIGNATURE_LENGTH  
.endproc


.import select_bank

.export _erase_sector_39SF040

.import sequence_39sf040

.import twilighte_banking_register
 ; SAX for Sector-Erase; uses AMS-A12 address lines
.proc _erase_sector_39SF040
    ; A : 4K sector id
    php
    sei
    ; clc
    ; adc     __modify1+2
    ; sta     __modify1+2
    ; sta     __modify2+2

    pha

    ; set sector address
    lda     #$80
    jsr     sequence_39sf040

    lda     #$AA
    sta     $D555

    lda     #$01
    jsr     select_bank

    lda     #$55
    sta     $EAAA                  ; $2AAA

    pla
    ldx     #$FF
@L2:
    inx
    ; 0 => 0
    ; 1 => 1
    ; 2 => 2
    ; 3 => 3
    ; 4 => 0
    sec
    sbc     #$04
    bpl     @L2

    adc     #$04
    cmp     #$03
    beq     @skip_add
    clc
    adc     __modify1+2
    sta     __modify1+2
    sta     __modify2+2

    ;jmp     @select_bank_for_address_line

@skip_add:
    ;bne     @not_next_bank


    txa
    clc
    adc     #$01
    jsr     select_bank

    ; Change twilighte register bank

    txa
    ldx     #$FF
@L3:
    inx
    sec
    sbc     #16
    bpl     @L2
    stx     twilighte_banking_register



@not_next_bank:
    lda     #$30

    ; BANK0_ROMRAM : A14
    ; BANK1_ROMRAM : A15
    ; BANK2_ROMRAM : A16
    ; BANK3_ROMRAM : A17 ; 0 if twilighte bank_register = 0
    ; BANK4_ROMRAM : A18 ; 0 if twilighte bank_register = 0

    ; Twilighte banking register | $321 value | BANK0_ROMRAM BANK1_ROMRAM BANK2_ROMRAM BANK3_ROMRAM BANK4_ROMRAM
    ; 0                          |    1       | 0            0            0            0            0
    ; 0                          |    2       | 1            0            0            0            0
    ; 0                          |    3       | 0            1            0            0            0
    ; 0                          |    4       | 1            1            0            0            0

    ; sector ID | Virt addr | Hex   | $321 value | BANK1_ROMRAM/A15 BANK0_ROMRAM/A14 A13  A12  A11 A10 A09 A08 A07 A06 A05 A04 A03 A02 A01 A00
    ;           |           |       |              0                4000             2000 1000 800 400 200 100 80  40  20  10  8   4   2   1
    ; 0         | $C000     |     0 |   1          0                0                0    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 1         | $E000     | $2000 |   1          0                0                1    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 2         | $F000     | $3000 |   1          0                0                1    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 3         | $C000     | $4000 |   2          0                1                1    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 4         | $E000     | XXXXX |   2          0                0                0    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 5         | $F000     | $XXXX |   2          0                0                1    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 6         | $C000     | $XXXX |   3          0                0                1    0    0   0   0   0   0   0   0   0   0   0   0   0
    ; 7         | $XXXX     | $XXXX |   X          0                1                1    0    0   0   0   0   0   0   0   0   0   0   0   0



__modify1:
    sta     $C000
wait_erase:
__modify2:
    bit     $C000
    bpl     wait_erase

    ; reset to $c000
    lda     #>$C000
    sta     __modify1+2
    sta     __modify2+2

    plp
    rts
.endproc
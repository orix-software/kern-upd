.export erase_39SF040_bank

.import _erase_sector_39SF040
.import bank_to_update

.proc erase_39SF040_bank
    ; A contains the id bank to erase
    ; It erase 4 sectors
    ; Remove 1

    sec
    sbc     #$01
    ; and multiply by 4
    asl
    asl


    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    clc
    adc     #$01
    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    clc
    adc     #$01
    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    clc
    adc     #$01
    pha
    ldx     bank_to_update
    jsr     _erase_sector_39SF040
    pla

    rts

.endproc

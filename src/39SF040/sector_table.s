.export sector_39SF040_banking_register
.export sector_39SF040_bank
.export sector_39SF040_adress_high

; This file is the sector table (mapping between bank, twilighte banking register and address)

    ; bank command    | sector ID   | Virt addr | Hex   | Twilighte banking register |$321 value | BANK4_ROMRAM | BANK3_ROMRAM | BANK2_ROMRAM | BANK1_ROMRAM | BANK0_ROMRAM | A13 | A12
    ; 1               |   0         | $C000     |     0 | 0                          |   1       |              | 0            | 0            |     0        |       0      |  0  |   0
    ; 1               |   1         | $D000     | $1000 | 0                          |   1       |              | 0            | 0                  0                0         0      1
    ; 1               |   2         | $E000     | $2000 | 0                          |   1       |              | 0            | 0                  0                0         1      0
    ; 2               |   3         | $F000     | $3000 | 0                          |   2       |              | 0            | 0                  0                0         1      1
    ; 2               |   4         | $E000     | XXXXX | 0                          |   2       |              | 0            | 0                  1                0                0
    ; 2               |   5         | $F000     | $XXXX | 0                          |   2       |              | 0            | 0                  1                0                1
    ; 2               |   6         | $C000     | $XXXX | 0                          |   3       |              | 0                | 0                  1                1                0
    ; 2               |   7         | $E000     | $XXXX | 0                          |   X       |              | 0                | 0                  1                1                1
    ; 3               |   8         | $F000     | $XXXX | 0                          |   X       |              | 0                | 1                  0                0                0
    ; 3               |   9         | $C000     | $XXXX | 0                          |   X       |              | 0                | 1                  0                0                1
    ; 3               |   10        | $E000     | $XXXX | 0                          |   X       |              | 0                | 1                  0                1                0
    ; 3               |   11        | $F000     | $XXXX | 0                          |   X       |              | 0                | 1                  0                1                1
    ; 3               |   12        | $C000     | $XXXX | 0                          |   X       |              | 0                | 1                  1                0                0


sector_39SF040_bank:
; bank 1
.byt 1 ; Sector 0 (bank command id : 1)
.byt 1 ; Sector 1 (bank command id : 1)
.byt 1 ; Sector 2 (bank command id : 1)
.byt 1 ; Sector 3 (bank command id : 1)
; Bank 2
.byt 2 ; Sector 4 (bank command id : 1)
.byt 2 ; Sector 5 (bank command id : 1)
.byt 2 ; Sector 6 (bank command id : 1)
.byt 2 ; Sector 7 (bank command id : 1)
; Bank 3
.byt 3 ; Sector 8 (bank command id : 1)
.byt 3 ; Sector 9 (bank command id : 1)
.byt 3 ; Sector 10 (bank command id : 1)
.byt 3 ; Sector 11 (bank command id : 1)

; bank 4
.byt 4 ; Sector 12
.byt 4 ; Sector 13
.byt 4 ; Sector 14
.byt 4 ; Sector 15

; Bank 5
.byt 1 ; Sector 16
.byt 1 ; Sector 17
.byt 1 ; Sector 18
.byt 1 ; Sector 19

; Bank 6
.byt 2 ; Sector 20
.byt 2 ; Sector 21
.byt 2 ; Sector 22
.byt 2 ; Sector 23

; Bank 7
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 8
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31

; Bank 9
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; Bank 10
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; Bank 11
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 12
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31

; Bank 13
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; Bank 14
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; Bank 15
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 16
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31

; Bank 17
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; Bank 18
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; Bank 19
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 20
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31


; Bank 21
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; Bank 22
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; Bank 23
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 24
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31


; Bank 25
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; Bank 26
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; Bank 27
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 28
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31

; Bank 29
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; Bank 30
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; Bank 31
.byt 3 ; Sector 24
.byt 3 ; Sector 25
.byt 3 ; Sector 26
.byt 3 ; Sector 27

; Bank 32
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31

sector_39SF040_banking_register:
; bank 1
.byt 0 ; Sector 0 (bank command id : 1)
.byt 0 ; Sector 1 (bank command id : 1)
.byt 0 ; Sector 2 (bank command id : 1)
.byt 0 ; Sector 3 (bank command id : 1)

; bank 2
.byt 0 ; Sector 4 (bank command id : 1)
.byt 0 ; Sector 5 (bank command id : 1)
.byt 0 ; Sector 6 (bank command id : 1)
.byt 0 ; Sector 7 (bank command id : 1)

; bank 3
.byt 0 ; Sector 8 (bank command id : 1)
.byt 0 ; Sector 9 (bank command id : 1)
.byt 0 ; Sector 10 (bank command id : 1)
.byt 0 ; Sector 11 (bank command id : 1)

; bank 4
.byt 0 ; Sector 12
.byt 0 ; Sector 13
.byt 0 ; Sector 14
.byt 0 ; Sector 15

; bank 5
.byt 4 ; Sector 16
.byt 4 ; Sector 17
.byt 4 ; Sector 18
.byt 4 ; Sector 19

; bank 6
.byt 4 ; Sector 20
.byt 4 ; Sector 21
.byt 4 ; Sector 22
.byt 4 ; Sector 23

; bank 7
.byt 4 ; Sector 24
.byt 4 ; Sector 25
.byt 4 ; Sector 26
.byt 4 ; Sector 27

; bank 8
.byt 4 ; Sector 28
.byt 4 ; Sector 29
.byt 4 ; Sector 30
.byt 4 ; Sector 31

; bank 9
.byt 1 ; Sector 32
.byt 1 ; Sector 33
.byt 1 ; Sector 34
.byt 1 ; Sector 35

; bank 10
.byt 1 ; Sector 36
.byt 1 ; Sector 37
.byt 1 ; Sector 38
.byt 1 ; Sector 39

; bank 11
.byt 1 ; Sector 36
.byt 1 ; Sector 37
.byt 1 ; Sector 38
.byt 1 ; Sector 39

; bank 12
.byt 1 ; Sector 36
.byt 1 ; Sector 37
.byt 1 ; Sector 38
.byt 1 ; Sector 39

; bank 13
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; bank 14
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; bank 15
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; bank 16
.byt 2 ; Sector 36
.byt 2 ; Sector 37
.byt 2 ; Sector 38
.byt 2 ; Sector 39

; bank 17
.byt 3 ; Sector 36
.byt 3 ; Sector 37
.byt 3 ; Sector 38
.byt 3 ; Sector 39

; bank 18
.byt 3 ; Sector 36
.byt 3 ; Sector 37
.byt 3 ; Sector 38
.byt 3 ; Sector 39

; bank 19
.byt 3 ; Sector 36
.byt 3 ; Sector 37
.byt 3 ; Sector 38
.byt 3 ; Sector 39

; bank 20
.byt 3 ; Sector 36
.byt 3 ; Sector 37
.byt 3 ; Sector 38
.byt 3 ; Sector 39

; bank 21
.byt 5 ; Sector 36
.byt 5 ; Sector 37
.byt 5 ; Sector 38
.byt 5 ; Sector 39

; bank 22
.byt 5 ; Sector 36
.byt 5 ; Sector 37
.byt 5 ; Sector 38
.byt 5 ; Sector 39

; bank 23
.byt 5 ; Sector 36
.byt 5 ; Sector 37
.byt 5 ; Sector 38
.byt 5 ; Sector 39

; bank 24
.byt 5 ; Sector 36
.byt 5 ; Sector 37
.byt 5 ; Sector 38
.byt 5 ; Sector 39

; bank 25
.byt 6 ; Sector 36
.byt 6 ; Sector 37
.byt 6 ; Sector 38
.byt 6 ; Sector 39

; bank 26
.byt 6 ; Sector 36
.byt 6 ; Sector 37
.byt 6 ; Sector 38
.byt 6 ; Sector 39

; bank 27
.byt 6 ; Sector 36
.byt 6 ; Sector 37
.byt 6 ; Sector 38
.byt 6 ; Sector 39

; bank 28
.byt 6 ; Sector 36
.byt 6 ; Sector 37
.byt 6 ; Sector 38
.byt 6 ; Sector 39

; bank 29
.byt 7 ; Sector 36
.byt 7 ; Sector 37
.byt 7 ; Sector 38
.byt 7 ; Sector 39

; bank 30
.byt 7 ; Sector 36
.byt 7 ; Sector 37
.byt 7 ; Sector 38
.byt 7 ; Sector 39

; bank 31
.byt 7 ; Sector 36
.byt 7 ; Sector 37
.byt 7 ; Sector 38
.byt 7 ; Sector 39

; bank 32
.byt 7 ; Sector 36
.byt 7 ; Sector 37
.byt 7 ; Sector 38
.byt 7 ; Sector 39





sector_39SF040_adress_high:
; bank 1
.byt >$C000 ; Sector 0 (bank command id : 1) ok
.byt >$D000 ; Sector 1 (bank command id : 1) ok
.byt >$E000 ; Sector 2 (bank command id : 1)
.byt >$F000 ; Sector 3 (bank command id : 1)

; bank 2
.byt >$C000 ; Sector 4 (bank command id : 1)
.byt >$D000 ; Sector 5 (bank command id : 1)
.byt >$E000 ; Sector 6 (bank command id : 1)
.byt >$F000 ; Sector 7 (bank command id : 1)

; bank 3
.byt >$C000 ; Sector 8 (bank command id : 1)
.byt >$D000 ; Sector 9 (bank command id : 1)
.byt >$E000 ; Sector 10 (bank command id : 1)
.byt >$F000 ; Sector 11 (bank command id : 1)

; bank 4
.byt >$C000 ; Sector 12 (bank command id : 1)
.byt >$D000 ; Sector 13 (bank command id : 1)
.byt >$E000 ; Sector 14 (bank command id : 1)
.byt >$F000 ; Sector 15 (bank command id : 1)

; bank 5
.byt >$C000 ; Sector 16
.byt >$D000 ; Sector 17
.byt >$E000 ; Sector 18
.byt >$F000 ; Sector 19

; bank 6
.byt >$C000 ; Sector 20
.byt >$D000 ; Sector 21
.byt >$E000 ; Sector 22
.byt >$F000 ; Sector 23

; bank 7
.byt >$C000 ; Sector 24
.byt >$D000 ; Sector 25
.byt >$E000 ; Sector 26
.byt >$F000 ; Sector 27

; bank 8
.byt >$C000 ; Sector 28
.byt >$D000 ; Sector 29
.byt >$E000 ; Sector 30
.byt >$F000 ; Sector 31

; bank 9
.byt >$C000 ; Sector 32
.byt >$D000 ; Sector 33
.byt >$E000 ; Sector 34
.byt >$F000 ; Sector 35

; bank 10
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 11
.byt >$C000 ; Sector 40
.byt >$D000 ; Sector 41
.byt >$E000 ; Sector 42
.byt >$F000 ; Sector 43

; bank 12
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39


; bank 13
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 14
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 15
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 16
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 17
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 18
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 19
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 20
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 21
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 22
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 23
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 24
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 25
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 26
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 27
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 28
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 29
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
; bank 30
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 31
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39

; bank 32
.byt >$C000 ; Sector 36
.byt >$D000 ; Sector 37
.byt >$E000 ; Sector 38
.byt >$F000 ; Sector 39
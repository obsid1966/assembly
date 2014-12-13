;CRC GENERATOR/CHECKER 04/17/86
;   POLYNOMIAL:   X^16 + X^12 + X^5 + 1
;   INITIALIZED STATE: B230h (PRELOADED WITH A1h,A1h,A1h,FEh)
;   SHIFTING CHARACTERS: TRACK,SIDE,SECTOR,SECTOR_LENGTH,CRC,CRC

crcheader .proc
        lda  tmp
        pha
        lda  tmp+1
        pha
        lda  tmp+2
        pha
        lda  tmp+3
        pha
        lda  tmp+4
        pha
        lda  tmp+5
        pha
        lda  tmp+6
        pha

        lda  #$30
        sta  tmp+5      ; sig_lo
        lda  #$B2
        sta  tmp+6      ; sig_hi (3) A1H, (1) FEH

        ldy  #0
m1      lda  header,y
        sta  tmp+1      ; msb
        tax
        iny
        lda  header,y
        sta  tmp        ; lsb

        txa
        ldx  #16
m2      sta  tmp+2
        clc
        rol  tmp
        rol  tmp+1
        lda  #0
        sta  tmp+3
        sta  tmp+4

        bit  tmp+2
        bpl  +

        lda  #$21
        sta  tmp+3
        lda  #$10
        sta  tmp+4
+       bit  tmp+6
        bpl  +

        lda  tmp+3
        eor  #$21
        sta  tmp+3
        lda  tmp+4
        eor  #$10
        sta  tmp+4
+       clc
        rol  tmp+5
        rol  tmp+6
        lda  tmp+5
        eor  tmp+3
        sta  tmp+5
        lda  tmp+6
        eor  tmp+4
        sta  tmp+6
        lda  tmp+1
        dex
        bne  m2

        iny
        cpy  #5
        bcc  m1

        ldy  tmp+5
        ldx  tmp+6

        pla
        sta  tmp+6
        pla
        sta  tmp+5
        pla
        sta  tmp+4
        pla
        sta  tmp+3
        pla
        sta  tmp+2
        pla
        sta  tmp+1
        pla
        sta  tmp

        cpy  #0         ; must be zero
        bne  +

        cpx  #0         ; *
        bne  +

        clc
        rts


+       lda  #9         ; crc header in header
        jmp  errr       ; bye bye ....
        .pend

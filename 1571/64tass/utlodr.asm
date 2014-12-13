
        rts
boot    rts
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        rts

utlodr  jmp  ptch18
        nop
        nop

rtch18  jsr  killp
        lda  f2cnt
        pha             ; save file count for utility
        lda  #1
        sta  f2cnt
        lda  #$ff       ; init firstbyte flag
        sta  r0         ; r0 is flag
        jsr  lookup     ; locate filename on disk
        lda  filtrk     ; check if found. err if not
        bne  utld00

+       lda  #nocfil
        jsr  cmderr

utld00  pla
        sta  f2cnt      ; restore file count
        lda  filtrk     ; init trk,sec for open
        sta  track
        lda  filsec
        sta  sector
        lda  #usrtyp    ; open sys type file(5)
        jsr  opntyp     ; open
utld10  lda  #$00       ; init checksum
        sta  r1         ; chksum resides in r1
        jsr  gtabyt     ; fetch load adr lo
        sta  r2
        jsr  addsum     ; add into checksum
        jsr  gtabyt     ; fetch load adr hi
        sta  r3
        jsr  addsum
        lda  r0         ; first byte address?
        beq  utld20     ; br if not

        lda  r2         ; sav this adr
        pha             ; lo first
        lda  r3
        pha             ; hi next
        lda  #$00       ; clear flag
        sta  r0         ; first byte flag
utld20  jsr  gtabyt     ; fetch data byte count
        sta  r4         ; save in r4
        jsr  addsum     ; add into checksum
utld30  jsr  gtabyt     ; fetch data byt
        ldy  #$00       ; init index
        sta  (r2),y     ; store byte
        jsr  addsum     ; add into checksum
        lda  r2         ; pointer:=pointer+1
        clc
        adc  #$01
        sta  r2
        bcc  utld35

        inc  r3         ; add in carry
utld35  dec  r4         ; update byte counter
        bne  utld30     ; if nonzero, continue

        jsr  gibyte     ; get byte without chk for eoi
        lda  data
        cmp  r1         ; last byte was chksum
        beq  utld50     ; ...everything ok

        jsr  gethdr
        lda  #norec     ; show record overflow
        jsr  cmder2     ; and leave to err exit

utld50  lda  eoiflg     ; check for eof
        bne  utld10     ; if nonzero, not done

        pla             ; xfer cntrl to
        sta  r3         ; 1st byte addr.
        pla
        sta  r2
        jmp  (r2)

gtabyt  jsr  gibyte     ; fetch a byte
        lda  eoiflg     ; check if eof exists
        bne  gtabye     ; ok if nonzero
        jsr  gethdr
        lda  #recovf    ; record size error
        jsr  cmder2     ; error routine
gtabye  lda  data
        rts

addsum  clc
        adc  r1         ; .a=.a+r1
        adc  #$00       ; .a=.a+carry
        sta  r1         ; save new checksum
        rts

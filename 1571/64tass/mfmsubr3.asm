
; mfm verify for write operation

cmdele  lda  #3
        sta  bufpnt+1   ; buffer #0
        ldy  #0         ; even page
        sty  bufpnt
        ldx  mfmsiz_hi  ; get sector high
        lda  cmdbuf+3   ; get track address
        sta  wdtrk      ; give track to wd
        lda  cmdbuf+4   ; get sector address
        sta  wdsec      ; give sector to wd
cmd_11  lda  #$88       ; read sector command
        jsr  strtwd     ; send cmd

        #WDTEST         ; chk address
c_1100  lda  wdstat     ; get a byte
        and  #3
        lsr  a
        bcc  c_1101

        and  #1
        beq  c_1100     ; byte ready

        lda  wddat      ; get a byte from wd
        cmp  (bufpnt),y ; put it in the buffer
        bne  c_1101     ; flag error

        cpy  mfmsiz_lo  ; done buffer
        beq  c_1102     ; next

        iny
        bne  c_1100

c_1102  iny             ; y=0
        dex
c_1103  beq  c_1104

        inc  bufpnt+1   ; next buffer
        jmp  c_1100

c_1101  lda  #$d0       ; abort wd1770
        #WDTEST         ; chk address
        sta  wdstat     ; send cmd

        jsr  jslowd     ; wait 40 uS.

        ldx  #7
        .byte skip2
c_1104  ldx  #0
        stx  mfmcmd
        jmp  waitdn     ; wait for the wd1770 to sleep

; verify sector to fill byte
; track and sector must be setup previous

cmdtwv  lda  #3
        sta  bufpnt+1   ; buffer #1
        ldy  #0         ; even page
        sty  bufpnt
        ldx  mfmsiz_hi  ; get sector high
cmd_12  lda  #$88       ; read sector command
        jsr  strtwd     ; send cmd

        #WDTEST         ; chk address
c_1200  lda  wdstat     ; get a byte
        and  #3
        lsr  a
        bcc  c_1201

        and  #1
        beq  c_1200     ; byte ready

        lda  wddat      ; get a byte from wd
        cmp  cmdbuf+10  ; same as fill byte ?
        bne  c_1201     ; br, on error

        cpy  mfmsiz_lo  ; get lo sector size
        beq  c_1202

        iny
        bne  c_1200     ; done ?

c_1202  iny
        dex
c_1203  beq  c_1204

        inc  bufpnt+1   ; next buffer
        jmp  c_1200

c_1201  lda  #$d0       ; abort wd1770
        #WDTEST         ; chk address
        sta  wdstat     ; send cmd

        jsr  jslowd     ; wait 40 uS.

        ldx  #7
        .byte skip2
c_1204  ldx  #0
        stx  mfmcmd
        jmp  waitdn     ; wait for the wd1770 to sleep

cmdthi  php
        sei
        jsr  cmdone     ; track zero start

        bit  switch     ; seek to n-track ?
        bpl  +

        lda  cmdbuf+3
        sta  cmd_trk    ; goto this track
        jsr  seke

+       lda  #0
        sta  cpmsek     ; clear # of sectors

        jsr  cmdfiv     ; read address
        ldx  mfmcmd     ; check status
        cpx  #2
        bcs  +

        lda  mfmhdr+2
        sta  cmd_sec    ; this is where we stop

-       jsr  cmdfiv     ; read address
        lda  mfmhdr+2   ; get next sector
        ldy  cpmsek
        sta  cmdbuf+11,y
        inc  cpmsek     ; inc sector count
        cpy  #31        ; went too far ?
        bcs  +

        cmp  cmd_sec    ; done yet ?
        bne  -          ; wait for rap...

        lda  mfmhdr     ; get track
        sta  cmd_trk    ; save for later

        ldx #0
        .byte skip2
+       ldx #2
        stx  mfmcmd
        plp
        rts

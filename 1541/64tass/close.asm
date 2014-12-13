; close the file associated with sa

close
        lda  #0
        sta  wbam
        lda  sa
        bne  cls10      ; directory close
        lda  #0
        sta  dirlst     ; clear dir list
        jsr  frechn
cls05
        jmp  freich
cls10
        cmp  #$f
        beq  clsall     ; close cmd chanl
        jsr  clschn     ; close channel
        lda  sa
        cmp  #2
        bcc  cls05

        lda  erword
        bne  cls15      ; last command had an error
        jmp  endcmd
cls15
        jmp  scren1

clsall
        lda  #14
        sta  sa
cls20
        jsr  clschn
        dec  sa
        bpl  cls20
        lda  erword
        bne  cls25      ;  last command had an error
        jmp  endcmd
cls25
        jmp  scren1

clschn
        ldx  sa
        lda  lintab,x
        cmp  #$ff
        bne  clsc28
        rts
clsc28
        and  #$f
        sta  lindx

        jsr  typfil
        cmp  #dirtyp
        beq  clsc30     ; direct channel
        cmp  #reltyp
        beq  clsrel

        jsr  fndwch     ; look for write channel
        bcs  clsc31

        jsr  clswrt     ; close seq write
        jsr  clsdir     ; close directory
clsc30
        jsr  mapout     ; write bam
clsc31
        jmp  frechn

clsrel
        jsr  scrub
        jsr  dblbuf
        jsr  ssend
        ldx  ssnum
        stx  t4
        inc  t4
        lda  #0
        sta  t1
        sta  t2
        lda  ssind
        sec
        sbc  #ssioff-2
        sta  t3
        jsr  sscalc
        ldx  lindx
        lda  t1
        sta  nbkl,x
        lda  t2
        sta  nbkh,x
        lda  #dyfile
        jsr  tstflg
        beq  clsr1
        jsr  clsdir
clsr1   jmp  frechn

; close a write chanl

clswrt                  ; close seq write file
        ldx  lindx
        lda  nbkl,x
        ora  nbkh,x
        bne  clsw10     ; at least 1 block written

        jsr  getpnt
        cmp  #2
        bne  clsw10     ; at least 1 byte written

        lda  #cr
        jsr  putbyt
clsw10
        jsr  getpnt
        cmp  #2
        bne  clsw20     ; not mt buffer

        jsr  dblbuf     ; switch bufs

        ldx  lindx
        lda  nbkl,x
        bne  clsw15
        dec  nbkh,x
clsw15
        dec  nbkl,x

        lda  #0
clsw20
        sec
        sbc  #1         ; back up 1
        pha             ; save it
        lda  #0
        jsr  setpnt
        jsr  putbyt     ; tlink=0
        pla             ; lstchr count
        jsr  putbyt

        jsr  wrtbuf     ; write out last buffer
        jsr  watjob     ; finish job up
        jmp  dblbuf     ; make sure both bufs ok

; directory close on open write file

clsdir  ldx  lindx      ; save lindx
        stx  wlindx     ; &sa
        lda  sa
        pha
        lda  dsec,x     ; get directory sector
        sta  sector
        lda  dind,x     ; get sector offset
        sta  index
        lda  filtyp,x   ; drv # in filtyp
        and  #1
        sta  drvnum
        lda  dirtrk
        sta  track
        jsr  getact     ; allocate a buffer
        pha
        sta  jobnum
        jsr  drtrd      ; read directory sector
        ldy  #0
        lda  bufind,x   ; .x is job#
        sta  r0+1
        lda  index
        sta  r0
        lda  (r0),y
        and  #$20
        beq  clsd5
        jsr  typfil
        cmp  #reltyp
        beq  clsd6

        lda  (r0),y
        and  #$8f       ; replace file
        sta  (r0),y
        iny
        lda  (r0),y
        sta  track
        sty  temp+2
        ldy  #27        ; extract replacement link
        lda  (r0),y     ;  to last sector
        pha
        dey
        lda  (r0),y
        bne  clsd4
        sta  track
        pla
        sta  sector
        lda  #$67
        jsr  cmder2
clsd4
        pha
        lda  #0
        sta  (r0),y
        iny
        sta  (r0),y
        pla
        ldy  temp+2
        sta  (r0),y
        iny
        lda  (r0),y
        sta  sector
        pla
        sta  (r0),y
        jsr  delfil     ; delete old file
        jmp  clsd6      ; set close bit
clsd5
        lda  (r0),y
        and  #$f
        ora  #$80
        sta  (r0),y
clsd6   ldx  wlindx
        ldy  #28        ; set # of blocks
        lda  nbkl,x
        sta  (r0),y
        iny
        lda  nbkh,x
        sta  (r0),y
        pla
        tax
        lda  #write     ; write directory sector
        ora  drvnum
        jsr  doit
        pla
        sta  sa
        jmp  fndwch     ; restore lindx

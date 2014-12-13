addrel  jsr  adrels
        jsr  fndrel
addr1
        jsr  numfre     ; calc available...
        ldy  lindx      ; record span?
        ldx  rs,y
        dex
        txa
        clc
        adc  relptr
        bcc  ar10       ; include ss ptrs and check

        inc  ssind
        inc  ssind
        bne  ar10

        inc  ssnum
        lda  #ssioff
        sta  ssind
ar10
        lda  r1
        clc
        adc  #2
        jsr  setssp
        lda  ssnum
        cmp  #nssl
        bcc  ar25       ; valid range?

        jsr  hugerel
        bne  ar20

        sta  ssnum      ; .a = 0
        inc  grpnum
        bne  ar25       ; bra
ar20
        lda  #bigfil
        jsr  cmderr     ; too many ss's

ar25    lda  ssind      ; calc # blks needed
        sec             ; & check against avail.
        sbc  r1
        bcs  ar30

        sbc  #ssioff-1
        clc
ar30
        pha
        jsr  hugerel
        beq  addbig

        pla
        sta  t3         ; # ss indices
        lda  ssnum
        sbc  r0
        sta  t4         ; # ss needed
        ldx  #0         ; clear accum.
        stx  t1
        stx  t2
        tax             ; .x=# ss
        jsr  sscalc     ; calc # of blks needed
        lda  t2
        bne  ar35

        ldx  t1
        dex
        bne  ar35

        beq  ar34       ; bra
;
; add for big relfile
;
addbig
        pla
        sta  t3
        lda  ssnum
        sbc  r0
        bcs  addbi1

        inc  r3
        adc  #6
addbi1
        sta  t4
        lda  grpnum
        sec
        sbc  r3
        sta  r3
        jsr  ssscal
        lda  result+1
        bne  ar35

        ldx  result
        bne  addbi2

        rts
addbi2
        dex
        bne  ar35
ar34
        inc  r2
ar35    cmp  nbtemp+1
        bcc  ar40       ; ok!!

        bne  ar20

        lda  nbtemp
        cmp  t1
        bcc  ar20       ; not enuf blocks

ar40    lda  #1
        jsr  drdbyt     ; look at sec link
        clc
        adc  #1         ; +1 is nr
        ldx  lindx
        sta  nr,x
        jsr  nxtts      ; get next block
        jsr  setlnk     ; ...& set link.
        lda  r2
        bne  ar50       ; add one block

        jsr  wrtout     ; write current last rec
ar45
        jsr  dblbuf     ; switch bufs
        jsr  sethdr     ; set hdr from t & s
        jsr  nxtts      ; get another
        jsr  setlnk     ; set up link
        jsr  nulbuf     ; clean it out
        jmp  ar55

ar50    jsr  dblbuf     ; switch bufs
        jsr  sethdr     ; set hdr from t&s
        jsr  nulbuf     ; clean buffer
        jsr  nullnk     ; last block =0,lstchr
ar55    jsr  wrtout     ; write buffer
        jsr  getlnk     ; get t&s from link
        lda  track
        pha             ; save 'em
        lda  sector
        pha
        jsr  gethdr     ; now get hdr t&s
        lda  sector
        pha             ; save 'em
        lda  track
        pha
        jsr  gsspnt     ; check ss ptr
        tax
        bne  ar60

        jsr  newss      ; need another ss
        lda  #ssioff
        jsr  setssp     ; .a=bt val
        inc  r0         ; advance ss count
ar60    pla
        jsr  putss      ; record t&s...
        pla
        jsr  putss      ; ...in ss.
        pla             ; get t&s from link
        sta  sector
        pla
        sta  track
        beq  ar65       ; t=0: that's all!!

        jsr  hugerel
        bne  ar61

        lda  r5
        cmp  grpnum
        bcc  ar45
ar61
        lda  r0
        cmp  ssnum
        bne  ar45       ; not even done yet

        jsr  gsspnt
        cmp  ssind
        bcc  ar45       ; almost done

        beq  ar50       ; one more blk left

ar65    jsr  gsspnt
        pha
        lda  #0
        jsr  ssdir
        lda  #0
        tay
        sta  (dirbuf),y
        iny
        pla
        sec
        sbc  #1
        sta  (dirbuf),y
        jsr  wrtss      ; write ss
        jsr  watjob
        jsr  mapout
        jsr  fndrel
        jsr  dblbuf     ; get back to leading buf
        jsr  sspos
        bvs  ar70

        jmp  positn

ar70    lda  #lrf
        jsr  setflg
        lda  #norec
        jsr  cmderr

adrels
        jsr  ssend      ; setup eof
        jsr  posbuf
        jsr  hugerel
        bne  adrel1

        lda  grpnum
        sta  r5
        sta  r3
adrel1
        lda  ssind
        sta  r1         ; save ss index
        lda  ssnum
        sta  r0         ; save ss number
        lda  #0
        sta  r2
        sta  recptr     ; first byte in record
        rts


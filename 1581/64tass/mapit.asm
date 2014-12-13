newmap  .proc
        lda  #0
        sta  track      ; clr trk counter
        lda  dirtrk     ; link to bam2
        sta  bam1       ; set trk links
        lda  #0         ; end trk link
        sta  bam2       ;
        lda  #2         ; link to bam2
        sta  bam1+1
        lda  #$ff       ; sector end link
        sta  bam2+1
        lda  vernum
        sta  bam1+2
        sta  bam2+2
        eor  #$ff
        sta  bam1+3
        sta  bam2+3
        lda  dskid
        sta  bam1+4
        sta  bam2+4
        lda  dskid+1
        sta  bam1+5
        sta  bam2+5
        lda  iobyte
        sta  bam1+6     ; bit-7 iobyte verify, bit-6 crc check
        sta  bam2+6     ; *
        lda  #0
        sta  bam1+7     ; auto boot flag off
        sta  bam2+7     ; *
        jsr  setbp2     ; set pntrs
m1      ldy  #bindx     ; bam offset
m2      inc  track      ; next trk
        lda  track      ; chk trk
        cmp  startrk    ; allocate neccessary tracks
        beq  m4         ; if track = starttrk then do not allocate

        bcc  m3         ; if track < starttrk then allocate

        cmp  maxtrk
        beq  m3         ; if track = maxtrk then allocate

        bcc  m4         ; if track < maxtrk then do not allocate

m3      clc
        .byte skip1
m4      sec
        php             ; save carry

        lda  #0         ; clear track map
        sta  t0
        sta  t1
        sta  t2
        sta  t3
        sta  t4

        ldx  numsec
        txa
        bcs  +

        lda  #0
+       sta  (bmpnt),y
        iny

-       plp             ; save carry
        php             ; & retrieve
        rol  t0         ;      t0        t1          t2    ...    t4
        rol  t1         ;   76543210  111111      22221111 ... 33333333
        rol  t2         ;             54321098    32109876 ... 98765432
        rol  t3
        rol  t4
        dex
        bne  -

        plp
-                       ; .x=0
        lda  t0,x
        sta  (bmpnt),y  ; write out bit map
        iny
        inx
        cpx  #5
        bcc  -

        tya             ; done?
        bne  m2

        lda  bmpnt+1
        cmp  #>bam2     ; both bams done?
        beq  +          ; yep...

        inc  bmpnt+1    ; do the next bam
        bne  m1         ; bra

+       lda  #1
        sta  wbam       ; set it dirty
        lda  #0
        sta  ndbl       ; clr blk free

        lda  dirtrk
        sta  track
        lda  #0
        sta  sector     ; allocate 3 sectors & directory sector
        jsr  wused      ; 0
        inc  sector
        jsr  wused      ; 1
        inc  sector
        jsr  wused      ; 2

        lda  dirst
        sta  sector
        jsr  wused      ; 3 usually

        jmp  nfcalc
        .pend

mapout  lda  wbam       ; is it dirty?
        beq  sb40       ; its clean

        lda  maxtrk     ; verify bam first
        sta  cont       ; set trk counter
        jsr  setbp2     ; set base adrr
sb10    lda  #bindx     ; bam offset
sb20    sta  bmpnt      ; lsb
        jsr  avck       ; check this trk
        dec  cont       ; do next trk
        beq  sb30       ; verify done

        clc             ; update bam pointer
        lda  bmpnt      ;
        adc  #6         ; 6 byte per trk
        bcc  sb20       ; same bam

        lda  bmpnt+1
        cmp  #>bam2
        beq  sb30

        inc  bmpnt+1    ; do next bam
        jmp  sb10

sb30    jsr  bamout     ; wrt the bams
sb40    lda  #0
        sta  wbam       ; set it clean now!
        rts

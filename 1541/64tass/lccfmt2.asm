;
;
;
ds08    lda  #$66       ;  min block size 282*5/4 -256=85
;
        sta  dtrck
;
        ldx  sectr      ;  total bytes= min*#secors
        ldy  #0
        tya
;
ds10    clc             ;  min*#sectors
        adc  dtrck
        bcc  ds14
;
        iny
;
ds14    iny
        dex
        bne  ds10
;
        eor  #$ff       ;  get 2s comp
        sec
        adc  #0
;
        clc
        adc  tral+1
        bcs  ds15
;
        dec  tral
;
ds15    tax
        tya
        eor  #$ff
        sec
        adc  #0
        clc
        adc  tral
;
        bpl  ds17
;
        lda  #tobig     ;  not enough space
        jmp  fmterr
;
ds17    tay
        txa
        ldx  #0
;
ds20    sec
        sbc  sectr
        bcs  ds22
;
        dey
        bmi  ds30
;
ds22    inx
        bne  ds20
;
ds30    stx  dtrck

;-----rom05-bc---09/12/84------
        cpx  #gap2      ;  test for min size
;------------------------------

        bcs  ds32
;
        lda  #tosmal    ;  gap2 to small
        jmp  fmterr
;
ds32    clc
        adc  sectr
        sta  remdr      ;  get remaider size
;
;
;
;
;
;  create header images
;
;
        lda  #0
        sta  sect
;
        ldy  #0
        ldx  drive
;
mak10   lda  hbid       ;  hbid cs s t id id 0f 0f
        sta  buff0,y
        iny
;
        iny             ;  skip checksum
;
        lda  sect       ;  store sector #
        sta  buff0,y
        iny
;
        lda  ftnum      ;  store track #
        sta  buff0,y
        iny
;
        lda  dskid+1,x  ;  store id low
        sta  buff0,y
        iny
;
        lda  dskid,x    ;  store id hi
        sta  buff0,y
        iny
;
        lda  #$0f       ;  store gap1 bytes
        sta  buff0,y
        iny
        sta  buff0,y
        iny
;
        lda  #0         ; create checksum
        eor  buff0-6,y
        eor  buff0-5,y
        eor  buff0-4,y
        eor  buff0-3,y
;
        sta  buff0-7,y  ;  store checksum
;
;
        inc  sect       ;  goto next sector
;
        lda  sect       ;  test if done yet
        cmp  sectr
        bcc  mak10      ;  more to do
;
        tya             ;  save block size
        pha
;
;
;
;
;   create data block of zero
;
        inx             ;  .x=0
        txa
;
crtdat  sta  buff2,x
        inx
        bne  crtdat
;
;
;  convert header block to gcr
;
        lda  #>buff0
        sta  bufpnt+1   ;  point at buffer
;
        jsr  fbtog      ;  convert to gcr with no bid char
;
        pla             ;   restore block size
        tay             ;  move buffer up 79 bytes
        dey             ;  for i=n-1 to 0:mem+i+69|:=mem+i|:next
        jsr  movup      ;  move buf0 up 69 bytes
;
        jsr  movovr     ;  move ovrbuf up to buffer
;
;
;
;   convert data block to gcr
;   write image
;
;   leave it in ovrbuf and buffer
;
;
        lda  #>buff2    ;  point at buffer
        sta  bufpnt+1
;
;
        jsr  chkblk     ;  get block checksum
        sta  chksum
        jsr  bingcr
;
;
;
;   start the format now
;
;   write out sync header gap1
;   data block
;
;
;
        lda  #0         ;  init counter
        sta  hdrpnt
;
        jsr  clearp     ;  clear disk
;
wrtsyn  lda  #$ff       ;  write sync
        sta  data2
;
        ldx  #numsyn    ;  write 4  sync
;
wrts10  bvc  *
        clv
;
        dex
        bne  wrts10
;
        ldx  #10        ;  write out header
        ldy  hdrpnt
;
wrts20  bvc  *
        clv
;
        lda  buff0,y    ;  get header data
        sta  data2
;
        iny
        dex
        bne  wrts20
;
;
; * write out gap1
;
        ldx  #gap1-2    ;  write  gcr bytes
;
wrts30  bvc  *
        clv
;
        lda  #$55
        sta  data2
;
        dex
        bne  wrts30
;
;
;
; * write out data block
;
        lda  #$ff       ;  write data block sync
;
        ldx  #numsyn
;
dbsync  bvc  *
        clv
;
        sta  data2
;
        dex
        bne  dbsync
;
        ldx  #256-topwrt ;  write out ovrbuf
;
wrts40  bvc  *
        clv
;
        lda  ovrbuf,x
        sta  data2
;
        inx
        bne  wrts40
;
;
        ldy  #0
;
wrts50  bvc  *
        clv
;
        lda  (bufpnt),y
        sta  data2
;
        iny
        bne  wrts50
;
        lda  #$55       ;  write gap2(dtrck)
        ldx  dtrck
;
wgp2    bvc  *
        clv
;
        sta  data2
        dex
        bne  wgp2
;
;       ldx #20         ; write erase trail gap
;wgp3   bvc *
;       clv
;       dex
;       bne wgp3
;
        lda  hdrpnt     ;  advance header pointer
        clc
        adc  #10
        sta  hdrpnt
;
;
;
;  done writing sector
;
        dec  sect       ;  go to next on
        bne  wrtsyn     ;  more to do
;
        bvc  *          ;  wait for last one to write
        clv
;
        bvc  *
        clv
;
        jsr  kill       ;  goto read mode
;
;
;
;.end

b0tob0  pha             ; buff to buff transfr
        lda  #0
        sta  temp
        sta  temp+2
        lda  bufind,y
        sta  temp+1
        lda  bufind,x
        sta  temp+3
        pla
        tay
        dey
b02     lda  (temp),y
        sta  (temp+2),y
        dey
        bpl  b02

        rts

clrbuf  tay             ; clr given buffer
        lda  bufind,y   ; accm =buff
        sta  temp+1
        lda  #0
        sta  temp
        tay
cb10    sta  (temp),y
        iny
        bne  cb10

        rts

ssset   lda  #0         ; set ss pntr=0
        jsr  ssdir
        ldy  #2
        lda  (dirbuf),y ; accm=ss number
        rts

ssdir   sta  dirbuf     ; set dirbuf w/current
        ldx  lindx      ; ss pointer. accm=low byte
        lda  ss,x
        tax
        lda  bufind,x
        sta  dirbuf+1
        rts

setssp  pha             ; set dirbuf and buftbl with
        jsr  ssdir      ; current ss pntr. acm=low byte
        pha
        txa
        asl  a
        tax
        pla
        sta  buftab+1,x
        pla
        sta  buftab,x
        rts
sspos   jsr  sstest     ; set ss/buftbl to
        bmi  ssp10      ; to ssnum ssind

        bvc  ssp20      ; er0:ok, in range

        ldx  lindx      ; er1: possibly in range
        lda  ss,x
        jsr  ibrd       ; read ss in
        jsr  sstest     ; test again
        bpl  ssp20

ssp10   jsr  ssend      ; not in range,set end
        bit  er1
        rts             ; v=1

ssp20   lda  ssind      ; ok, set ptr w/ index
        jsr  setssp
        bit  er0
        rts             ; v=0

ibrd    sta  jobnum     ; indir block rd/wr.
        lda  #read_dv   ; accm= buf#, x=lindx
        bne  ibop       ; dirbuf)y pnts to t&s for r/w

        sta  jobnum
        lda  #wrtsd_dv
ibop    sta  cmd
        lda  (dirbuf),y
        sta  track
        iny
        lda  (dirbuf),y
        sta  sector
        lda  jobnum
        jsr  seth
        ldx  jobnum
        jmp  doit2

gsspnt  ldx  lindx
        lda  ss,x
        jmp  gp1

scal1   lda  #nssp
        jsr  addt12     ; add (#ss needed)*120
sscalc  dex
        bpl  scal1

        lda  t3         ; add (# ss indices needed)
        lsr  a
        jsr  addt12
        lda  t4         ; add (# ss blocks needed)
addt12  clc             ; add .a to t1,t2
        adc  t1
        sta  t1
        bcc  addrts

        inc  t2
addrts  rts
;
; calc # of side sectors needed
;
ssscal
        jsr  zerres
        jsr  zeracc
        ldy  r3
sssca1
        dey
        bmi  sssca2

        ldx  #>726
        lda  #<726
        jsr  addlit
        jmp  sssca1
sssca2
        ldy  t4
sssca3
        dey
        bmi  sssca4

        ldx  #0
        lda  #nssp+1
        jsr  addlit
        jmp  sssca3
sssca4
        lda  t3
        lsr  a
        ldx  #0
        jmp  addlit
zeracc
        ldx  #0
        stx  accum+1
        stx  accum+2
        stx  accum+3
        rts
addlit
        stx  accum+2
        sta  accum+1
        jmp  addres

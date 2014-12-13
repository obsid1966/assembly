
mask1=$f8
mask2=$07
mask2x=$c0
mask3=$3e
mask4=$01
mask4x=$f0
mask5=$0f
mask5x=$80
mask6=$7c
mask7=$03
mask7x=$e0
mask8=$1f
;
;
;
;
; fast gcr to binary conversion
;
get4gb  ldy  gcrpnt
;
        lda  (bufpnt),y
        and  #mask1
        lsr  a
        lsr  a
        lsr  a
        sta  gtab       ;  hi nibble

        lda  (bufpnt),y
        and  #mask2
        asl  a
        asl  a
        sta  gtab+1

        iny             ;  next byte
        bne  xx05       ;  test for next buffer
        lda  nxtbf
        sta  bufpnt+1
        ldy  nxtpnt

xx05    lda  (bufpnt),y
        and  #mask2x
        rol  a
        rol  a
        rol  a
        ora  gtab+1
        sta  gtab+1

        lda  (bufpnt),y
        and  #mask3
        lsr  a
        sta  gtab+2

        lda  (bufpnt),y
        and  #mask4
        asl  a
        asl  a
        asl  a
        asl  a
        sta  gtab+3

        iny                     ;  next

        lda  (bufpnt),y
        and  #mask4x
        lsr  a
        lsr  a
        lsr  a
        lsr  a
        ora  gtab+3
        sta  gtab+3

        lda  (bufpnt),y
        and  #mask5
        asl  a
        sta  gtab+4

        iny                     ;  next byte

        lda  (bufpnt),y
        and  #mask5x
        clc
        rol  a
        rol  a
        and  #1
        ora  gtab+4
        sta  gtab+4

        lda  (bufpnt),y
        and  #mask6
        lsr  a
        lsr  a
        sta  gtab+5

        lda  (bufpnt),y
        and  #mask7
        asl  a
        asl  a
        asl  a
        sta  gtab+6

        iny
; test for overflow during write to binary conversion
        bne  xx06
        lda  nxtbf
        sta  bufpnt+1
        ldy  nxtpnt

xx06    lda  (bufpnt),y
        and  #mask7x
        rol  a
        rol  a
        rol  a
        rol  a
        ora  gtab+6
        sta  gtab+6

        lda  (bufpnt),y
        and  #mask8
        sta  gtab+7
        iny

        sty  gcrpnt


        ldx  gtab
        lda  gcrhi,x
        ldx  gtab+1
        ora  gcrlo,x
        sta  btab

        ldx  gtab+2
        lda  gcrhi,x
        ldx  gtab+3
        ora  gcrlo,x
        sta  btab+1

        ldx  gtab+4
        lda  gcrhi,x
        ldx  gtab+5
        ora  gcrlo,x
        sta  btab+2

        ldx  gtab+6
        lda  gcrhi,x
        ldx  gtab+7
        ora  gcrlo,x
        sta  btab+3

        rts

gcrhi   .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $80
        .byte   $00
        .byte   $10
        .byte   $ff    ; error
        .byte   $c0
        .byte   $40
        .byte   $50
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $20
        .byte   $30
        .byte   $ff    ; error
        .byte   $f0
        .byte   $60
        .byte   $70
        .byte   $ff    ; error
        .byte   $90
        .byte   $a0
        .byte   $b0
        .byte   $ff    ; error
        .byte   $d0
        .byte   $e0
        .byte   $ff    ; error
;
;
;
gcrlo   .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   8
        .byte   $00
        .byte   1
        .byte   $ff    ; error
        .byte   $c
        .byte   4
        .byte   5
        .byte   $ff    ; error
        .byte   $ff    ; error
        .byte   2
        .byte   3
        .byte   $ff    ; error
        .byte   $f
        .byte   6
        .byte   7
        .byte   $ff    ; error
        .byte   9
        .byte   $a
        .byte   $b
        .byte   $ff    ; error
        .byte   $d
        .byte   $e
        .byte   $ff    ; error
;
;
gcrbin  lda  #0         ;  setup pointers
        sta  gcrpnt
        sta  savpnt
        sta  bytcnt
;
        lda  #>ovrbuf
        sta  nxtbf
;
        lda  #255-toprd
        sta  nxtpnt
;
        lda  bufpnt+1
        sta  savpnt+1
;
        jsr  get4gb
;
        lda  btab
        sta  bid        ;  get header id
;
        ldy  bytcnt
        lda  btab+1
        sta  (savpnt),y
        iny
;
        lda  btab+2
        sta  (savpnt),y
        iny
;
        lda  btab+3
        sta  (savpnt),y
        iny
;
gcrb10  sty  bytcnt
;
        jsr  get4gb
;
        ldy  bytcnt
;
        lda  btab
        sta  (savpnt),y
        iny
        beq  gcrb20     ;  test if done yet
;
        lda  btab+1
        sta  (savpnt),y
        iny
;
        lda  btab+2
        sta  (savpnt),y
        iny
;
        lda  btab+3
        sta  (savpnt),y
        iny
;
        bne  gcrb10     ;  jmp
;
gcrb20
        lda  btab+1
        sta  chksum
        lda  savpnt+1   ; restore buffer pointer
        sta  bufpnt+1
;
        rts
;.end

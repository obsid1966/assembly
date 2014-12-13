;
;   fast binary to gcr
;
;
put4bg  lda  #0         ;  clear table
        sta  gtab+1
        sta  gtab+4
;
        ldy  gcrpnt
;
        lda  btab
        and  #$f0
        lsr  a
        lsr  a
        lsr  a
        lsr  a
        tax
        lda  bgtab,x
;
        asl  a
        asl  a
        asl  a
        sta  gtab
;
        lda  btab
        and  #$0f
        tax
        lda  bgtab,x
;
        ror  a
        ror  gtab+1
        ror  a
        ror  gtab+1
;
        and  #$07
        ora  gtab
        sta  (bufpnt),y
;
        iny
;
        lda  btab+1
        and  #$f0
        lsr  a
        lsr  a
        lsr  a
        lsr  a
        tax
        lda  bgtab,x
;
        asl  a
        ora  gtab+1
        sta  gtab+1
;
;
        lda  btab+1
        and  #$0f
        tax
        lda  bgtab,x
;
        rol  a
        rol  a
        rol  a
        rol  a
        sta  gtab+2
;
        rol  a
        and  #1
        ora  gtab+1
        sta  (bufpnt),y
;
        iny
;
        lda  btab+2
        and  #$f0
        lsr  a
        lsr  a
        lsr  a
        lsr  a
        tax
        lda  bgtab,x
;
        clc
        ror  a
        ora  gtab+2
        sta  (bufpnt),y
        iny
;
        ror  a
        and  #$80
        sta  gtab+3
;
        lda  btab+2
        and  #$0f
        tax
        lda  bgtab,x
        asl  a
        asl  a
        and  #$7c
        ora  gtab+3
        sta  gtab+3
;
        lda  btab+3
        and  #$f0
        lsr  a
        lsr  a
        lsr  a
        lsr  a
        tax
        lda  bgtab,x
;
        ror  a
        ror  gtab+4
        ror  a
        ror  gtab+4
        ror  a
        ror  gtab+4
;
        and  #$03
        ora  gtab+3
        sta  (bufpnt),y
        iny
        bne  bing35
;
        lda  savpnt+1
        sta  bufpnt+1
;
;
bing35  lda  btab+3
        and  #$0f
        tax
        lda  bgtab,x
        ora  gtab+4
        sta  (bufpnt),y
        iny
        sty  gcrpnt
        rts
;
;
;
bgtab   .byte    $0a
	.byte    $0b
	.byte    $12
	.byte    $13
	.byte    $0e
	.byte    $0f
	.byte    $16
	.byte    $17
	.byte    $09
	.byte    $19
	.byte    $1a
	.byte    $1b
	.byte    $0d
	.byte    $1d
	.byte    $1e
	.byte    $15
;
;
;
;******************************
;*
;*
;*       binary to gcr conversion
;*
;*
;*   does inplace conversion of
;*   buffer to gcr using overflow
;*   block
;*
;*
;*   creates write image
;*
;*     1 block id char
;*   256 data bytes
;*     1 check sum
;*     2 off bytes
;*   ---
;*   260 binary bytes
;*
;*  260 binary bytes >> 325 gcr
;*
;*  325 = 256 + 69 overflow
;*
;*
;********************************
;*
bingcr  lda  #0         ;  init pointers
        sta  bufpnt
        sta  savpnt
        sta  bytcnt
;
        lda  #256-topwrt
        sta  gcrpnt     ;  start saving gcr here
;
        sta  gcrflg     ;  buffer converted flag
;
        lda  bufpnt+1   ;  save buffer pointer
        sta  savpnt+1
;
        lda  #>ovrbuf   ;  point at overflow
        sta  bufpnt+1
;
        lda  dbid       ;  store data block id
        sta  btab       ;  and next 3 data bytes
;
        ldy  bytcnt
;
        lda  (savpnt),y
        sta  btab+1
        iny
;
        lda  (savpnt),y
        sta  btab+2
        iny
;
        lda  (savpnt),y
        sta  btab+3
        iny
;
bing07  sty  bytcnt     ;  next byte to get
;
        jsr  put4bg     ;  convert and store
;
        ldy  bytcnt
;
        lda  (savpnt),y
        sta  btab
        iny
        beq  bing20
;
        lda  (savpnt),y
        sta  btab+1
        iny
;
        lda  (savpnt),y
        sta  btab+2
        iny
;
        lda  (savpnt),y
        sta  btab+3
        iny
;
        bne  bing07     ;  jmp
;
;
bing20  lda  chksum     ;  store chksum
        sta  btab+1
;
        lda  #0         ;  store 0 off byte
        sta  btab+2
        sta  btab+3
;
        jmp  put4bg     ;  convert and store and return
;
;
;
;.end

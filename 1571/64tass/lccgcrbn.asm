
; even faster gcr to binary conversion

jget4gb ldy  gcrpnt

        lda  (bufpnt),y
        sta  gtab       	;  A

        and  #mask2
        sta  gtab+1

        iny             	;  next byte
        bne  +			;  test for next buffer
        lda  nxtbf
        sta  bufpnt+1
        ldy  nxtpnt

+	lda  (bufpnt),y
	sta  gtab+2		;  C

        and  #mask2x
        ora  gtab+1
        sta  gtab+1     	;  B

	lda  gtab+2
        and  #mask4
        sta  gtab+3

        iny     		;  next

        lda  (bufpnt),y
        tax
        and  #mask4x
        ora  gtab+3
        sta  gtab+3     	;  D

        txa
        and  #mask5
        sta  gtab+4

        iny     		;  next byte

        lda  (bufpnt),y
	sta  gtab+5		;  F

        and  #mask5x
        ora  gtab+4
        sta  gtab+4     	;  E

	lda  gtab+5
        and  #mask7
        sta  gtab+6

        iny

; test for overflow during write to binary conversion

        bne  +

        lda  nxtbf
        sta  bufpnt+1
        ldy  nxtpnt
        sty  bufpnt

+	lda  (bufpnt),y
	sta  gtab+7    		;  H

        and  #mask7x
        ora  gtab+6
        sta  gtab+6    		;  G

        iny

        sty  gcrpnt

        ldx  gtab
        lda  gcrtb1,x  		;  a
        ldx  gtab+1
        ora  gcrtba,x  		;  b
        sta  btab

        ldx  gtab+2
        lda  gcrtb2,x    	;  c
        ldx  gtab+3
        ora  gcrtbd,x    	;  d
        sta  btab+1

        ldx  gtab+4
        lda  gcrtbe,x    	;  e
        ldx  gtab+5
	ora  gcrtb3,x    	;  f
        sta  btab+2

        ldx  gtab+6
        lda  gcrtbg,x    	;  g
        ldx  gtab+7
        ora  gcrtb4,x    	;  h
        sta  btab+3

        rts


jgcrbin lda  #0         ;  setup pointers
        sta  gcrpnt
        sta  savpnt
        sta  bytcnt

        lda  #>ovrbuf	; point to overflow first
        sta  nxtbf

        lda  #255-toprd	; overflow offset
        sta  nxtpnt

        lda  bufpnt+1
        sta  savpnt+1

        jsr  jget4gb

        lda  btab
        sta  bid        ;  get header id

        ldy  bytcnt
        lda  btab+1
        sta  (savpnt),y
        iny

        lda  btab+2
        sta  (savpnt),y
        iny

        lda  btab+3
        sta  (savpnt),y
        iny

-	sty  bytcnt

        jsr  jget4gb

        ldy  bytcnt

        lda  btab
        sta  (savpnt),y
        iny
        beq  +			; test if done yet

        lda  btab+1
        sta  (savpnt),y
        iny

        lda  btab+2
        sta  (savpnt),y
        iny

        lda  btab+3
        sta  (savpnt),y
        iny

        bne  -		;  jmp

+       lda  savpnt+1   ; restore buffer pointer
        sta  bufpnt+1
        rts

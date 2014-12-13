
;  mfm read

cmdnin  lda  switch
	and  #%00100000
	bne  c_904

	lda  #3
	sta  bufpnt+1	; buffer #1
	ldy  #0         ; even page
	sty  bufpnt
	ldx  mfmsiz_hi	; get sector size
        lda  cmdbuf+3   ; get track address
        sta  wdtrk      ; give track to wd
        lda  cmdbuf+4   ; get sector address
        sta  wdsec      ; give sector to wd
	lda  #$88       ; read sector command
	jsr  strtwd	; send cmd

	#WDTEST		; chk address
c_900	lda  wdstat	; get a byte
	and  #3
	lsr  a
	bcc  c_902

	and  #1
	beq  c_900

        lda  wddat      ; get a byte from wd
        sta  (bufpnt),y ; put it in the buffer
        cpy  mfmsiz_lo	; done buffer
        beq  c_901	; next

        iny
        bne  c_900

c_901	iny		; y=0
	dex
        beq  c_902

        inc  bufpnt+1   ; next buffer
        jmp  c_900

c_902	jsr  waitdn	; wait for unbusy

	jsr  cvstat	; convert
	jsr  upinst     ; update controller status

        bit  switch
	bvs  c_905	; ignore error ?

	cpx  #2
	bcc  c_905

	jmp  finbad	; send it

c_905	jsr  hskrd	; send status

	lda  switch
	bmi  c_906	; buffer transfer ?

c_904	lda  #3
	sta  bufpnt+1	; buffer #1
	ldy  #0         ; even page
	sty  bufpnt
	ldx  mfmsiz_hi	; get sector size
c_907	lda  (bufpnt),y ; get data from buffer
	sta  ctl_dat
	jsr  hskrd	; handshake data to host

        cpy  mfmsiz_lo	; done buffer ?
        beq  c_908	; next

        iny
        bne  c_907

c_908	iny		; y=0
	dex
        beq  c_906

        inc  bufpnt+1   ; next buffer
        jmp  c_907

c_906	dec  cmdbuf+5	; any more sectors ?
	beq  cmd9ex

	jsr  sectnx     ; next sector rap ?
	jmp  cmdnin	; continue...

cmd9ex  jmp  chcsee     ; next track

; mfm write

cmdten  lda  #3
	sta  bufpnt+1	; buffer #1
	ldy  #0
	sty  bufpnt
	ldx  mfmsiz_hi	; get high byte
	lda  switch
	bmi  c_100	; buffer transfer ?

c_101	lda  pb		; debounce
	eor  #clkout	; toggle clock
	bit  icr	; clear pending
	sta  pb		; doit

c_103	lda  pb
	bpl  c_102	; atn ?

	jsr  tstatn	; service if appropiate

c_102	lda  icr
	and  #8
	beq  c_103	; wait for byte ready

	lda  sdr	; get data
	sta  (bufpnt),y
	cpy  mfmsiz_lo
	beq  c_104

	iny
	bne  c_101

c_104	iny		; y=0
	dex
	beq  c_100

	inc  bufpnt+1   ; next buffer
	jmp  c_101

c_100	lda  switch
	and  #%00100000
	bne  c_105	; buffer op

	lda  switch
	and  #%00001000 ; check internal switch
	beq  c_112

	ldx  ctl_dat
	jmp  fail

c_112	lda  #3         ; write now
	sta  bufpnt+1	; buffer #1
	ldy  #0
	sty  bufpnt
	ldx  mfmsiz_hi
	lda  cmdbuf+3	; get track
	sta  wdtrk
	lda  cmdbuf+4
	sta  wdsec
	lda  ifr1	; check for diskette change
	lsr  a
	bcs  c_110

	lda  #$a8	; normal dam
	jsr  strtwd

	#WDTEST		; chk address
cmd10	lda  wdstat
	and  #3
	lsr  a
	bcc  c_110

	and  #1
	beq  cmd10

	lda  (bufpnt),y
	sta  wddat	; send data to wd1770
	cpy  mfmsiz_lo
	beq  cmd100

	iny
	bne  cmd10

cmd100	iny		; y=0
	dex
	beq  c_108

	inc  bufpnt+1	; next page...
	jmp  cmd10

c_108   lda  ifr1	; check for diskette change
	lsr  a
	bcs  c_110

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jsr  ptch60	; *** rom ds 01/21/86 ***, chk for verify
;	jsr  cmdele	; verify

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	bcc  c_109

c_110	jsr  spout	; go output
	ldx  #7
	bne  c_111	; bra

c_109	jsr  spout
	jsr  cvstat
c_111	stx  mfmcmd	; save status
	jsr  upinst
	jsr  hskrd	; send it
	jsr  burst	; wait for clk high
	jsr  spinp	; input

	bit  switch	; abort on error ?
	bvs  c_105

	cpx  #2		; error ?
	bcs  c_107

c_105	dec  cmdbuf+5	; more sectors
	beq  c_106

	jsr  sectnx	; next sector
	jmp  cmdten

c_106	jmp  chcsee

c_107	rts

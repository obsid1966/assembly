
;*****************************************************

jslower txa
	ldx  #5
	bne  jslowd+3	; bra

jslowd  txa
	ldx  #$0d	; insert 40 us. delay at 2 Mhz
-	dex
	bne  -
	tax
	rts

;*****************************************************

sav_pnt	lda  bmpnt	; save pointers
	sta  savbm
	lda  bmpnt+1
	sta  savbm+1
	rts

;*****************************************************

res_pnt lda  savbm
	sta  bmpnt	; save pointers
	lda  savbm+1
	sta  bmpnt+1
	rts

;*****************************************************

set_bm  .proc
	ldx  drvnum

	#NODRRD		; read nodrv,x absolute
;	lda  nodrv,x	; drive active

	beq  +

	lda  #nodriv

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

;	jsr  cmder3
	jsr  cmder2	; *** rom ds 11/07/85 beta9 ***, set error

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

+       jsr  bam2x	; get index into bufx
	jsr  redbam	; read BAM if neccessary

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jmp  m2		; *** rom ds 09/12/85 ***, always in memory!
;	lda  wbam	; write pending ?

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	beq  m3

	ora  #$80
	sta  wbam	; set write pending flag
	bne  m2		; bra

m3	jsr  wrt_bam	; write out BAM, *** rom ds 9/12/85 ***, never get here

m2	jsr  sav_pnt	; save current BAM pointers
	jsr  where	; find BAM
	lda  track	; get offset
	sec
	sbc  #36
	tay
	lda  (bmpnt),y	; get count
	pha
	jsr  res_pnt	; restore BAM pointers
	pla		; count in .a
	rts
	.pend

   .byte $44,$41,$56,$49,$44,$20,$47,$2e,$20,$53,$49,$52,$41,$43,$55,$53,$41

bam_pt	lda  track
	sec
	sbc  #36	; offset
	tay
	lda  sector	; sector/8
	lsr  a
	lsr  a
	lsr  a
	clc
	adc  bmindx,y	; get location
	tay
	lda  sector
	and  #7
	tax		; which sector
	lda  ovrbuf+$46,y
	and  bmask,x
	php		; save status
	lda  ovrbuf+$46,y
	plp		; retrieve status set/clr (z)
	rts

;*****************************************************

deall_b	jsr  sav_pnt	; save pointers
	jsr  where	; where is the BAM
	lda  track
	sec
	sbc  #36	; offset
	tay		; index into table
	clc
	lda  (bmpnt),y	; goto location and add 1
	adc  #1
	sta  (bmpnt),y
	jmp  res_pnt	; restore BAM pointers

;*****************************************************

alloc_b jsr  sav_pnt	; save pointers
	jsr  where	; find location of the BAM
	lda  track
	sec
	sbc  #36	; offset
	tay		; index into table
	sec
	lda  (bmpnt),y	; goto location and sub 1
	sbc  #1
	sta  (bmpnt),y
	jmp  res_pnt	; restore pointers

;*****************************************************

where	ldx  #blindx+7
	lda  buf0,x
	and  #$0f
	tax
	lda  bufind,x	; which buffer is the BAM in
	sta  bmpnt+1
	lda  #$dd
	sta  bmpnt
	rts

;*****************************************************

chk_blk .proc
	lda  temp
	pha		; save temp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jsr  ptch71	; *** rom ds 05/19/86 ***
;	jsr  sav_pnt

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	lda  track
	sec
	sbc  #36	; get offset
	tay
	pha		; save
	jsr  where	; where is the BAM
	lda  (bmpnt),y
	pha
	lda  #0
	sta  temp	; start at zero
	lda  #>bam_one
	sta  bmpnt+1	; msb
	lda  bmindx,y	; starts here
	clc
	adc  #<bam_one	; add offset
	sta  bmpnt

	ldy  #2
m1	ldx  #7		; verify bit map to count value
-	lda  (bmpnt),y
	and  bmask,x
	beq  +

	inc  temp	; on free increment
+	dex
	bpl  -

	dey
	bpl  m1

	pla
	cmp  temp
	beq  +

	lda  #direrr
	jsr  cmder2

+	pla
	tay		; restore track offset
	pla
	sta  temp	; restore temp
	jmp  res_pnt
	.pend

;*****************************************************

wrt_bam lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jmp  dowrit

+	lda  maxtrk
	cmp  #37
	bcc  -

	ldx  jobnum
	lda  lstjob,x	; save last job
	pha
	jsr  dowrit	; write out side zero
	jsr  sav_pnt	; save bmpnt
	jsr  setbpt
	jsr  clrbam+3	; clear buffer
	lda  jobnum
	asl  a
	tax
	lda  #53
	sta  hdrs,x	; put track in job queue, same sector

	ldy  #104
-	lda  ovrbuf+$46,y
	sta  (bmpnt),y
	dey
	bpl  -		; transfer to buffer

	jsr  res_pnt	; restore pointers
	jsr  dowrit	; write this track out

	lda  jobnum
	asl  a
	tax
	lda  dirtrk     ; *2
	sta  hdrs,x	; read back BAM side zero
	jsr  doread	; done
	pla
	ldx  jobnum
	sta  lstjob,x	; restore last job
	rts
;*****************************************************

bmindx  .byte 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54
	.byte 57,60,63,66,69,72,75,78,81,84,87,90,93,96,99,102

;----------------------------------------------------
;
; PATCHES  David G Siracusa - Commodore (c) 1985
;
; Compatibility is fun...
; I know you can say fun... I know you can...
;
;----------------------------------------------------
;
;     patch 18  *rom ds 01/21/85*
;
ptch18  lda  pota1	; 1/2 Mhz ?
	and  #$20
	beq  +

	ldy  #0		; clr regs
	ldx  #0
	lda  #1		; place filename
	sta  filtbl
	jsr  onedrv	; setup drv
	jmp  rtch18	; ret

+	lda  #$8d	; 1541 mode
	jsr  parse
	jmp  rtch18	; ret
;
;
;----------------------------------------------------
;
;     patch 19  *rom ds 01/21/85*
;
ptch19	jsr  parsxq	; parse & xeq cmd
	jsr  spinp	; input
	lda  fastsr	; clr error
	and  #$7f
	sta  fastsr
	jmp  rtch19
;
;
;----------------------------------------------------
;
;     patch 20  *rom ds 01/21/85*
;
ptch20	lda  #255
	sta  acltim
	lda  #6		; setup timer2
	sta  acltim2
	rts
;
;
;----------------------------------------------------
;
;     patch 21  *rom ds 01/21/85*
;
ptch21	.proc
	bne  m1

	lda  mtrcnt	; anything to do ?
	bne  m2
	beq  m3

m1	lda  #255
	sta  mtrcnt	; irq * 255
	jsr  moton	; turn on the motor

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jsr  ptch72	; *** rom ds 05/20/86 ***
	nop
;	lda  #1
;	sta  wpsw

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	bne  m3		; bra

m2	dec  mtrcnt
	bne  m3

	lda  drvst
	bne  m3

	jsr  motoff	; turn off the motor

m3	jmp  rtch21	; return
	.pend
;
;
;----------------------------------------------------
;
;     patch 22
;
ptch22  lda  #2
	sta  pb
	lda  #$20	; *,_atn,2 mhz,*,*,side 0,sr-in,*
	sta  pa1
	jmp  ptch22r	; ret
;
;
;----------------------------------------------------
;
;     patch 23
;
;
ptch23  lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jmp  doread	; 1541 mode read BAM side 0

+	lda  maxtrk	; seek ok, on other side ?
	cmp  #37
	bcc  -		; seek regular method

	jsr  sav_pnt	; save pointers

	lda  #0
	sta  bmpnt	; even page
	ldx  jobnum
	lda  bufind,x	; which buffer is it in
	sta  bmpnt+1
	lda  #$ff

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jmp  ptch70	; *** rom ds 05/14/86 ***
;	sta  jobrtn	; error recovery on
rtch70			; ret

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	lda  jobnum
	asl  a
	tax
	lda  #53	; read BAM side one
	sta  hdrs,x	; put track in job queue, same sector
	jsr  doread	; read it
	cmp  #2		; ok ?
	ror  a		; carry set bad return
	and  #$80	; isolate sign bit
	eor  #$80
	sta  dside
	bpl  +		; br, error

	ldy  #104
-	lda  (bmpnt),y	; get BAM 1 and put somewhere in God's country
	sta  ovrbuf+$46,y
	dey
	bpl  -

+
	lda  #$ff
	sta  jobrtn	; set error recovery on

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

rtch70a

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	lda  jobnum
	asl  a
	tax
	lda  dirtrk	; read BAM side zero
	sta  hdrs,x	; put track in job queue, same sector
	jsr  doread	; read it
	cmp  #2
	bcc  +

	tax		; save error
	lda  #36
	sta  maxtrk	; def single sided
	jsr  res_pnt	; save BAM pointers
	txa
	jsr  error      ; let the error handler do the rest
	jmp  rec7	; consist

+	ldy  #3
	lda  (bmpnt),y	; check double sided flag
	and  dside	; both must be ok....
	bmi  +

	lda  #36
	.byte skip2
+	lda  #71
	sta  maxtrk	; double sided

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jmp  ptch69	; *** rom ds 05/14/86 fix swap problem ***
;	jmp  res_pnt	; restore BAM pointers

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;
;----------------------------------------------------
;
;     patch 24
;

ptch24  .proc
	jsr  dojob	; seek side zero
	pha		; save status
	cmp  #2		; error ?
	bcs  m1		; br, error...

	lda  pota1
	and  #$20
	beq  m1		; 1/2 Mhz ?

	lda  #71
	sta  maxtrk	; let DOS think he has double sided capability

	lda  #$ff
	sta  jobrtn	; return from error
	lda  header	; get id's
	pha
	lda  header+1
	pha		; save them

	lda  jobnum
	asl  a
	tax
	lda  #53	; seek side one BAM track
	sta  hdrs,x	; put track in job queue, same sector
	lda  #seek

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

;	jsr  dojob	; try it...
	jsr  ptch64 	; make it faster...

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	cmp  #2		; error ?

	pla
	tay		; header+1
	pla
	tax		; header
	bcs  m2		; error on last job ?

	cpx  header	; same id's ?
	bne  m2

      	cpy  header+1	; same id's ?
	bne  m2

	lda  #71	; probably double sided
	.byte skip2
m2	lda  #36
	sta  maxtrk

	sty  header+1	; restore original id's from side zero
	stx  header

	lda  jobnum
	asl  a
	tax
	lda  dirtrk
	sta  hdrs,x	; put track in job queue, same sector

m1	pla		; get status
	rts
	.pend
;
;
;----------------------------------------------------
;
;     patch 25
;
ptch25 	jsr  setbpt	; setup bit map pointer
	lda  pota1
	and  #%00100000 ; 1/2 Mhz ?
	beq  +

	lda  #0
	ldy  #104	; clr BAM side one
-	sta  ovrbuf+$46,y
	dey
	bpl  -

+	jmp  rtch25	; return
;
;
;----------------------------------------------------
;
;     patch 26
;
otcrgkqo = ptch26
ptch26  .proc
	pha		; save .a
	lda  pota1
	and  #%00100000 ; 1/2 Mhz ?
	beq  m1

	pla
	cmp  #36	; > trk 35 ?
	bcc  m2

	sbc  #35
	.byte skip1
m1	pla		; restore .a
m2	ldx  nzones	; cont
	rts
	.pend
;
;
;----------------------------------------------------
;
;     patch 27
;
ptch27  jsr  clrbam	; clear BAM area
	lda  pota1
	and  #%00100000
	bne  +		; 1/2 Mhz ?

	lda  #36
	.byte skip2
+	lda  #71
	sta  maxtrk	; set maximum track full format
	jmp  rtch27	; return
;
;
;----------------------------------------------------
;
;     patch 28
;
ptch28  lda  pota1
	and  #%00100000
	bne  +		; 1/2 Mhz ?

	jmp  format	; 1541 mode

+       jmp  jformat	; 1571 mode
;
;
;----------------------------------------------------
;
;     patch 29
;
ptch29  lda  pa1	; change to 1 mhz
	and  #%11011111
	sta  pa1
	jsr  jslowd	; wait for ...

	lda  #$7f
	sta  icr	; clear all sources of irq's
	lda  #8
	sta  cra	; turn off timers
	sta  cra+1	; off him too...

	lda  #0		; msb nil
	sta  tima_h
	lda  #6		; msb nil
	sta  tima_l	; 6 us bit cell time
	lda  #1
	sta  cra	; start timer a
	jsr  spinp	; finish up and enable irq's from '26
	jmp  tstatn	; chk for atn & goto xidle
;
;
;----------------------------------------------------
;
;     patch 30
;
ptch30
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;	lda  pota1
	jsr  ptch57	; *** rom ds 08/05/85 ***, serial bus fix for a
			; very old bug.
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
	and  #%00100000
	beq  +		; 1/2 Mhz ?

	jmp  jatnsrv	; 2 Mhz
+	jmp  atnsrv	; 1 Mhz
;
;
;----------------------------------------------------
;
;     patch 31
;
ptch31	sei
	ldx  #topwrt	; set stack pointer
	txs
	jmp  rtch31
;
;
;----------------------------------------------------
;
;     patch 32
;
ptch32  lda  pota1	; 1/2 Mhz ?
	and  #$20
ptch32a .proc
	bne  m1

m6	ldy  #3
	lda  #0
	sta  (bmpnt),y	; set single sided bit in BAM side 0
	jmp  newmap	; finish up 1541 mode

m1	lda  maxtrk	; single/double sided?
	cmp  #37
	bcc  m6

	ldy  #1
	ldx  #0
m2	cpy  #18
	beq  m4

	txa
	pha		; save .x
	lda  #0		; start temps at zero
	sta  t0
	sta  t1
	sta  t2
	lda  num_sec-1,y
	tax		; number of sectors per track
-	sec
	rol  t0
	rol  t1
	rol  t2
	dex
	bne  -

	pla
	tax		; restore .x

	lda  t0		; write BAM side one
	sta  ovrbuf+$46,x
	lda  t1
	sta  ovrbuf+$46+1,x
	lda  t2
	sta  ovrbuf+$46+2,x
	inx
	inx
	inx
	cpx  #$33	; skip track 53
	bne  m4

	inx
	inx
	inx
	iny		; bypass and leave allocated

m4	iny
	cpy  #36
	bcc  m2

	jsr  newmap	; generate new BAM for side zero

	ldy  #3
	lda  #$80
	sta  (bmpnt),y	; set double sided bit in BAM side 0

	ldy  #$ff
	ldx  #34
-	lda  num_sec,x	; get # of free sectors
	sta  (bmpnt),y	; save in top end of BAM zero
	dey		; => $dd-$ff
	dex
	bpl  -

	ldy  #$ee	; offset for track 53
	lda  #0
	sta  (bmpnt),y	; allocate track 53

	jmp  nfcalc	; calculate BAM side 0/1
        .pend
;
;
;----------------------------------------------------
;
;     patch 33
;
oeunttn = ptch33
ptch33  .proc
	lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jsr  freuse	; track < 36 or 1541 mode
	jmp  frets2	; ret

+	lda  track	; is track greater than 35
	cmp  #36
	bcc  -

	jsr  set_bm	; setup & update parms
	jsr  bam_pt	; find position within table
	bne  +

	ora  bmask,x	; set it free
	sta  ovrbuf+$46,y
	jsr  dtybam	; set dirty flag
	jsr  deall_b	; deallocate BAM
	lda  track
	cmp  #53	; skip BAM track side one
	beq  m4

	lda  drvnum	; get drv #
	asl  a
	tax		; *2
	jmp  fre20	; ret
+	sec
m4	rts
        .pend
;
;
;----------------------------------------------------
;
;     patch 34
;
ptch34	lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jsr  freuse	; track < 36 or 1541 mode
	jmp  rtch34

+	lda  track	; check track
	cmp  #36
	bcc  -

	jsr  set_bm	; setup & update parms
	jsr  bam_pt	; find position within the BAM
	beq  +

	eor  bmask,x	; set it used
	sta  ovrbuf+$46,y
	jsr  dtybam	; set dirty flag
	jsr  alloc_b	; allocate BAM
	lda  track
	cmp  #53	; skip BAM track side one
	beq  +

	lda  drvnum	; get drv #
	asl  a
	tax
	jmp  use30
+	rts
;
;
;----------------------------------------------------
;
;     patch 35
;

ptch35  .proc
	lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jsr  setbam	; track < 36 or 1541 mode
	jmp  rtch35

+	lda  track	; check track
	cmp  #36
	bcc  -

	jsr  set_bm	; setup & update parms
	jsr  chk_blk	; chk alloc w/ bits

	lda  num_sec,y  ; get number of sectors on this track
	sta  lstsec	; & save it
-	lda  sector	; what sector are we looking at ?
	cmp  lstsec
	bcs  +

	jsr  bam_pt	; check availability
	bne  m6

	inc  sector	; we will find something I hope...
	bne  -

+	lda  #0
m6	rts		; (z=1) used
        .pend
;
;
;----------------------------------------------------
;
;     patch 36
;
ptch36  lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	lda  temp
	pha
	jmp  rtch36

+	lda  track	; check track
	cmp  #36
	bcc  -

	cmp  #53
	beq  +

	lda  temp
	pha		; save temp var
	jsr  set_bm	; setup & update parms
	tay		; save .a
	pla
	sta  temp	; restore temp
	tya		; return allocation status in .a
	jmp  rtch36a

+	lda  #0		; z=1
	jmp  rtch36a	; track 53 allocated
;
;
;----------------------------------------------------
;
;     patch 37
;
ptch37  lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jsr  setbam	; setup the BAM pointer
	jmp  rtch37	; ret

+	lda  track	; check track
	cmp  #36
	bcc  -

	jsr  set_bm	; setup & update parms
	jmp  rtch37a
;
;
;----------------------------------------------------
;
;     patch 38
;
ptch38  lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jsr  setbam	; setup the BAM pointer
	jmp  rtch38	; ret

+	lda  track	; check track
	cmp  #36
	bcc  -

	jsr  set_bm	; setup & update parms
	jmp  rtch38a
;
;
;----------------------------------------------------
;
;     patch 39
;
ptch39	lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

-	jmp  avck	; check block availability

+	lda  maxtrk	; check maximum track
	cmp  #37
	bcc  -

	lda  track	; check track do regular check
	cmp  #36
	bcc  -

	jmp  chk_blk	; finish up
;
;
;----------------------------------------------------
;
;     patch 40
;
oteunho = ptch40
ptch40  .proc
	sta  ndbl,x	; save low order
	lda  pota1	; 1/2 Mhz ?
	and  #$20
	beq  m1

	lda  maxtrk	; check maximum track
	cmp  #37
	bcc  m1

	jsr  sav_pnt	; save pointers
	jsr  where	; locate BAM

	ldy  #34	; count backwards and sleep........zzzzZZZZZZZZ
	lda  ndbl
-	clc
	adc  (bmpnt),y	; count it up
	sta  ndbl	; keep track HAHA !!!
	bcc  +

	inc  ndbh	; increment msb
+	dey
	bpl  -

	jmp  res_pnt	; restore pointers

m1	rts		; done
        .pend
;
;
;----------------------------------------------------
;
;     patch 41
;
ptch41  sta  nbkl,x
	sta  nbkh,x
	lda  #0
	sta  lstchr,x
	rts
;
;
;----------------------------------------------------
;
;     patch 42
;
ptch42  jsr  jformat	; format disk in GCR
	ldy  #0
	sty  jobrtn
	rts
;
	*=*+11		; address adjust
;
;
;----------------------------------------------------
;
;     patch 43
;
;
ptch43  lda  #0		; clr nodrv
	#NODRWR		; write nodrv,x absolute
	jmp  rtch43
;
;
;----------------------------------------------------
;
;     patch 44
;
;
ptch44  tya		; set/clr nodrv
	#NODRWR		; write nodrv,x absolute
	jmp  rtch44
;
;
;----------------------------------------------------
;
;     patch 45
;
ptch45  lda  pota1	; 1/2 Mhz ?
	and  #$20
	beq  +

	jmp  a2		; 1571 mode
+	jmp  atns20	; 1541 mode
;
;
;----------------------------------------------------
;
;     patch 46
;
ptch46	pha		; save error
	stx  jobnum	; save job #
	lda  pota1	; 1/2 Mhz ?
	and  #$20
	beq  +

	bit  fastsr	; error recovery on ?
	bpl  +

	lda  fastsr
	and  #$7f	; clr error recovery
	sta  fastsr

	pla		; get error
	tax
	jmp  ctr_err	; let it error out

+	jmp  rtch46	; return
;
;
;----------------------------------------------------
;
;     patch 47
;
ptch47	pha		; save error
	lda  pota1	; 1/2 Mhz ?
	and  #$20
	beq  +

	bit  fastsr	; error recovery on ?
	bpl  +

	lda  fastsr
	and  #$7f	; clr error recovery
	sta  fastsr
	sei
	ldx  #2
	jsr  handsk	; send it
	lda  #0
	sta  sa
	jsr  close	; close channel

+	pla		; get error #
	jmp  cmder2
;
;
;----------------------------------------------------
;
;     patch 48
;
ptch48  lda  #0
	sta  drvst	; clr drive status
	lda  pcr2	; set edge and latch mode
	jmp  rtch48
;
;
;----------------------------------------------------
;
;     patch 49
;
ptch49  .proc
	lda  cmdbuf	; is there a 'U0n' cmd waiting in the wings
	cmp  #'U'
	bne  m1		; br, no 'U'

	lda  cmdbuf+1
	cmp  #'0'
	beq  m2		; br, we got it toyota

m1	lda  cmdbuf,y	; get char
	.byte skip2
m2	lda  #0		; null
	rts
        .pend
;
;
;----------------------------------------------------
;
;     patch 50
;
ptch50	ldx  drvnum	; get offset
	#NODRRD		; read nodrv,x absolute
	rts
;
;
;----------------------------------------------------
;
;     patch 51
;
ptch51	sta  wpsw,x	; clr wp switch
	#NODRWR		; write nodrv,x absolute
	jmp  rtch51
;
;
;----------------------------------------------------
;
;     patch 52
;
ptch52	ldx  drvnum	; get offset
	#NODRRD		; read nodrv,x absolute
	jmp  rtch52
;
;
;----------------------------------------------------
;
;     patch 53
;
ptch53  lda  ip
	cmp  #<sysirq	; irq ?
	bne  +

	lda  ip+1
	cmp  #>sysirq	; irq ?
	bne  +

	brk		; do irq and return
	nop
	rts

+	jmp  (ip)
;
;
;----------------------------------------------------
;
;     patch 54
;
ptch54  cmp  #2		; error ?
	bcc  +

	cmp  #15	; no drv condition ?
	beq  +

	jmp  rtch54	; bad, try another
+	jmp  stl50	; ok
;
;
;----------------------------------------------------
;
;     patch 55
;
ptch55  sta  ftnum	; clear flag
	jsr  led_on	; lights on
	jsr  ptch42	; format it
	pha		; save error
	jsr  led_off	; turn off the lights
	pla
	rts
;
;
;----------------------------------------------------
;
;     patch 56
;
ptch56  lda  pattyp	; check file type
	and  #typmsk	; remove other bits
	cmp  #2
	rts
;
;
;----------------------------------------------------
;
;     patch 57
;
ptch57  lda  pota1	; 1/2 Mhz ?
	bit  pa1	; clear h/w interrupt source
	rts
;
;
;----------------------------------------------------
;
;     patch 58
;
ptch58  lda  pota1	; 1/2 Mhz ?
	and  #$20
	bne  +

	jmp  newmap	; finish up 1541 mode

+	jmp  ptch32a	; bra, go doit !!!
;
;
;----------------------------------------------------
;
;     patch 59
;
ptch59  lda  #2
	sta  t1hc1	; wait 256 uS
	rts
;
;
;----------------------------------------------------
;
;     patch 60
;
ptch60  lda  vertog	; verify ?
	bne  +		; br, no verify

	jmp  cmdele	; doit

+	clc		; say ok...
	rts
;
;
;----------------------------------------------------
;
;     patch 61
;
ptch61	tay
	cmp  #'V'	; fast read ?
	bne  devs

	sei		; no irq's
	lda  pota1
	and  #$20
	bne  +

-	jmp  utlbad	; 1571 only

+	lda  cmdbuf+4	; which ?
	cmp  #'1'
	beq  +

	cmp  #'0'
	bne  -		; no switch specified

+	and  #$ff-$30
	sta  vertog	; save flag
	cli
	rts

devs	cpy #4
	jmp  rtch61
;
;
;----------------------------------------------------
;
;     patch 62
;
ptch62	lda  vertog	; to verify or not to verify ?
	bne  +

	lda  jobs,y	; get job
	.byte skip2
+	lda  #$30	; verify is off
	eor  #$30
	sta  jobs,y
	bne  +

	jmp  jerrr	; done

+	jmp  jseak	; return
;
;
;----------------------------------------------------
;
;     patch 63
;
ptch63	jsr  hskrd	; send interleave
	lda  #bit5
	bit  switch	; send sector table ?
	beq  +

	ldy  #0
-	lda  cmdbuf+11,y
	sta  ctl_dat	; get ready to send
	jsr  hskrd	; send it
	iny
	cpy  cpmsek	; send whole thing
	bne  -

+	rts		; done
;
;
;----------------------------------------------------
;
;     patch 64
;
ptch64	ldx  jobnum	; get job #
	ora  #$08	; sector seek...
	sta  jobs,x
	jmp  stbctl	; this better work!!!
;
;
;----------------------------------------------------
;
;     patch 65
;
ptch65
	jsr  burst_doit
	jmp  endcmd

Burst_doit
	jmp  (ip)
;
;
;----------------------------------------------------
;
;     patch 66
;
ptch66
	cmp  #3
	bcs  +

	lda  #dskful
	jsr  errmsg

+	lda  #1
	rts
;
;
;----------------------------------------------------
;
;     patch 67
;
ptch67
	php
	sei
	lda  #0
	sed
-	cpx  #0
        beq  +

        clc
        adc  #1
        dex
        jmp  -
+	plp
	jmp  hex5
;
;
;----------------------------------------------------
;
;     patch 68
;
ptch68
	php
	sei
	sta  sdr	; send it
        lda  fastsr
        eor  #4         ; change state of clk
        sta  fastsr
        lda  #8
-	bit  icr	; wait transmission time
        beq  -

	plp
        rts
;
;
;----------------------------------------------------
;
;     patch 69
;
ptch69  .proc
	lda  maxtrk	; double sided?
	cmp  #37
	bcc  m5

	lda  temp
	pha		; save temp
	lda  track
	pha
	ldy  #0
	sty  track
m1	lda  #0
	sta  temp	; start at zero
	lda  #>bam_one
	sta  bmpnt+1	; msb
	lda  bmindx,y	; starts here
	clc
	adc  #<bam_one	; add offset
	sta  bmpnt

	ldy  #2
m2	ldx  #7		; verify bit map to count value
-	lda  (bmpnt),y
	and  bmask,x
	beq  +

	inc  temp	; on free increment
+	dex
	bpl  -

	dey
	bpl  m2

	jsr  where	; where is the BAM
	lda  temp
	ldy  track
	sta  (bmpnt),y
	inc  track
	ldy  track
	cpy  #35
	bcc  m1		; check side one

	pla
	sta  track	; restore track,
	pla
	sta  temp	; temp,
m5	jmp  res_pnt	; and bam pointers
        .pend
;
;
;----------------------------------------------------
;
;     patch 70
;
ptch70
	sta  jobrtn
	pha
	lda  swapfg	; read bam one?
	beq  +

	lda  #0
	sta  swapfg	; clr it
	pla
	jmp  rtch70	; yes

+	lda  #$80
	sta  dside
	pla
	jmp  rtch70a	; nope
;
;
;----------------------------------------------------
;
;     patch 71
;
ptch71
	jsr  sav_pnt
	jsr  ptch69	; we can rebuild 'em, we have the technology!
	jmp  sav_pnt
;
;
;----------------------------------------------------
;
;     patch 72
;
ptch72
	lda  #1
	sta  wpsw
	sta  swapfg	; mark bam one out of memory
	rts
;
;
;----------------------------------------------------
;
;     patch 73
;
ptch73
	lda  #1		; BAM is out of mem
	sta  swapfg
	jmp  ptch23	; continue on...
;
;
;----------------------------------------------------
;
;   patch 74
;
;
ptch74
	lda  #1
	sta  wpsw
	sta  swapfg
	jmp  initdr

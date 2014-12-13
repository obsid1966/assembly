
;bit   7   -           test track
;bit   6   -           test sector
;bit   5   -           test write protect switch
;bit   4   -           motor on
;bit   3   -           seek to track
;bit   2   -           wait for motor up to speed
;bit   1   -           logical seek
;bit   0   -           error return

cmdinf   .byte  $00,$15,$00,$00,$00,$15,$00,$bc
         .byte  $34,$de,$fe,$dc,$15,$15,$00

cmdjmp   .word    cmdzer         ; reset
         .word    cmdone         ; bump
         .word    cmdtwo         ; wp status
         .word    cmdthr         ; setup for step
         .word    cmdfor         ; reserved
         .word    cmdfve         ; read address
         .word    seke           ; seek physical
         .word    cmdsev         ; format track
         .word    cmdeig         ; format disk
         .word    cmdnin         ; read sector
         .word    cmdten         ; write sector
         .word    cmdele         ; verify
         .word    cmdtwv         ; verify format
         .word    cmdthi         ; create sector table
         .word    diskin         ; is the disk home ?

cmdis    =  *-cmdjmp
prcmd   sei
        pha             ; save cmd
        tax
        lda  cmdinf,x   ; get information
        sta  info
        lda  dkmode
        ora  #$80       ; mfm mode
        sta  dkmode

        asl  info       ; check track
        bcc  prc00

        lda  cmdbuf+3
        sta  cmd_trk    ; save track
prc00   asl  info       ; check sector
        bcc  prc01

        lda  cmdbuf+4
        sta  sectr      ; save sector
prc01   asl  info       ; check wp for write jobs
        bcc  prc02

        lda  dskcnt
        and  #$10
        bne  prc02

        lda  switch     ; set kill job switch
        ora  #%00001000
        sta  switch     ; wp error
        ldx  #8
        stx  ctl_dat

prc02   asl  info       ; motor on ?
        bcc  prc03

        jsr  stmtr      ; start motor
prc03   asl  info       ; seek ?
        bcc  prc04      ; seek physical while motor is spinning

        jsr  seke       ; seek job
prc04   asl  info       ; wait for motor up to speed ?
        bcc  prc05

        jsr  wtmtr      ; go and wait

; disk up to speed

prc05   jsr  sel_sid    ; select
        asl  info       ; logical seek required ?
        bcc  prc06

        jsr  s_log      ; seek by reading

; disk up to speed and on track

prc06   lda  #0
        pla             ; get jobs
        asl  a
        tax
        lda  cmdjmp,x   ; do indirect
        sta  temp
        lda  cmdjmp+1,x
        sta  temp+1

        jsr  do_the_command

        jsr  trnoff     ; motor off...

        ldx  mfmcmd
        cpx  #2
        php

        asl  info
        bcs  prc07

        plp
        bcc  prc08

        jmp  exbad

prc07   plp             ; restore status

prc08   rts

do_the_command  jmp  (temp)



;******************************************************

moton   php             ; no irq's
        sei
        lda  dskcnt
        ora  #4
        sta  dskcnt
        plp             ; retrieve status
        rts

;******************************************************

motoff  php             ; no irq's
        sei
        lda  dskcnt
        and  #$ff-$04
        sta  dskcnt
        plp             ; retrieve status
        rts

;******************************************************

led_on  php             ; no irq's
        sei
        lda  dskcnt     ; turn on led
        ora  #8
        sta  dskcnt
        plp             ; retrieve status
        rts

;******************************************************

led_off php             ; no irq's
        sei
        lda  dskcnt     ; turn led off
        and  #$ff-$08
        sta  dskcnt
        plp             ; retrieve status
        rts

;******************************************************

stmtr   .proc
        php
        sei
        lda  drvst
        bmi  m2         ; accelerating ?

        and  #bit5+bit4
        beq  m1

        lda  #$20       ; disk up to speed
        sta  drvst
m2      plp
        rts

m1      plp
        sta  cdrive     ; set drive
        jmp  turnon     ; turn on motor
        nop
        nop
        nop
        nop
        nop
        nop
        .pend

;******************************************************

wtmtr   php             ; wait for motor up to speed
        cli
wtmtr1  lda  drvst
        cmp  #$20       ; drv ready ?
        bne  wtmtr1

        plp
        rts

;******************************************************

seke    php             ; wait for not busy
        cli             ; enable irqs for motor on timing
        lda  cmd_trk
        asl  a          ; half steps
        cmp  cur_trk    ; correct track ?
        beq  sekrtn     ; br, yep

seklop  lda  cmd_trk    ; where
        asl  a
        cmp  cur_trk
        beq  sekdun

        bcs  sekup      ; hi or lo ?

sekdn   jsr  stout      ; step out
        jmp  seklop     ; next

sekup   jsr  stin       ; step in
        jmp  seklop     ; next also

sekdun  ldy  #$10       ; settle
        jsr  xms        ; delay

sekrtn  plp
        rts

;******************************************************

stin    lda  cur_trk    ; get current valuestep
        clc
        adc  #1
        jmp  stpfin     ; half step out

stout   .proc
        ldy  #99        ; wait for trk_00
-       lda  pota1      ; check for trk_00
        ror  a          ; rotate into carry
        php             ; save carry
        lda  pota1      ; debounce it
        ror  a          ; carry <=
        ror  a          ; bit 7 <=
        plp             ; retrieve carry
        and  #$80       ; set/clear sign bit
        bcc  m3         ; on track zero

        bpl  +          ; carry set(off) & sign(on) exit

        bmi  m4         ; bra

m3      bmi  +          ; carry clear(on) & sign(off) exit

m4      dey
        bne  -          ; continue

        bcs  +          ; br, not track 00 ?

        lda  dskcnt     ; phase 0
        and  #3
        bne  +

        lda  #0         ; trk zero
        sta  cur_trk    ; current trk = 40*2/0
        rts

+       lda  cur_trk    ; get current half step
        sec
        sbc #1
        .pend

stpfin  sta  cur_trk    ; save
        and  #3         ; strip unused
        sta  temp
        php             ; no irq's
        sei
        lda  dskcnt
        and  #$fc       ; strip step bits
        ora  temp
        sta  dskcnt
        plp             ; retrieve status
        ldy  #$06       ; 6 ms step time, 16 ms settle

xms     jsr  onems      ; delay 1 ms
        dey
        bne  xms

        rts


;******************************************************

onems   ldx  #2
        lda  #$6f       ; *** rom ds 12/27/85 ***, beta9 1 mS.
onems1  adc  #1
        bne  onems1

        dex
        bne  onems1

        rts


;******************************************************


cvstat  #WDTEST         ; chk address
        lda  wdstat     ; retrieve status
        lsr  a
        lsr  a
        lsr  a
        and  #3         ; check status
        tax
        lda  mfmer,x
        sta  mfmcmd
        tax
        rts

;******************************************************

strtwd  pha             ; save accum
        jsr  led_on     ; act led on
        pla
        #WDTEST         ; chk address
        sta  wdstat     ; send cmd to wd 1770
        lda  #1         ; wait for busy
        #WDTEST         ; chk address
-       bit  wdstat
        beq  -

        jmp  jslower    ; WD1770 bug ????


;******************************************************

waitdn  jsr  led_off    ; act led off
        lda  #1         ; wait for unbusy
        #WDTEST         ; chk address
-       bit  wdstat
        bne  -

        rts


;******************************************************

sectnx  lda  minsek
        sec
        sbc  #1
        sta  ctl_dat    ; save min sector - 1
        lda  cmdbuf+4   ; get original sector
        clc
        adc  cpmit      ; next sector
        cmp  maxsek
        beq  +          ; equal to or

        bcc  +          ;          less than

        sbc  maxsek     ; rap around
        clc
        adc  ctl_dat    ; add min now
+       sta  cmdbuf+4   ; next sector for controller
        rts


;******************************************************

sectcv  ldy  #0
        ldx  #0
        lda  cmdbuf+3   ; start at sector x
        and  #$3f       ; delete mode bit & table bit
        sta  cmdbuf+3
        sta  minsek     ; new min
        pha             ; save ss
        lda  cmdbuf+7   ; save ns
        pha
        inc  cmdbuf+4   ; interleave + 1

sectop  lda  cmdbuf+3   ; ss
        sta  cmdbuf+11,y ; table goes to cmdbuf+42
        inc  cmdbuf+3   ; increment ss
        inx
        tya             ; do addition
        clc
        adc  cmdbuf+4   ; add interleave
        tay
        cpy  #32        ; no more room
        bcs  bd_int

        cpy  cmdbuf+7   ; ns
        bcc  secles     ; < than

        bne  seclmo     ; can't be equal until the end

        cpx  cmdbuf+7   ; ns end ?
        beq  seclmo

bd_int  dec  cmdbuf+4   ; restore
        pla
        sta  cmdbuf+7   ; restore ns
        pla
        sta  cmdbuf+3   ; restore ss

        sec
        rts             ; bad exit

seclmo  tya
        sec
        sbc  cmdbuf+7   ; ns
        tay

secles  cpx  cmdbuf+7   ; ns
        bne  sectop

        stx  cpmsek     ; ns
        dex
        txa
        clc
        adc  minsek     ; find max
        sta  maxsek     ; new max
        cmp  minsek     ; better be less than max
        bcc  bd_int     ; bad starting sector

        pla
        sta  cmdbuf+7   ; restore ns
        pla
        sta  cmdbuf+3   ; restore ss
        dec  cmdbuf+4   ; restore

        clc             ; ok exit
        rts


;******************************************************


verfmt  lda  mfmcmd
        pha             ; save current logical track

        ldy  #0
        sty  mfmhdr     ; init index into sector table
ver_fm  ldy  mfmhdr     ; get current index
        lda  cmdbuf+11,y
        sta  wdsec      ; setup sector for wd 1770
        jsr  cmdtwv     ; verify
        ldx  mfmcmd     ; get error
        cpx  #2
        bcs  ver_00

        inc  mfmhdr     ; next entry in sector table
        ldy  mfmhdr
        cpy  cmdbuf+7   ; check with ns
        bne  ver_fm     ; done ?

        clc
        .byte  skip1
ver_00  sec
        pla
        sta  mfmcmd     ; restore track address
no_trk  rts


;******************************************************

chcsee  lda  cmdsiz
        cmp  #7         ; next track parameter given ?
        bcc  no_trk

        lda  cmdbuf+6   ; get nt
        sta  cmd_trk
        jmp  seke


;******************************************************


s_log   .proc
        lda  mfmcmd     ; save command
        pha
        jsr  cmdfiv     ; where are we?
        ldx  mfmcmd     ; status ok?
        cpx  #2
        bcc  m1         ; see if we are there...

        jsr  cmdone     ; restore to trk_00
        jsr  cmdfiv     ; where are we.. better be track 00
        ldx  mfmcmd     ; status ok?
        cpx  #2
        bcs  m2         ; on error leave on track 00

m1      lda  cmd_trk    ; we there yet ?
        asl  a
        cmp  cur_trk    ; are we on ?
        beq  m2

        jsr  seke       ; find it...should be there now...hope?

m2      pla
        sta  mfmcmd     ; restore command
        rts
        .pend

;******************************************************


sel_sid php             ; no irq's
        sei
        lda  switch
        and  #%00010000 ; check side
        cmp  #%00010000 ; set/clr carry
        jsr  set_side   ; set h/w
        plp             ; retrieve status
        rts

;******************************************************

maxmin  ldy  cpmsek     ; get ns
        dey             ; one less
        lda  #255       ; as small as min can get
minim   cmp  cmdbuf+11,y
        bcc  no_min     ; br, no change

        lda  cmdbuf+11,y
no_min  dey
        bpl  minim

        sta  minsek     ; save min

        ldy  cpmsek
        dey             ; one less
        lda  #0         ; as small as max can get
maxim   cmp  cmdbuf+11,y
        bcs  no_max     ; br, no change

        lda  cmdbuf+11,y
no_max  dey
        bpl  maxim

        sta  maxsek     ; save max
        rts

;******************************************************

fn_int  ldx  cpmsek     ; location of min
        ldy  #0         ; start in beginning
fn_000  lda  cmdbuf+11,y
        cmp  minsek
        beq  fn_001     ; min ?

        iny
        cpy  cpmsek
        bne  fn_000

fn_001  sty  ctl_cmd    ; save index
        lda  minsek     ; get min
        clc
        adc  #1         ; add one to it
        sta  ctl_dat    ; save min + 1

        ldx  #255       ; interleave at zero
fnlook  lda  cmdbuf+11,y
        cmp  ctl_dat    ; find min + 1 ?
        beq  fn_002

        inx             ; cpmit = cpmit + 1
        iny
        cpy  cpmsek     ; index here ?
        bne  fnlook

        ldy  #0         ; rap around
        beq  fnlook     ; bra

fn_002  rts             ; return with hard interleave in .x


;******************************************************


diskin  .proc
        lda  temp
        pha             ; save temp
        php             ; save status
        sei             ; no irq's
        lda  wdtrk      ; where are we ?
        sta  wddat      ; here we are..
        lda  #$18
        jsr  strtwd     ; seek cmd
        jsr  waitdn     ; fin ?
        ldx  #0
        ldy  #128       ; wait a little more than a revolution
        #WDTEST         ; chk address
        lda  wdstat     ; get start status
        and  #2
        sta  temp       ; save current status
        #WDTEST         ; chk address
-       lda  wdstat     ; get current status
        and  #2
        cmp  temp       ; same go on
        beq  +

        plp             ; retrieve status
        jmp  m4         ; finish up ok disk inserted

+       dex
        bne  -

        dey
        bne  -          ; timout ?

        plp             ; retrieve status
        sec             ; exit no index sensor toggling
        .byte skip1
m4      clc             ; ok
        pla
        sta  temp       ; restore temp
        rts
        .pend

;

reset_ctl .proc         ; reset disk controller

        ldy  #all
        jsr  xms        ; no access for 500 mS
        ldy  #all
        jsr  xms        ; *

        lda  #bit7
        sta  cachetrk   ; *
        lda  #0
        sta  dirty
        jsr  psetdef
        jsr  setdef

        lda  #$4e
        sta  ctltimh
        lda  #$20
        sta  ctltiml    ; IRQ's
        jsr  resetim    ; reset controller timers
        lda  #$08       ; setup wd177x commands
        sta  wdrestore
        lda  #$18
        sta  wdseek
        lda  #$28
        sta  wdstep
        lda  #$48
        sta  wdstepin
        lda  #$68
        sta  wdstepout
        lda  #$88
        sta  wdreadsector
        lda  #$aa
        sta  wdwritesector
        lda  #$c8
        sta  wdreadaddress
        lda  #$e8
        sta  wdreadtrack
        lda  #$fa
        sta  wdwritetrack
        lda  #$d0
        sta  wdforceirq

        lda  #18
        sta  setval     ; 18 mS
        ldy  #all       ; test registers
m1      sty  wdtrk
        sty  wdsec
        sty  wddat
        jsr  delay16
        cpy  wdtrk
        bne  m3

        cpy  wdsec
        bne  m3

        cpy  wddat
        bne  m3

        dey
        bne  m1

        jsr  wdabort    ; abort the wd17xx
        lda  #0
        sta  todlsb
        jsr  delay40    ; wait for 40 uS
        lda  todlsb
        bne  m2         ; default wd1770

        inc  wdrestore
        inc  wdseek
        inc  wdstep
        inc  wdstepin
        inc  wdstepout

m2      bne  okdone     ; bra

m3      lda  #$0d       ; controller error
        .byte skip2
        .pend
okdone  lda  #0         ; ok
done    jmp  errr
;

moton_ctl               ; motor on with spinup sequence

        jmp  okfin      ; done

;

motoff_ctl              ; motor off with spin down sequence

        jmp  okdone     ; turn off the motor

;

motoni_ctl              ; motor on

        jsr  moton      ; turn on the motor
okfin   lda  #0
fin     ldy  nextjob
        sta  jobs,y     ; mimick errr w/o spindown
        lda  #bit7
        sta  nextjob    ; clear job flag
        ldy  #numjob
        jmp  erret

;

motoffi_ctl             ; motor off

        jsr  motoff     ; turn it off
        jmp  okfin

;

seek_ctl                ; move physical

        lda  cmdtrk     ; we on track yet?
        cmp  drvtrk
        beq  +          ; br, yep

        jmp  end_ctl

+       jmp  okdone

;

format_ctl .proc                ; format side

        jsr  cacheip    ; setup indirects
        jsr  fmtrk
        bcs  m1

        jsr  getwdstat  ; get status
        bne  m2

        jsr  cacheip    ; setup indirects
        jsr  fmtver_ctl ; won't come back on verify error

        lda  #1         ; ok
        .byte skip2
m1      lda  #6         ; format error
m2      jmp  errr
        .pend

fmtrk
        lda  cmdtrk     ; track
        sta  wdtrk
        jsr  precmp     ; set precomp
        lda  pstartsec  ; starting sector
        sta  tmp+1
        lda  pnumsec
        sta  tmp+2

        lda  wdwritetrack
        jsr  wdbusy     ; send it a 'write track' command

        ldx  #32
        #WDTEST         ; chk address
cmd7    lda  wdstat
        and  #3
        lsr  a
v6      bcc  v1
        beq  cmd7

        lda  #$4e
        sta  wddat      ; give him the $4E data
        dex
        bne  cmd7

main7   ldx  #12
        #WDTEST         ; chk address
cmd70   lda  wdstat
        and  #3
        lsr  a
        bcc  v1
        beq  cmd70

        lda  #0
        sta  wddat
        dex
        bne  cmd70

        ldx  #3
        #WDTEST         ; chk address
cmd71   lda  wdstat
        and  #3
        lsr  a
v1      bcc  v2
        beq  cmd71

        lda  #$f5
        sta  wddat
        dex
        bne  cmd71


        #WDTEST         ; chk address
cmd7n   lda  wdstat
        and  #3
        lsr  a
        bcc  v2
        beq  cmd7n

        lda  #$fe       ; id address mark
        sta  wddat


        #WDTEST         ; chk address
cmd7f   lda  wdstat
        and  #3
        lsr  a
        bcc  v2
        beq  cmd7f

        lda  wdtrk      ; give him the track
        sta  wddat

        #WDTEST         ; chk address
cmd7e   lda  wdstat
        and  #3
        lsr  a
        bcc  v2
        beq  cmd7e

        lda  tcacheside
        sta  wddat      ; side number is ...

        #WDTEST         ; chk address
cmd7d   lda  wdstat
        and  #3
        lsr  a
        bcc  v2
        beq  cmd7d

        lda  tmp+1      ; sector #
        sta  wddat

        #WDTEST         ; chk address
cmd7c   lda  wdstat
        and  #3
        lsr  a
v2      bcc  v3
        beq  cmd7c

        lda  psectorsiz ; sector size
        sta  wddat

        #WDTEST         ; chk address
cmd7b   lda  wdstat
        and  #3
        lsr  a
        bcc  v3
        beq  cmd7b

        lda  #$f7       ; crc 2 bytes written
        sta  wddat

        ldx  #22
        #WDTEST         ; chk address
cmd72   lda  wdstat
        and  #3
        lsr  a
        bcc  v3
        beq  cmd72

        lda  #$4e
        sta  wddat
        dex
        bne  cmd72

        ldx  #12
        #WDTEST         ; chk address
cmd73   lda  wdstat
        and  #3
        lsr  a
v3      bcc  v4
        beq  cmd73

        lda  #0
        sta  wddat
        dex
        bne  cmd73

        ldx  #3         ; Counter for 3 F5's.
        #WDTEST         ; chk address
cmd74   lda  wdstat
        and  #3
        lsr  a
        bcc  v4
        beq  cmd74

        lda  #$f5       ; (Writes A1 data, 0A clock).
        sta  wddat
        dex
        bne  cmd74

        #WDTEST         ; chk address
cmd7a   lda  wdstat
        and  #3
        lsr  a
        bcc  v4
        beq  cmd7a

        lda  #$fb       ; (writes data address mark)
        sta  wddat

        ldy  psectorsiz
        cpy  #3
        bne  cmd750

        iny

        #WDTEST         ; chk address
cmd750  lda  wdstat
        and  #3
        lsr  a
v4      bcc  v5
        beq  cmd750

        lda  fillbyte   ; fill byte
        cmp  #$f5       ; track cache fill ?
        bne  +

        sty  yreg
        ldy  #0
        lda  (ip+4),y   ; get data
        ldy  yreg       ; restore .y register
+       sta  wddat
        inc  ip+4       ; inc pointer
        bne  cmd750

        inc  ip+5       ; inc high address
        dey
        bne  cmd750


        #WDTEST         ; chk address
cmd7ff  lda  wdstat
        and  #3
        lsr  a
        bcc  v5
        beq  cmd7ff

        lda  #$f7       ; crc
        sta  wddat

        ldx  gap3
        #WDTEST         ; chk address
cmd7fe  lda  wdstat
        and  #3
        lsr  a
        bcc  v5
        beq  cmd7fe

        lda  #$4e       ; gap 3
        sta  wddat
        dex
        bne  cmd7fe

        dec  tmp+2      ; number of sectors
        beq  finmfm

        inc  tmp+1
        jmp  main7

        #WDTEST         ; chk address
finmfm  lda  wdstat
        and  #3
        lsr  a
        bcc  vfin
        beq  finmfm

        clc
        lda  #$4e       ; wait for wd to time out
        sta  wddat
        bne  finmfm     ; bra

vfin    jsr  wdunbusy   ; wait for sleepy time
        clc             ; good carry
        .byte $24
v5      sec
        rts

;

ledacton_ctl            ; turn activity led on

        lda  ledprint
        ora  #act_led
        sta  ledprint
        jmp  okfin

;

ledactoff_ctl           ; turn activity led off

        lda  ledprint
        and  #all-act_led
        sta  ledprint
        jmp  okfin

;

errledon_ctl            ; blink power led

        lda  ledprint
        ora  #pwr_led
        sta  ledprint
        jmp  okfin

;

errledoff_ctl           ; disable power led blink

        lda  ledprint
        and  #all-pwr_led
        sta  ledprint
        jmp  okfin

;


side_ctl                ; select side

        ldy  nextjob    ; get index
        lda  sids,y     ; side in track position in header queue
        and  #bit0
        sta  cacheside  ; select side
        bne  +

        lda  #0         ; side one
        .byte skip2
+       lda  #side_sel  ; side zero
        sta  ctmp
        lda  pa
        and  #all-side_sel
        ora  ctmp
        sta  pa
        jmp  okfin

;

bufmove_ctl             ; buffer move

        ldy  hdrjob     ; get index
        lda  hdrs+1,y   ; sector position denotes operation
;
; hdrs: position in track cache
;
; hdrs+1:
;
;  bits 7   6   5   4   3   2   1   0
;       d   m   t  [  # of 256 blks  ]
;
; d: direction (1=to track cache buffer)
; m: mark, set the dirty flag (d must be set)
; t: transfer data (1=transfer)
;
; hdrs2: cachetrk update
;
; sids: cacheside update
;
;
        sta  tmp+1      ; save command info
        bit  tmp+1
        bpl  +          ; br, from cache

        lda  hdrs2,y
        sta  cachetrk   ; this track
        ldy  nextjob
        lda  sids,y
        sta  cacheside  ; & this side
        jsr  bufcache   ; transfer to cache
        jmp  okdone

+       jsr  cachebuf   ; transfer from cache
        jmp  okdone

;

trkwrt_ctl              ; track cache dump

        jmp  okdone     ; done by (mfmctl)


;

        .align 256

wrtold_ctl .proc        ; old track cache dump

        jsr  seek       ; seek any header, on error don't come back
        lda  cachetrk   ; this is what is in memory
        cmp  header
        beq  +

        jmp  wrongtrk

+       sta  wdtrk
        jsr  precmp     ; set precomp
        jsr  cacheip    ; setup ip
        lda  pnumsec    ; number of sectors on a side
        sta  tmp+2

        lda  header+2   ; get sector number
        tax             ; save in .x
        cmp  pendsec    ; pending sector
        php
        bne  m3

        lda  pstartsec  ; get starting sector
        tax             ; save in .x
        sec
        sbc  #1         ; one less
m3      sec
        sbc  pstartsec  ; track cache index=last sector - start sector
        clc
        adc  #1

        ldy  psectorsiz
m4      dey             ; for sectors > 256
        beq  m5

        asl  a          ; x2
        bcc  m4         ; more ?

m5      jsr  chkcache   ; check cache address
        txa             ; retrieve sector
        plp
        beq  m6         ; if it was the last sector then start at the beginning

        clc
        adc  #1         ; one more
        bne  m7         ; bra

m6      lda  pstartsec  ; get starting sector
m7      sta  wdsec
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
m8      lda  wdwritesector
        jsr  wdbusy

        ldy  psectorsiz ; get sector size
        cpy  #3
        bne  m9

        iny
        #WDTEST
m9      lda  wdstat
        and  #3
        lsr  a
        bcc  m10

        beq  m9

        sty  yreg       ; save .y register
        ldy  #0
        lda  (ip+4),y   ; get data
        sta  wddat      ; put it
        ldy  yreg       ; restore .y register

        inc  ip+4
        bne  m9

        inc  ip+5

        dey
        bne  m9

        jsr  getwdstat
        bne  m10        ; error

        dec  tmp+2      ; done ?
        beq  m10

        lda  wdsec      ; put in .a
        inc  wdsec      ; next
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        cmp  pendsec    ; last sector?
        bne  m8

        lda  cache+1
        sta  ip+5       ; start at beginning of the track cache buffer
        lda  pstartsec  ; & first sector
        sta  wdsec
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        jmp  m8

m10     jsr  getwdstat  ; get status
        beq  m11        ; ok?

        jmp  errr       ; nope

m11     jmp  wrtver_ctl ; verify job
        .pend
;

diskin_ctl              ; disk present?

;

pseek_ctl               ; move head to logical track

        jsr  seek       ; seek ok...
        jmp  okdone

;
        .align 256

spwrt_ctl               ; write physical address

        jsr  seek       ; seek any header, on error abort
        lda  cmdtrk     ; get address
        cmp  header
        beq  +

        jmp  wrongtrk

+       ldx  nextjob    ; get job number
        lda  hdrs,x     ; get track
        sta  wdtrk
        lda  hdrs+1,x
        sta  wdsec      ; and sector
        lda  #0
        sta  ip+4       ; zero low
        lda  #>buff0
        sta  ip+5       ; point to buffer 0
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        lda  wdwritesector
        jsr  wdbusy

        ldy  psectorsiz ; get sector size
        cpy  #3
        bne  +

        iny
        #WDTEST
+
-       lda  wdstat
        and  #3
        lsr  a
        bcc  +

        beq  -

        sty  yreg       ; save .y register
        ldy  #0
        lda  (ip+4),y   ; get data
        sta  wddat      ; put it
        ldy  yreg       ; restore .y register

        inc  ip+4
        bne  -

        inc  ip+5

        dey
        bne  -

+       jsr  getwdstat  ; get status
        jmp  errr

;

        .align 256

spread_ctl              ; read physical address

        jsr  seek       ; seek any header, on error abort
        lda  cmdtrk     ; get address
        cmp  header
        beq  +

        jmp  wrongtrk

+       ldx  nextjob    ; get job number
        lda  hdrs,x     ; get track
        sta  wdtrk
        lda  hdrs+1,x
        sta  wdsec      ; and sector
        lda  #0
        sta  ip+4       ; zero low
        lda  #>buff0
        sta  ip+5       ; point to buffer 0
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        lda  wdreadsector
        jsr  wdbusy

        ldy  psectorsiz ; get sector size
        cpy  #3
        bne  +

        iny
        #WDTEST
+
-       lda  wdstat
        and  #3
        lsr  a
        bcc  +

        beq  -

        sty  yreg       ; save .y register
        ldy  #0
        lda  wddat      ; get it
        sta  (ip+4),y   ; put data
        ldy  yreg       ; restore .y register

        inc  ip+4
        bne  -

        inc  ip+5

        dey
        bne  -

+       jsr  getwdstat  ; get status
        jmp  errr

;

        .align 256

pread_ctl
pwrt_ctl

wrtsd_ctl               ; write to track cache buffer
read_ctl .proc          ; read from track cache buffer

        jsr  seek       ; seek any header, on error abort
        lda  cmdtrk     ; get address
        cmp  header
        beq  m1

        jmp  wrongtrk

m1      sta  wdtrk
        jsr  cacheip    ; setup ip
        lda  tcacheside ; get translated cache side
        sta  tmp+1      ; in current

        lda  pnumsec    ; number of sectors on a side
        sta  tmp+2

        lda  header+2   ; get sector number
        tax             ; save in .x
        cmp  pendsec    ; pending sector
        php
        bne  m3

        lda  pstartsec  ; get starting sector
        tax             ; save in .x
        sec
        sbc  #1         ; one less
m3      sec
        sbc  pstartsec  ; track cache index=last sector - start sector
        clc
        adc  #1

        ldy  psectorsiz
m4      dey             ; for sectors > 256
        beq  m5

        asl  a          ; x2
        bcc  m4         ; more ?

m5      jsr  chkcache   ; check cache for valid address
        txa             ; retrieve sector
        plp
        beq  m6         ; if it was the last sector then start at the beginning

        clc
        adc  #1         ; one more
        bne  m7         ; bra

m6      lda  pstartsec  ; get starting sector
m7      sta  wdsec
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
m8      lda  wdreadsector
        jsr  wdbusy

        ldy  psectorsiz ; get sector size
        cpy  #3
        bne  m9

        iny
        #WDTEST
m9      lda  wdstat
        and  #3
        lsr  a
        bcc  m10

        beq  m9

        sty  yreg       ; save .y register
        ldy  #0
        lda  wddat      ; get it
        sta  (ip+4),y   ; put data
        ldy  yreg       ; restore .y register

        inc  ip+4
        bne  m9

        inc  ip+5

        dey
        bne  m9

        jsr  getwdstat  ; get status
        bne  m10        ; error

        dec  tmp+2      ; done ?
        beq  m10

        lda  wdsec      ; put in .a
        inc  wdsec      ; next
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        cmp  pendsec    ; last sector?
        bne  m8

        lda  cache+1
        sta  ip+5       ; start at beginning of the track cache buffer
        lda  pstartsec  ; & first sector
        sta  wdsec
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        jmp  m8

m10     jsr  getwdstat  ; get status
        bne  +          ; bad

        lda  tcacheside
        sta  cacheside  ; new current
        lda  cmdtrk
        sta  cachetrk   ; track in memory
        jmp  back       ; service original

+       jmp  errr       ; nope
        .pend

;


wrtver_ctl              ; write track cache buffer to disk

        bit  iobyte
        bpl  +          ; verify on/off ?

        jsr  one_6      ; delay 1.6 mS
        jsr  fmtver_ctl ; verify it
-       asl  dirty      ; clear dirty flag
        jmp  back       ; back to sender

+       jsr  one_6      ; delay 1.6 mS
        jmp  -

;

        .align 256

fmtver_ctl .proc

        jsr  seek       ; seek any header, on error abort
        lda  cmdtrk     ; get track address
        cmp  header
        beq  +

        jmp  wrongtrk

+       sta  wdtrk
        jsr  cacheip    ; setup ip
        lda  tcacheside ; get translated cache side
        sta  tmp+1      ; in current

        lda  pnumsec    ; number of sectors
        sta  tmp+2

        lda  header+2   ; get sector number
        tax             ; save in .x
        cmp  pendsec    ; pending sector
        php
        bne  +

        lda  pstartsec  ; get starting sector
        tax             ; save in .x
        sec
        sbc  #1         ; one less
+       sec
        sbc  pstartsec  ; track cache index=last sector - start sector
        clc
        adc  #1

        ldy  psectorsiz
-       dey             ; for sectors > 256
        beq  +

        asl  a          ; x2
        bcc  -          ; more ?

+       jsr  chkcache   ; check cache for valid address
        txa             ; retrieve sector
        plp
        beq  m6         ; if it was the last sector then start at the beginning

        clc
        adc  #1         ; one more
        bne  m7         ; bra

m6      lda  pstartsec  ; get starting sector
m7      sta  wdsec
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
m8      lda  wdreadsector
        jsr  wdbusy

        ldy  psectorsiz ; get sector size
        cpy  #3
        bne  m9

        iny
        #WDTEST
m9      lda  wdstat
        and  #3
        lsr  a
        bcc  m11

        beq  m9

        lda  fillbyte
        cmp  #$f5
        bne  +

        sty  yreg       ; save .y register
        ldy  #0
        lda  (ip+4),y   ; get data
        ldy  yreg       ; restore .y register
+       cmp  wddat
        bne  m13

        inc  ip+4
        bne  m9

        inc  ip+5

        dey
        bne  m9

        jsr  getwdstat  ; get status
        bne  m12        ; error

        dec  tmp+2      ; done ?
        beq  m11

        lda  wdsec      ; put in .a
        inc  wdsec      ; next
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        cmp  pendsec    ; last sector?
        bne  m8

        lda  cache+1
        sta  ip+5       ; start at beginning of the track cache buffer
        lda  pstartsec  ; & first sector
        sta  wdsec
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        jmp  m8

m11     jsr  getwdstat  ; get status
        bne  m14        ; bad

m12     rts

m13     jsr  wdabort    ; abort the bugger
        lda  #7
m14     jmp  errr       ; nope
        .pend
;

seekphd_ctl             ; seek a particular header

        jsr  seek       ; on an error, don't come back now hear!!!

        lda  drvtrk
        cmp  cmdtrk     ; on track?
        bne  +

        ldy  #60        ; 60 headers
        sty  tmp+1      ; count
-       jsr  seek       ; start looking
        ldy  hdrjob     ; get index
        lda  hdrs2+1,y  ; get sector address
        cmp  header+2   ; we there yet?
        beq  seekhd_ctl ; yep

        dec  tmp+1
        bne  -

        lda  #2
        jmp  errr       ; sector not found

+       jmp  end_ctl    ; & better step there

;

seekhd_ctl              ; seek any header

        jsr  seek       ; on an error, don't come back now hear!!!
        jmp  okdone

;

restore_ctl             ; restore head

        lda  wdrestore  ; restore head to track zero
        jsr  wdbusy
        jsr  wdunbusy   ; done?
        lda  pstartrk   ; physical starting track
        sta  drvtrk     ; init
        sta  cmdtrk     ; *
        ldy  setval
        jsr  xms        ; settle
        jmp  okdone     ; done

;

exbuf_ctl               ; execute buffer w/ motor upto speed & on track

;

jumpc_ctl               ; execute buffer

        ldx  nextjob
        lda  bufind,x
        sta  ip+3
        ldy  #0
        sty  ip+2
        txa
        jmp  (ip+2)

;

formatdk_ctl .proc      ; format disk

        lda  #0
        sta  tcacheside ; side zero
-       lda  tcacheside
        jsr  sid_select ; setup side
        jsr  cacheip    ; setup indirects
        jsr  fmtrk      ; format side zero
        jsr  getwdstat  ; get status
        bne  m3

        jsr  one_6      ; delay
        jsr  cacheip    ; setup indirects
        jsr  fmtver_ctl ; won't come back on verify error
        inc  tcacheside ; side one
        lda  tcacheside
        cmp  #2
        bcc  -

        lda  cmdtrk     ; where are we?
        cmp  pmaxtrk    ; ...there yet?
        bne  m4

        lda  #1         ; ok
        .byte skip2
        lda  #6         ; format error
m3      jmp  errr

m4      ldy  hdrjob
        lda  hdrs2,y    ; next track
        clc
        adc  #1
        sta  hdrs2,y
        jmp  erret      ; service job
        .pend

;

detwp_ctl

        lda  #wpin
        bit  pb         ; write protected
        bne  +

        lda  #8         ; it's protected
        .byte skip2
+       lda  #0
        jmp  errr

;

syntaxer

        lda  #$0e       ; syntax error
        .byte skip2
wrongfmt
wrongtrk
        lda  #2
        jmp  errr

;
chkcache
        clc
        adc  cache+1
        sta  ip+5       ; high address
        cmp  #cache_high
        bcs  +

        rts
+
        pla
        pla             ; restore stack
        jsr  getwdstat
        jmp  wrongfmt

;


; format track

cmdsev  lda  #$f8       ; write track
        jsr  strtwd     ; send command

        bit  switch     ; system 34 / iso standard switch
        bvc  no_ind     ; write index ?

        ldx  #80
        #WDTEST         ; chk address
-       lda  wdstat
        and  #3
        lsr  a
        bcc  v6
        beq  -

        lda  #$4e
        sta  wddat      ; give him the data
        dex
        bne  -

        ldx  #12
        #WDTEST         ; chk address
-       lda  wdstat
        and  #3
        lsr  a
        bcc  v6
        beq  -

        lda  #0
        sta  wddat
        dex
        bne  -

        ldx  #3
        #WDTEST         ; chk address
-       lda  wdstat
        and  #3
        lsr  a
        bcc  v6
        beq  -

        lda  #$f6
        sta  wddat
        dex
        bne  -

        #WDTEST         ; chk address
-       lda  wdstat
        and  #3
        lsr  a
        bcc  v6
        beq  -

        lda  #$fc
        sta  wddat


        ldx  #50
        #WDTEST         ; chk address
-       lda  wdstat
        and  #3
        lsr  a
        bcc  v6
        beq  -

        lda  #$4e
        sta  wddat      ; give him the data
        dex
        bne  -

        beq  inner      ; bra... done...


no_ind  ldx  #60
        #WDTEST         ; chk address
cmd7    lda  wdstat
        and  #3
        lsr  a
v6      bcc  v1
        beq  cmd7

        lda  #$4e
        sta  wddat      ; give him the data
        dex
        bne  cmd7


inner   ldy  #1         ; ss

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

        lda  mfmcmd     ; give him the track
        sta  wddat

        #WDTEST         ; chk address
cmd7e   lda  wdstat
        and  #3
        lsr  a
        bcc  v2
        beq  cmd7e

        lda  switch
        and  #%00010000 ; what side are we on ?
        bne  +

        lda  #0
        .byte skip2
+       lda  #1
        sta  wddat      ; side number is ...

        #WDTEST         ; chk address
cmd7d   lda  wdstat
        and  #3
        lsr  a
        bcc  v2
        beq  cmd7d

        lda  cmdbuf+10,y ; sector number actually cmdbuf+11
        sta  wddat

        #WDTEST         ; chk address
cmd7c   lda  wdstat
        and  #3
        lsr  a
v2      bcc  v3
        beq  cmd7c

        lda  cmdbuf+5   ; sz
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

        ldx  #3
        #WDTEST         ; chk address
cmd74   lda  wdstat
        and  #3
        lsr  a
        bcc  v4
        beq  cmd74


        lda  #$f5       ; a1
        sta  wddat
        dex
        bne  cmd74

        #WDTEST         ; chk address
cmd7a   lda  wdstat
        and  #3
        lsr  a
        bcc  v4
        beq  cmd7a

        lda  #$fb       ; dam
        sta  wddat

        sty  temp       ; save current sector


        ldy  mfmsiz_hi  ; high
        #WDTEST         ; chk address
cmd750  lda  wdstat
        and  #3
        lsr  a
v4      bcc  v5
        beq  cmd750


        lda  cmdbuf+10  ; fl
        sta  wddat

        cpx  mfmsiz_lo
        beq  cmd75x

        inx             ; increment
        jmp  cmd750

cmd75x  inx
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

        ldy  cmdbuf+5   ; ss
        lda  gapmfm,y
        ldy  temp       ; sector restore
        tax

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

        cpy  cmdbuf+7   ; ns
        beq  finmfm

        iny             ; inc sector
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
        jmp  finmfm

vfin    jsr  waitdn     ; wait for sleepy time
        clc             ; good carry
        .byte skip1
v5      sec
        rts

        ; min gap size @2% fast
gapmfm  .byte 7, 12, 23, 44

numsek  .byte 26, 16, 9, 5

; format disk

;  0     1    2    3      4    5    6    7    8   9   10  + cmdbuf
;  ^     ^    ^    ^      ^    ^    ^    ^    ^   ^    ^
; "U" + $00 + N +  MD  + CP + SZ + LT + NS + ST + S + FL

cmdeig  lda  switch     ; check abort command switch
        and  #%00001000
        beq  +

        ldx  ctl_dat    ; get error
        stx  mfmcmd     ; save for prcmd
        sec             ; wp error usually
        rts

+       jsr  clrchn     ; close all channels
        lda  cmdsiz     ; setup default parms
        sec
        sbc  #4         ; less mandatory + 1
        tay
        beq  cp00       ; mode only, gave cp

        dey
        beq  sz00       ; md, cp only, gave sz

        lda  #0
        sta  mfmcmd     ; clear status

        lda  cmdbuf+5
        jsr  consek     ; setup sector size

        dey
        beq  lt00       ; md, cp, sz only, gave lt

        dey
        beq  ns00       ; md, cp, sz, lt only, gave ns

        dey
        beq  st00       ; md, cp, sz, lt, ns only, gave st

        dey
        beq  s00        ; md, cp, sz, lt, ns, st only, gave s

        dey
        beq  fl00       ; md, cp, sz, lt, ns, st, ss only, gave fl

        jmp  start8

cp00    lda  #0         ; default interleave
        sta  cmdbuf+4

sz00    lda  #0
        sta  mfmcmd     ; clear status

        lda  #1         ; 256 byte sectors
        sta  cmdbuf+5
        jsr  consek     ; setup block size

lt00    lda  #39        ; last track is #39, 40 tracks total
        sta  cmdbuf+6

ns00    lda  numsek,x   ; x=sector size index for # of sectors per track
        sta  cmdbuf+7

st00    lda  #0         ; default track #0 start
        sta  cmdbuf+8
        sta  wdtrk

s00     lda  #0         ; default steps from track 00
        sta  cmdbuf+9

fl00    lda  #$e5       ; default block fill
        sta  cmdbuf+10

start8  jsr  go_fmt     ; format side zero
        lda  mfmcmd     ; error ?
        cpx  #2
        bcs  +

        lda  switch     ; check for double sided opt
        and  #%00100000
        beq  +

        lda  switch     ; set single side
        ora  #%00010000
        sta  switch
        jsr  sel_sid    ; select h/w
        jsr  go_fmt     ; format side one
+       jmp  cmdone     ; restore

go_fmt  jsr  diskin     ; is there a diskette in the unit
        bcs  c_801      ; br, nope...

        lda  #1
        sta  ifr1       ; clear irq from write protect
        jsr  cmdone     ; restore to track one/zero ?
        lda  cmdbuf+8   ; store logical
        sta  mfmcmd     ; in mfmcmd
        sta  wdtrk

        bit  cmdbuf+3   ; check table bit
        bvs  +          ; br, table has been given to us

        jsr  sectcv     ; generate sector table
        bcs  c_801

+       lda  cmdbuf+9   ; offset track 00 by s steps
        and  #$7f       ; clear mode bit
        beq  c_800

        clc
        adc  cmd_trk    ; add to it
        sta  cmd_trk    ; physical
        jsr  seke       ; & seek to it

c_800   sei
        lda  ifr1       ; check for disk change
        lsr  a
        bcs  c_801

        jsr  cmdsev     ; format track
        bcs  c_801

        lda  ifr1       ; check for disk change
        lsr  a
        bcs  c_801

        jsr  verfmt     ; verify format
        bcs  c_801

        lda  ifr1       ; check for disk change
        lsr  a
        bcs  c_801

        lda  mfmcmd     ; last track ?
        cmp  cmdbuf+6   ; lt
        beq  c_802

        inc  cmd_trk
        inc  wdtrk
        inc  mfmcmd     ; track to write

        jsr  seke       ; goto next track
        jmp  c_800

c_802   bit  switch
        bpl c_803       ; kill next

        sec
        lda  cmdbuf+6   ; lt
        sbc  cmdbuf+8   ; st
        cmp  #39        ; no more than 40 tracks
        bcs  c_803

        inc  cmd_trk    ; clear next track
        jsr  seke
        ldx  #28

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        jsr  ptch0d     ; *** rom ds 01-13-87 ***,no SO
        nop
        nop
        nop             ; fill
;       jsr  jclear     ; with gcr 0
;       jsr  kill       ; read mode again

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

c_803   ldx  #0
        .byte  skip2
c_801   ldx  #6
        stx  mfmcmd     ; ok exit
        jmp  upinst

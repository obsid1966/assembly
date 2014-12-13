; Partition Routines
;
; USAGE: Create
;"/0:par_name,"+chr$(start-trk)+chr$(start-sector)+chr$(lo-blks)+chr$(hi-blks)+",C"
;
; USAGE: Select
;"/0:par_name"
;
part    .proc
        jsr  autoi      ; init drive
        lda  cmdsiz
        cmp  #2
        bcc  m8         ; select default

        lda  #1
        sta  filtbl     ; set filename
        jsr  onedrv     ; select drive
        jsr  lookup     ; does it exist

        lda  filtrk
        beq  m5         ; no br, file exists

        jsr  testlimit
        bcc  m6         ; no parms must accept as select partition

        lda  #flexst    ; file exists
        .byte  skip2
m2      lda  #flntfd    ; file not found
        .byte  skip2
m3      lda  #badsyn    ; bad syntax
        .byte  skip2
m4      lda  #illpar    ; illegal partition
        jsr  cmderr

m5      jsr  testlimit
        bcc  m2         ; no parms can't create partition

        ldx  limit
        lda  cmdbuf+6,x
        cmp  #'C'       ; create char
        bne  m3         ; syntax error

        jmp  creatpart  ; create partition file

m6      lda  pattyp
        and  #typmsk
        cmp  #partyp    ; partition file?
        bne  m2

        jsr  setparts   ; set partition t&s
-       jsr  tschk      ; check t&s
        jsr  calcpar    ; calc maxtrk, etc...
        bne  -

        bcc  m4         ; carry must be set

        ldy  #2
        lda  (dirbuf),y ; get sector
        bne  m4         ; must be zero

        dey
        lda  track      ; get maxtrk
        tax             ; save
        sbc  (dirbuf),y ; sub starting track
        cmp  #2
        beq  m4         ; illegal

        bcc  m4         ; illegal

        lda  (dirbuf),y
        sta  dirtrk     ; set system track
        sta  startrk    ; set starting track
        stx  maxtrk     ; set maxtrk
        dex
        dex
        stx  pmaxtrk    ; set physical maxtrk
        jmp  m9         ; bra

m8      jsr  setdef     ; set default
m9      jsr  clrchn     ; clear all channels
        jsr  initdr     ; init directory
        lda  startrk
        sta  track      ; exit with starting track in track position of OK...
        ldy  maxtrk     ; & last track in sector position
        dey
        sty  sector
        lda  #2         ; ok partition
        ldy  #0
        jmp  partend
        .pend


scanpart .proc
        lda  wbam
        pha
        lda  ndbl
        pha
        lda  ndbh       ; save
        pha
        jsr  settslim   ; set t&s limits
-       jsr  tschk      ; check limits
        lda  track
        cmp  #systrack  ; hard system track?
        beq  +          ; br, error

        jsr  wused      ; allocate it
        beq  +          ; already allocated? then error

        jsr  frets      ; freeit

        jsr  calcpar    ; next
        bne  -

        pla
        sta  ndbh
        pla
        sta  ndbl
        pla
        sta  wbam
        rts

+       pla             ; restore
        sta  ndbh
        pla
        sta  ndbl
        pla
        sta  wbam
        lda  #systs
        jmp  cmder2     ; error
        .pend

testlimit
        ldx  #1
        jsr  fndlmt     ; find = or ,
        lda  cmdsiz
        sec
        sbc  limit
        cmp  #4
        rts



settslim

        ldy  limit
        iny
        lda  cmdbuf,y
        sta  track
        iny
        lda  cmdbuf,y
        sta  sector
        iny
        lda  cmdbuf,y
        sta  lo
        iny
        lda  cmdbuf,y
        sta  hi
        clc
        lda  lo
        adc  hi
        beq  +          ; =0?

        jmp  tschk      ; chk parms
+       lda  #illpar
        jsr  cmderr     ; illegal partition


creatpart

        jsr  scanpart   ; test range given
        lda  #partyp    ; open partition
        sta  type
        lda  #iwsa      ; internal write channel
        sta  sa
        jsr  settslim   ; set t&s limits
        jsr  opnwch1    ; open internal write channel
        jsr  addfil     ; addfil to directory
        jsr  settslim   ; set t&s limits
-       jsr  tschk      ; check limits
        lda  track
        jsr  wused      ; allocate it
        jsr  calcpar    ; next
        bne  -

        jsr  settslim   ; set t&s limits
        ldx  lindx
        lda  lo
        sta  nbkl,x     ; low blks
        lda  hi
        sta  nbkh,x     ; high blks
        lda  #0
        jsr  putbyt     ; write one byte, nil
        lda  #iwsa
        sta  sa
        jsr  clschn     ; close channel
        jmp  endcmd

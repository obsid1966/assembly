;  validate files with bam
;  create new bam according to
;  contents of files entered in dir

verdir  jsr  simprs     ; get drive #
        jsr  initdr
        jsr  newmap     ; set new bam
        lda  #0
        sta  delind
        jsr  srchst     ; search first file
        bne  vd25       ; found one

vd10    lda  #0         ; set dir sectors..
        sta  sector     ; ...in bam
        lda  dirtrk
        sta  track
        jsr  vmkbam
        jsr  mapout     ; wrt 'em out
        jmp  endcmd

vd15    iny
        lda  (dirbuf),y
        pha             ; save track
        iny
        lda  (dirbuf),y
        pha             ; save sector
        ldy  #19        ; get ss track
        lda  (dirbuf),y ; is this relative ?
        beq  vd17       ; no

        sta  track      ; yes - save track
        iny
        lda  (dirbuf),y ; get ss sector
        sta  sector
        jsr  vmkbam     ; validate ss by links
vd17    pla
        sta  sector     ; now do data blocks
        pla
        sta  track
        jsr  vmkbam     ; set bit used in bam
vd20    jsr  srre       ; search for more
        beq  vd10       ; no more files

vd25    ldy  #0
        lda  (dirbuf),y
        bpl  vd28

        and  #7         ; par. file?
        cmp  #5
        bne  vd15

vd26    jsr  setparts   ; set partition t&s
        jsr  allocpart  ; allocate t&s
        jmp  vd20

vd28    jsr  deldir     ; not closed delete dir
        jmp  vd20
vmkbam                  ; mark bam w/file sectors
        jsr  tschk
        jsr  wused
        jsr  opnird
mrk2    lda  #0
        jsr  setpnt
        jsr  getbyt
        sta  track
        jsr  getbyt
        sta  sector
        lda  track
        bne  mrk1

        jmp  frechn
mrk1    jsr  wused
        jsr  nxtbuf
        jmp  mrk2



calcpar .proc
        lda  lo
        bne  m1

        lda  hi
        beq  m2

        dec  hi
m1      dec  lo
        inc  sector     ; next please
        lda  numsec
        cmp  sector
        bne  m2

        lda  #0
        sta  sector     ; start over
        lda  track
        cmp  dirtrk     ; can not overrun system track
        beq  m3

        inc  track      ; next

        sec
        .byte skip1
m2      clc
        lda  hi
        ora  lo
        rts             ; .z=1 done...

m3      lda  #systs     ; illegal partition track & sector error
        jmp  cmder2
        .pend


setparts

        ldy  #1
        lda  (dirbuf),y
        sta  track      ; starting track
        iny
        lda  (dirbuf),y
        sta  sector     ; starting sector
        ldy  #$1C
        lda  (dirbuf),y
        sta  lo         ; blks used
        iny
        lda  (dirbuf),y
        sta  hi
        rts




allocpart

        jsr  tschk      ; check t&s
        jsr  wused      ; allocate it
        jsr  calcpar
        bne  allocpart

        rts

;set rel pntrs to given rec# or to
;the last rec if out of range

record  jsr  cmdset     ; init tables, ptrs
        lda  cmdbuf+1
        sta  sa
        jsr  fndrch
        bcc  r20        ; got channel's lindex

        lda  #nochnl    ; no valid channel
        jsr  cmderr

r20     lda  #lrf+ovrflo
        jsr  clrflg
        jsr  typfil     ; get file type
        beq  r30        ; it is relative file

        lda  #mistyp    ; wrong type
        jsr  cmderr

r30     lda  cmdbuf+2
        sta  recl,x     ; get record #
        lda  cmdbuf+3
        sta  rech,x
        ldx  lindx      ; clear chnrdy to rndrdy
        lda  #rndrdy
        sta  chnrdy,x
        lda  cmdbuf+4   ; get offset
        beq  r40

        sec
        sbc  #1
        beq  r40

        cmp  rs,x
        bcc  r40

        lda  #recovf
        sta  erword
        lda  #0
r40     sta  recptr     ; set offset
        jsr  fndrel     ; calc ss stuff
        jsr  sspos      ; set ss ptrs
        bvc  r50

        lda  #lrf       ; beyond the end
        jsr  setflg     ; set last rec flag
        jmp  rd05

r50     jsr  positn     ; pos to record
        lda  #lrf
        jsr  tstflg
        beq  r60

        jmp  rd05

r60     jmp  endcmd
;position rel data block into act buf and
;next block into inact buffer
positn  jsr  posbuf     ; pos buffers
        lda  relptr
        jsr  setpnt     ; set ptr from fndrel
        ldx  lindx
        lda  rs,x
        sec             ; calc the offset
        sbc  recptr
        bcs  p2

        jmp  break      ; should not be needed

p2      clc
        adc  relptr
        bcc  p30

        adc  #1
        sec
p30     jsr  nxout      ; set nr
        jmp  rd15

        lda  #recovf
        jsr  cmderr

posbuf  lda  dirbuf     ; position proper data
        sta  r3         ; blocks into buffers
        lda  dirbuf+1
        sta  r4
        jsr  bhere      ; is buffer in?
        beq  p20        ; br, yes!

        jsr  scrub      ; write and clear
        jsr  getlnk     ; get t & s link
        lda  track      ; done?
        beq  p80

        jsr  dblbuf
        jsr  bhere      ; is it in?
        bne  p80

        jsr  getlnk     ; get t & s link
        lda  track      ; done ???
        beq  p20

        jsr  dblbuf
        jsr  rdab       ; read it
        jmp  dblbuf

p20     rts

p80     ldy  #0         ; get proper block
        lda  (r3),y
        sta  track
        iny
        lda  (r3),y
        sta  sector
        jmp  strdbl     ; get next blk, too.

bhere   jsr  gethdr     ; get the header
        ldy  #0
        lda  (r3),y
        cmp  track
        beq  bh10       ; test sector, too.

        rts

bh10    iny
        lda  (r3),y
        cmp  sector     ; set .z
        bne  +

        lda  relsw
        and  #bit4
        beq  +

        lda  relsw
        and  #all-bit4
        sta  relsw      ; clear flag
        eor  #bit4
+       rts

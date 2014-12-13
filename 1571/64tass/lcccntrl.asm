;
;
;
;    *contrl
;
;    main controller loop
;
;    scans job que for jobs
;
;   finds job on current track
;   if it exists
;
lcc
;
        tsx     	;  save current stack pointer
        stx  savsp
;
        lda  t1lc2      ; reset irq flag
;
        lda  pcr2       ;  enable s.o. to 6502
        ora  #$0e       ;  hi output
        sta  pcr2
;
;
;
top     ldy  #numjob-1  ;  pointer into job que
;
cont10
        lda  jobs,y     ;  find a job (msb set)
        bpl  cont20     ;  not one here
;
        cmp  #jumpc     ;  test if its a jump command
        bne  cont30
;
        tya     	;  put job num in .a
        jmp  ex2
;
;
cont30
        and  #1         ;  get drive #
        beq  cont35
;
        sty  jobn
        lda  #$0f       ; bad drive # error
        jmp  errr
;
cont35  tax
        sta  drive
;
        cmp  cdrive     ;  test if current drive
        beq  cont40
;
        jsr  turnon     ;  turn on drive
        lda  drive
        sta  cdrive
        jmp  end        ;  go clean up
;
;
cont40  lda  drvst      ;  test if motor up to speed
        bmi  cont50
;
        asl  a          ;  test if stepping
        bpl  que        ;  not stepping
;
cont50  jmp  end
;
cont20  dey
        bpl  cont10
;
        jmp  end
;
;
que     lda  #$20       ;  status=running
        sta  drvst
;
        ldy  #numjob-1
        sty  jobn
;
que10   jsr  setjb
        bmi  que20
;
que05   dec  jobn
        bpl  que10
;
;
        ldy  nxtjob
        jsr  setjb1
;
        lda  nxtrk
        sta  steps
        asl  steps      ;  steps*2
;
        lda  #$60       ;  set status=stepping
        sta  drvst
;
;
        lda  (hdrpnt),y         ;  get dest track #
        sta  drvtrk
fin     jmp  end
;
;
que20   and  #1         ;  test if same drive
        cmp  drive
        bne  que05
;
        lda  drvtrk
        beq  gotu       ;  uninit. track #
;
        sec     	;  calc distance to track
        sbc  (hdrpnt),y
        beq  gotu       ;  on track
;
        eor  #$ff       ;  2's comp
        sta  nxtrk
        inc  nxtrk
;
        lda  jobn       ;  save job# and dist to track
        sta  nxtjob
;
        jmp  que05
;
;
;
;
gotu    ldx  #4         ;  set track and sectr
        lda  (hdrpnt),y
        sta  tracc
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

gotu10  cmp  trackn-1,x ; *** rom ds 11/7/86 ***, set density for tracks > 35

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
        dex
        bcs  gotu10
;
        lda  numsec,x
        sta  sectr
;
        txa     	;  set density
        asl  a
        asl  a
        asl  a
        asl  a
        asl  a
        sta  work
;
        lda  dskcnt
        and  #$9f       ;  clear density bits
        ora  work
        sta  dskcnt
;
        ldx  drive      ;  drive num in .x
;
        lda  job        ;  yes, go do the job
        cmp  #bumpc     ;  test for bump
        beq  bmp
;
;
exe     cmp  #execd     ;  test if execute
        beq  ex
;
        jmp  seak       ;  do a sector seek
;
ex      lda  jobn       ;  jump to buffer
ex2     clc
        adc  #>bufs
        sta  bufpnt+1
        lda  #0
        sta  bufpnt
ex3     jmp  (bufpnt)
;
;
bmp
        lda  #$60       ;  set status=stepping
        sta  drvst
;
        lda  dskcnt
        and  #$ff-$03   ;  set phase a
        sta  dskcnt
;
;
        lda  #256-92    ;  step back 45 traks
        sta  steps
;
        lda  #1         ;  drvtrk now 1
        sta  drvtrk
;
        jmp  errr       ;  job done return 1
;
;
setjb   ldy  jobn
setjb1  lda  jobs,y
        pha
        bpl  setj10     ;  no job here
;
        and  #$78
        sta  job
        tya
        asl  a
        adc  #<hdrs
        sta  hdrpnt
        tya     	;  point at buffer
        clc
        adc  #>bufs
        sta  bufpnt+1
;
;
setj10  ldy  #0
        sty  bufpnt
;
        pla
        rts
;
;
;
;.end

; rename file name in directory
rename  jsr  alldrs     ; set both drive #'s
        lda  fildrv+1
        and  #1
        sta  fildrv+1
        cmp  fildrv
        beq  rn10       ; same drive #'s

        ora  #$80       ; check both drives for name
rn10    sta  fildrv
        jsr  lookup     ; look up both names
        jsr  chkio      ; check for existence
        lda  fildrv+1
        and  #1
        sta  drvnum
        lda  entsec+1
        sta  sector
        jsr  rdab       ; read directory sector
        jsr  watjob
        lda  entind+1
        clc     	; set sector index
        adc  #3         ; ...+3
        jsr  setpnt
        jsr  getact
        tay
        ldx  filtbl
        lda  #16
        jsr  trname     ; transfer name
        jsr  wrtout     ; write sector out
        jsr  watjob
        jmp  endcmd

; check i/o file for exist

chkin   lda  pattyp+1   ; 1st file bears type
        and  #typmsk
        sta  type
        ldx  f2cnt
ck10    dex
        cpx  f1cnt
        bcc  ck20

        lda  filtrk,x
        bne  ck10

        lda  #flntfd    ; input file not found
        jmp  cmderr

ck20    rts

chkio   jsr  chkin
ck25    lda  filtrk,x
        beq  ck30

        lda  #flexst
        jmp  cmderr

ck30    dex
        bpl  ck25

        rts

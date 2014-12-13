        *=$8000

signature_lo    *=*+1   ; <<< TO BE DETERMINED
signature_hi    *=*+1   ; <<< TO BE DETERMINED

        .text  'S/W - DAVID G SIRACUSA',$0D,"H/W - GREG BERLIN",$0D,'1985',$0D

burst_routines

        lda  cmdsiz     ; check command size
        cmp  #3
        bcc  realus

        lda  cmdbuf+2   ; get command
        sta  switch     ; save info
        and  #$1f
        tax             ; command info
        asl  a
        tay
        lda  cmdtbb,y
        sta  ip
        lda  cmdtbb+1,y
        sta  ip+1
        cpx  #30        ; utload ok for 1541 mode
        beq  +

        lda  pota1
        and  #$20       ; 1/2 Mhz ?
        beq  realus     ; 1541 mode...ignore

+       lda  fastsr     ; clear clock & error return
        and  #$eb
        sta  fastsr

        lda  cmdctl,x   ; most sig bit set set error recover
        sta  cmdbuf+2   ; save info here

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        jmp  ptch65
;       jmp  (ip)       ; *** rom ds 04/25/86 ***

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

realus  lda  #<ublock   ; set default block add
        sta  usrjmp
        lda  #>ublock
        sta  usrjmp+1
unused  rts


; command tables and information

cmdctl   .byte  $80,$81,$90,$91,$b0,$b1,$f0,$f1,$00,$01,$B0,$01,$00,$01,$00,$01
         .byte  $80,$81,$90,$91,$b0,$b1,$f0,$f1,$00,$01,$B0,$01,$00,$01,$00,$80

cmdtbb   .word    fstrd          ; fast read drv #0 - 0000
         .word    ndkrd          ; fast read drv #1 - 0001

         .word    fstwrt         ; fast write drv #0 - 0010
         .word    ndkwrt         ; fast write drv #1 - 0011

         .word    fstsek         ; seek disk drv #0 - 0100
         .word    ndkrd          ; seek disk drv #1 - 0101

         .word    fstfmt         ; format disk drv #0 - 0110
         .word    fstfmt         ; format disk drv #1 - 0111

         .word    cpmint         ; interleave disk drv #0 - 1000
         .word    cpmint         ; interleave disk drv #1 - 1001

         .word    querdk         ; query disk format - 1010
         .word    ndkrd          ; seek disk drv #1 - 1011

         .word    inqst          ; return disk status - 1100
         .word    ndkrd          ; return disk status - 1101

         .word    duplc1         ; backup drv0 to drv1 - 1110
         .word    duplc1         ; backup drv1 to drv0 - 1111

; *****************************************************************

         .word    fstrd          ; fast read drv #0 - 0000
         .word    ndkrd          ; fast read drv #1 - 0001

         .word    fstwrt         ; fast write drv #0 - 0010
         .word    ndkwrt         ; fast write drv #1 - 0011

         .word    fstsek         ; seek disk drv #0 - 0100
         .word    ndkrd          ; seek disk drv #1 - 0101

         .word    fstfmt
         .word    fstfmt

         .word    unused
         .word    unused

         .word    querdk         ; query disk format - 1010
         .word    ndkrd          ; seek disk drv #1 - 1011

         .word    unused
         .word    unused

         .word    chgutl
         .word    fstload

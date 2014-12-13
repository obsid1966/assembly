getact  ldx  lindx      ; get the act buf#
        lda  buf0,x     ; accm= act buf#
        bpl  ga1        ; x=lindx, n=1 no act buf

        lda  buf1,x
ga1     and  #$bf       ;  strip dirty bit
        rts

;get act buf#-set lbused,flgs

gaflgs  ldx  lindx
        stx  lbused     ; save buf #
        lda  buf0,x
        bpl  ga3

        txa
        clc
        adc  #mxchns
        sta  lbused
        lda  buf1,x
ga3     sta  t1
        and  #$1f
        bit  t1
        rts             ; n=1 no act buf/v=1 dirty buf

getina  ldx  lindx      ; get ch's inact buf#
        lda  buf0,x
        bmi  gi10

        lda  buf1,x     ; accm =buf#
gi10    cmp  #$ff
        rts             ; ff=no inact buffer

putina  ldx  lindx      ; put inact buff
        ora  #$80       ; accm=buf#
        ldy  buf0,x
        bpl  pi1

        sta  buf0,x
        rts

pi1     sta  buf1,x
        rts

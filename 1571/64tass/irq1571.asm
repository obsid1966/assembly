
jirq	pha     	; save .a,.x,.y
        txa
        pha
        tya
        pha

        lda  icr	; chk for fast byte
	and  #8
	beq  irq_1

irq_0	lda  fastsr
        ora  #$40       ; set byte in flag
        sta  fastsr
	bne  irq_2	; bra

irq_1	lda  ifr1	; test for atn
	and  #2
	beq  +

	bit  pa1	; clear (ca1)
	lda  #1         ; handle atn request
        sta  atnpnd     ; flag atn is pending

+	tsx     	; check break flag
        lda  $0104,x    ; check processor status
        and  #$10
        beq  +

        jsr  jlcc       ; forced irq do controller job

+	lda  ifr2	; test if timer
	asl  a
	bpl  +

        jsr  jlcc       ; goto controller

+
irq_2	pla     	; restore .y,.x,.a
        tay
        pla
        tax
        pla
        rti

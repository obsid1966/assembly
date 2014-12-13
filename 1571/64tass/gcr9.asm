
	.align 256	; even page boundary

gcrtbh  .byte    $ff    ; -d
        .byte    $ff    ; -c
        .byte    $ff    ; -b
        .byte    $ff    ; -a
        .byte    $ff    ; -9
        .byte    $ff    ; -8
        .byte    $ff    ; -7
        .byte    $ff    ; -6
        .byte    $ff    ; -5
        .byte    $08    ; -4  h
	.byte    $00    ; -3  h
	.byte    $01    ; -2  h
	.byte    $ff    ; -1
gcrtba  .byte    $0c    ; 0  h
gcrtbf  .byte    $04    ; 1  h
gcrtbd  .byte    $05    ; 2  h
	.byte    $ff    ; 4
	.byte    $ff	; 3
	.byte    $02    ; 5  h
	.byte    $03    ; 6  h
	.byte    $ff    ; 7
	.byte    $0f    ; 8  h
	.byte    $06    ; 9  h
	.byte    $07    ; a  h
	.byte    $ff    ; b
	.byte    $09    ; c  h
	.byte    $0a    ; d  h
	.byte    $0b    ; e  h
	.byte    $ff    ; f
gcrtbe  .byte    $0d    ; 10  h
	.byte    $0e    ; 11  h
	.byte    $80    ; 12  c
	.byte    $ff    ; 13
	.byte    $00    ; 14  c
	.byte    $00    ; 15  e
	.byte    $10    ; 16  c
	.byte    $40    ; 17  e
	.byte    $ff    ; 18
	.byte    $20    ; 19  e
	.byte    $c0    ; 1a  c
	.byte    $60    ; 1b  e
	.byte    $40    ; 1c  c
gcrtbg  .byte    $a0    ; 1d  e
	.byte    $50    ; 1e  c
	.byte    $e0    ; 1f  e
	.byte    $ff    ; 20
	.byte    $ff    ; 21
	.byte    $ff    ; 22
	.byte    $02    ; 23  d
	.byte    $20    ; 24  c
	.byte    $08    ; 25  f
	.byte    $30    ; 26  c
	.byte    $ff    ; 27
	.byte    $ff    ; 28
        .byte    $00    ; 29  f
	.byte    $f0    ; 2a  c
	.byte    $ff    ; 2b
	.byte    $60    ; 2c  c
	.byte    $01    ; 2d  f
	.byte    $70    ; 2e  c
	.byte    $ff    ; 2f
	.byte    $ff    ; 30
	.byte    $ff    ; 31
	.byte    $90    ; 32  c
	.byte    $03    ; 33  d
	.byte    $a0    ; 34  c
	.byte    $0c    ; 35  f
	.byte    $b0    ; 36  c
	.byte    $ff    ; 37
	.byte    $ff    ; 38
	.byte    $04    ; 39  f
	.byte    $d0    ; 3a  c
	.byte    $ff    ; 3b
	.byte    $e0    ; 3c  c
	.byte    $05    ; 3d  f
	.byte    $80    ; 3e  g
	.byte    $ff    ; 3f
	.byte    $90    ; 40  g
	.byte    $ff    ; 41
	.byte    $08    ; 42  b
	.byte    $0c    ; 43  b
	.byte    $ff    ; 44
	.byte    $0f    ; 45  b
	.byte    $09    ; 46  b
	.byte    $0d    ; 47  b
	.byte    $80    ; 48  a
	.byte    $02    ; 49  f
	.byte    $ff    ; 4a
	.byte    $ff    ; 4b
	.byte    $ff    ; 4c
	.byte    $03    ; 4d  f
	.byte    $ff    ; 4e
	.byte    $ff    ; 4f
	.byte    $00    ; 50  a
	.byte    $ff    ; 51
	.byte    $ff    ; 52
	.byte    $0f    ; 53  d
	.byte    $ff    ; 54
	.byte    $0f    ; 55  f
	.byte    $ff    ; 56
	.byte    $ff    ; 57
	.byte    $10    ; 58  a
	.byte    $06    ; 59  f
	.byte    $ff    ; 5a
	.byte    $ff    ; 5b
	.byte    $ff    ; 5c
	.byte    $07    ; 5d  f
	.byte    $00    ; 5e  g
	.byte    $20    ; 5f  g
	.byte    $a0    ; 60  g
	.byte    $ff    ; 61
	.byte    $ff    ; 62
	.byte    $06    ; 63  d
	.byte    $ff    ; 64
	.byte    $09    ; 65  f
	.byte    $ff    ; 66
	.byte    $ff    ; 67
	.byte    $c0    ; 68  a
	.byte    $0a    ; 69  f
	.byte    $ff    ; 6a
	.byte    $ff    ; 6b
	.byte    $ff    ; 6c
	.byte    $0b    ; 6d  f
	.byte    $ff    ; 6e
	.byte    $ff    ; 6f
	.byte    $40    ; 70  a
	.byte    $ff    ; 71
	.byte    $ff    ; 72
	.byte    $07    ; 73  d
	.byte    $ff    ; 74
	.byte    $0d    ; 75  f
	.byte    $ff    ; 76
	.byte    $ff    ; 77
	.byte    $50    ; 78  a
	.byte    $0e    ; 79  f
	.byte    $ff	; 7a
	.byte    $ff	; 7b
	.byte    $ff	; 7c
	.byte    $ff	; 7d
	.byte    $10    ; 7e  g
	.byte    $30    ; 7f  g
	.byte    $b0    ; 80  g
	.byte    $ff    ; 81
	.byte    $00    ; 82  b
	.byte    $04    ; 83  b
	.byte    $02    ; 84  b
	.byte    $06    ; 85  b
	.byte    $0a    ; 86  b
	.byte    $0e    ; 87  b
	.byte    $80    ; 88  a
	.byte    $ff    ; 89
	.byte    $ff    ; 8a
	.byte    $ff    ; 8b
	.byte    $ff    ; 8c
	.byte    $ff    ; 8d
	.byte    $ff    ; 8e
	.byte    $ff    ; 8f
	.byte    $20    ; 90  a
	.byte    $ff    ; 91
	.byte    $08    ; 92  d
	.byte    $09    ; 93  d
	.byte    $80    ; 94  e
	.byte    $10    ; 95  e
	.byte    $c0    ; 96  e
	.byte    $50    ; 97  e
	.byte    $30    ; 98  a
	.byte    $30    ; 99  e
	.byte    $f0    ; 9a  e
	.byte    $70    ; 9b  e
	.byte    $90    ; 9c  e
	.byte    $b0    ; 9d  e
	.byte    $d0    ; 9e  e
	.byte    $ff    ; 9f
	.byte    $ff    ; a0
	.byte    $ff    ; a1
	.byte    $00    ; a2  d
	.byte    $0a    ; a3  d
	.byte    $ff    ; a4
	.byte    $ff    ; a5
	.byte    $ff    ; a6
	.byte    $ff    ; a7
	.byte    $f0    ; a8  a

stbctl  brk     	; a9  *** start code stbctl
        nop     	; aa
stbknt  lda  $00,x      ; ab,ac
        bmi  stbknt     ; ad,ae
        rts     	; af  *** end code stbctl

	.byte    $60    ; b0  a
	.byte    $ff    ; b1
	.byte    $01    ; b2  d
	.byte    $0b    ; b3  d
	.byte    $ff    ; b4
	.byte    $ff    ; b5
	.byte    $ff    ; b6
	.byte    $ff    ; b7
	.byte    $70    ; b8  a
	.byte    $ff    ; b9
	.byte    $ff    ; ba
	.byte    $ff    ; bb
	.byte    $ff    ; bc
	.byte    $ff    ; bd
	.byte    $c0    ; be  g
	.byte    $f0    ; bf  g
	.byte    $d0    ; c0  g
	.byte    $ff    ; c1
	.byte    $01    ; c2  b
	.byte    $05    ; c3  b
	.byte    $03    ; c4  b
	.byte    $07    ; c5  b
	.byte    $0b    ; c6  b
	.byte    $ff    ; c7
	.byte    $90    ; c8  a
	.byte    $ff    ; c9
	.byte    $ff    ; ca
	.byte    $ff    ; cb
	.byte    $ff    ; cc
	.byte    $ff    ; cd
	.byte    $ff    ; ce
	.byte    $ff    ; cf
	.byte    $a0    ; d0  a
	.byte    $ff    ; d1
	.byte    $0c    ; d2  d
	.byte    $0d    ; d3  d
	.byte    $ff    ; d4
	.byte    $ff    ; d5
	.byte    $ff    ; d6
	.byte    $ff    ; d7
	.byte    $b0    ; d8  a
	.byte    $ff    ; d9
	.byte    $ff    ; da
	.byte    $ff    ; db
	.byte    $ff    ; dc
	.byte    $ff    ; dd
	.byte    $40    ; de  g
	.byte    $60    ; df  g
	.byte    $e0    ; e0  g
	.byte    $ff    ; e1
	.byte    $04    ; e2  d
	.byte    $0e    ; e3  d
	.byte    $ff    ; e4
	.byte    $ff    ; e5
	.byte    $ff    ; e6
	.byte    $ff    ; e7
	.byte    $d0    ; e8  a
	.byte    $ff    ; e9
	.byte    $ff    ; ea
	.byte    $ff    ; eb
	.byte    $ff    ; ec
	.byte    $ff    ; ed
	.byte    $ff    ; ee
	.byte    $ff    ; ef
	.byte    $e0    ; f0  a
	.byte    $ff    ; f1
	.byte    $05    ; f2  d
	.byte    $ff    ; f3
	.byte    $ff    ; f4
	.byte    $ff    ; f5
	.byte    $ff    ; f6
	.byte    $ff    ; f7
	.byte    $ff    ; f8
	.byte    $ff    ; f9
	.byte    $ff    ; fa
	.byte    $ff    ; fb
	.byte    $ff    ; fc
	.byte    $ff    ; fd
 	.byte    $50    ; fe  g
	.byte    $70    ; ff  g

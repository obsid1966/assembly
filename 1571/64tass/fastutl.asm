;NOTE: ALL BURST COMMANDS ARE SENT VIA KERNAL I/O CALLS.
;
;BURST CMD ONE - READ
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      T       E       B       S       0       0       0       N
;----------------------------------------------------------------------------
;       03                     DESTINATION TRACK
;----------------------------------------------------------------------------
;       04                     DESTINATION SECTOR
;----------------------------------------------------------------------------
;       05                     NUMBER OF SECTORS
;----------------------------------------------------------------------------
;       06                     NEXT TRACK (OPTIONAL)
;----------------------------------------------------------------------------
;
;
;   RANGE:
;
;       MFM ALL VALUES ARE DETERMINED UPON THE PARTICULAR DISK FORMAT.
;       GCR SEE SOFTWARE SPECIFICATIONS.
;
;
;SWITCHES:
;
;       T - TRANSFER DATA (1=NO TRANSFER)
;       E - IGNORE ERROR (1=IGNORE)
;       B - BUFFER TRANSFER ONLY (1=BUFFER TRANSFER ONLY)
;       S - SIDE SELECT (MFM ONLY)
;       N - DRIVE NUMBER
;
;
;
;PROTOCOL:
;
;       BURST HANDSHAKE.
;
;
;
;CONVENTIONS:
;
;       CMD ONE MUST BE PRECEEDED  WITH CMD 3 OR CMD 6 ONCE  AFTER
;       A NEW DISK IS INSERTED.
;
;
;OUTPUT:
;       ONE  BURST  STATUS  BYTE PRECEEDING BURST DATA WILL BE SENT
;       FOR  EVERY  SECTOR  TRANSFERED.    ON  AN  ERROR  CONDITION
;       DATA  WILL NOT BE SENT UNLESS THE E BIT IS SET.
;BURST CMD TWO - WRITE
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      T       E       B       S       0       0       1       N
;----------------------------------------------------------------------------
;       03                     DESTINATION TRACK
;----------------------------------------------------------------------------
;       04                     DESTINATION SECTOR
;----------------------------------------------------------------------------
;       05                     NUMBER OF SECTORS
;----------------------------------------------------------------------------
;       06                     NEXT TRACK (OPTIONAL)
;----------------------------------------------------------------------------
;
;
;   RANGE:
;
;       MFM ALL VALUES ARE DETERMINED UPON THE PARTICULAR DISK FORMAT.
;       GCR SEE SOFTWARE SPECIFICATIONS.
;
;
;SWITCHES:
;
;       T - TRANSFER DATA (1=NO TRANSFER)
;       E - IGNORE ERROR (1=IGNORE)
;       B - BUFFER TRANSFER ONLY (1=BUFFER TRANSFER ONLY)
;       S - SIDE SELECT (MFM ONLY)
;       N - DRIVE NUMBER
;
;
;
;PROTOCOL:
;
;       BURST HANDSHAKE.
;
;
;
;CONVENTIONS:
;
;       CMD TWO MUST BE PRECEEDED  WITH CMD 3 OR CMD 6 ONCE  AFTER
;       A NEW DISK IS INSERTED.
;
;
;INPUT:
;       HOST MUST TRANSFER BURST DATA.
;
;
;OUTPUT:
;       ONE BURST STATUS  BYTE FOLLOWING EACH WRITE OPERATION.
;BURST CMD THREE - INQUIRE DISK
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      X       X       X       S       0       1       0       N
;----------------------------------------------------------------------------
;
;
;
;SWITCHES:
;
;       S - SIDE SELECT (MFM ONLY)
;       N - DRIVE NUMBER
;
;
;OUTPUT:
;       ONE BURST STATUS  BYTE FOLLOWING THE INQUIRE OPERATION.
;BURST CMD FOUR - FORMAT MFM
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      P       I       D       S       0       1       1       N
;----------------------------------------------------------------------------
;       03      M=1      T                LOGICAL STARTING SECTOR
;----------------------------------------------------------------------------
;       04           INTERLEAVE            (OPTIONAL DEF-0)
;----------------------------------------------------------------------------
;       05           SECTOR SIZE         * (OPTIONAL 01 for 256 Byte Sectors)
;----------------------------------------------------------------------------
;       06           LAST TRACK NUMBER     (OPTIONAL DEF-39)
;----------------------------------------------------------------------------
;       07           NUMBER OF SECTORS     (OPTIONAL DEPENDS ON BYTE 05)
;----------------------------------------------------------------------------
;       08          LOGICAL STARTING TRACK (OPTIONAL DEF-0)
;----------------------------------------------------------------------------
;       09           STARTING TRACK OFFSET (OPTIONAL DEF-0)
;----------------------------------------------------------------------------
;       0A           FILL BYTE             (OPTIONAL DEF-$E5)
;----------------------------------------------------------------------------
;       0B-??        SECTOR TABLE          (OPTIONAL T-BIT SET)
; ----------------------------------------------------------------------------
;
;SWITCHES:
;
;       P - PARTIAL FORMAT (1=PARTIAL)
;       I - INDEX ADDRESS MARK WRITTEN (1=WRITTEN)
;       D - DOUBLE SIDED FLAG (1=FORMAT DOUBLE SIDED)
;       S - SIDE SELECT
;       T - SECTOR TABLE INCLUDED (1=INCLUDED, ALL OTHER PARMS
;           MUST BE INCLUDED)
;       N - DRIVE NUMBER
;
;
;PROTOCOL:
;
;       CONVENTIONAL.
;
;
;
;CONVENTIONS:
;
;       AFTER FORMATTING CMD 3 MUST BE SENT ON CONVENTIONAL FORMAT
;       OR CMD 6 ON A NON-CONVENTIONAL FORMAT.
;
;
;OUTPUT:
;        NONE.  STATUS WILL BE UPDATED WITHIN THE DRIVE.
;
; * 00 - 128 byte sectors
;   01 - 256 byte sectors
;   02 - 512 byte sectors
;   03 - 1024 byte sectors
;BURST CMD FOUR - FORMAT GCR (NO DIRECTORY)
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      X       X       X       X       0       1       1       N
;----------------------------------------------------------------------------
;       03      M=0
;----------------------------------------------------------------------------
;       04                     ID LOW
;----------------------------------------------------------------------------
;       05                     ID HIGH
;----------------------------------------------------------------------------
;
;
;SWITCHES:
;
;       N - DRIVE NUMBER
;       X - DON'T CARE.
;
;PROTOCOL:
;
;       CONVENTIONAL.
;
;
;CONVENTIONS:
;
;       AFTER FORMATTING CMD 3 MUST BE SENT.
;
;       NOTE: THIS  COMMAND  DOES NOT WRITE THE BAM OR THE
;       DIRECTORY ENTRIES  ( DOUBLE SIDED FLAG WILL NOT BE
;       ON TRACK 18, SECTOR 0).  IT  IS SUGGESTED THAT THE
;       CONVENTIONAL 'NEW' FORMAT COMMAND BE USED.
;
;OUTPUT:
;        NONE.  STATUS WILL BE UPDATED WITHIN THE DRIVE.
;BURST CMD FIVE - SECTOR INTERLEAVE
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      W       X       X       0       1       0       0       N
;----------------------------------------------------------------------------
;       04                     INTERLEAVE
;----------------------------------------------------------------------------
;
;
;SWITCHES:
;
;       W - WRITE SWITCH
;       N - DRIVE NUMBER
;       X - DON'T CARE
;
;PROTOCOL:
;
;       CONVENTIONAL, UNLESS THE W-BIT IS SET.
;
;
;CONVENTIONS:
;
;       THIS IS A SOFT INTERLEAVE USED FOR MULTI-SECTOR BURST
;       READ AND WRITE.
;
;OUTPUT:
;        NONE (W=0), INTERLEAVE BURST BYTE (W=1)
;BURST CMD SIX - QUERY DISK FORMAT
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      F       X       T       S       1       0       1       N
;----------------------------------------------------------------------------
;       03                  OFFSET      (OPTIONAL F-BIT SET)
;----------------------------------------------------------------------------
;
;
;SWITCHES:
;
;       F - FORCE FLAG (F=1, WILL STEP THE HEAD WITH THE
;       T - END SECTOR TABLE (T=1, SEND)
;       N - DRIVE NUMBER
;       X - DON'T CARE.
;
;PROTOCOL:
;
;       CONVENTIONAL.
;
;
;CONVENTIONS:
;
;       THIS IS A METHOD OF DETERMINING THE FORMAT OF THE DISK ON
;       ANY PARTICULAR TRACK.
;
;
;OUTPUT:
;       BURST STATUS BYTE (IF THERE WAS AN ERROR OR IF THE
;                          FORMAT IS GCR NO BYTES WILL FOLLOW)
;       BURST STATUS BYTE (IF THERE WAS AN ERROR IN COMPILING
;                          MFM FORMAT INFORMATION NO BYTES
;                          WILL FOLLOW)
;       NUMBER OF SECTORS (THE NUMBER OF SECTORS ON A PARTICULAR
;                          TRACK)
;       LOGICAL TRACK     (THE LOGICAL TRACK NUMBER FOUND IN THE
;                          DISK HEADER)
;       MINIMUM SECTOR    (THE LOGICAL SECTOR WITH THE LOWEST
;                          VALUE ADDRESS)
;       MAXIMUM SECTOR    (THE LOGICAL SECTOR WITH THE HIGHEST
;                          VALUE ADDRESS)
;       CP/M INTERLEAVE   (THE HARD INTERLEAVE FOUND ON A PARTICULAR
;                          TRACK)
;
;BURST CMD SEVEN - INQUIRE STATUS
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      W       C       X       0       1       1       0       N
;----------------------------------------------------------------------------
;       03                      NEW STATUS (W-BIT CLEAR)
;----------------------------------------------------------------------------
;
;SWITCHES:
;
;       W - WRITE SWITCH
;       C - CHANGE (C=1 & W=0 - FORCE LOGIN DISK,
;                   C=1 & W=1 - RETURN WHETHER DISK WAS LOGGED
;                   IE. $XB ERROR OR OLD STATUS)
;       N - DRIVE NUMBER
;       X - DON'T CARE
;
;PROTOCOL:
;
;       BURST.
;
;
;CONVENTIONS:
;
;       THIS IS A METHOD OF READING OR WRITING CURRENT STATUS.
;
;
;OUTPUT:
;        NONE (W=0), BURST STATUS BYTE (W=1)
;
;
;BURST CMD EIGHT - BACKUP DISK
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      ?       ?       ?       ?       1       1       1       ?
;----------------------------------------------------------------------------
;
;SWITCHES:
;
;       ? - GOT ME
;
;BURST CMD NINE - CHGUTL UTILITY
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      X       X       X       1       1       1       1       0
;----------------------------------------------------------------------------
;       03         UTILITY COMMANDS: 'S', 'R', 'T', 'M', 'H', #DEV
;----------------------------------------------------------------------------
;       04         COMMAND PARAMETER
;----------------------------------------------------------------------------
;SWITCHES:
;
;       X - DON'T CARE.
;
;
;
;UTILITY COMMANDS:
;
;       'S' - DOS SECTOR INTERLEAVE.
;       'R' - DOS RETRIES.
;       'T' - ROM SIGNATURE ANALYSIS.
;       'M' - MODE SELECT.
;       'H' - HEAD SELECT.
;       'V' - WRITE WITH VERIFY.
;      #DEV - DEVICE #.
;
;
;NOTE: BYTE 02 IS EQUIVALENT TO A '>'
;
;EXAMPLES:
;       "U0>S"+CHR$(SECTOR-INTERLEAVE)
;       "U0>R"+CHR$(RETRIES)
;       "U0>T"
;       "U0>M1"=1571 MODE, "U0>M0"=1541 MODE
;       "U0>H0"=SIDE ZERO, "U0>H1"=SIDE ONE (1541 MODE ONLY)
;       "U0>V0"=VERIFY ON, "U0>V1"=NO VERIFY (1571 MODE ONLY)
;       "U0>"+CHR$(#DEV), WHERE #DEV = 4-30
;BURST CMD TEN - FASTLOAD UTILITY
;
;
;     BYTE  BIT 7       6       5       4       3       2       1       0
;============================================================================
;       00      0       1       0       1       0       1       0       1
;----------------------------------------------------------------------------
;       01      0       0       1       1       0       0       0       0
;----------------------------------------------------------------------------
;       02      P       X       X       1       1       1       1       1
;----------------------------------------------------------------------------
;       03                    FILE NAME
;----------------------------------------------------------------------------
;
;SWITCHES:
;
;       P - SEQUENTIAL FILE BIT (P=1, DOES NOT HAVE TO BE A PROGRAM
;                                     FILE)
;       X - DON'T CARE.
;
;PROTOCOL:
;
;       BURST.
;
;
;OUTPUT:
;        BURST STATUS BYTE PRECEEDING EACH SECTOR TRANSFERED.
;
;STATUS IS AS FOLLOWS:
;
;       0000000X ............. OK
;     * 00000010 ............. FILE NOT FOUND
;    ** 00011111 ............. EOI
;
;* VALUES BETWEEN THE RANGE 3-15 SHOULD BE CONSIDERED A FILE READ ERROR.
;** EOI STATUS BYTE, FOLLOWED BY NUMBER OF BYTES TO FOLLOW.
;STATUS BYTE BREAK DOWN
;
;
;      BIT 7       6       5       4       3       2       1       0
;============================================================================
;        MODE      DN     SECTOR SIZE      [  CONTROLLER  STATUS   ]
;----------------------------------------------------------------------------
;
; Values Represented are in Binary
;
;       MODE - 1=MFM, 0=GCR
;         DN - DRIVE NUMBER
;
; SECTOR SIZE - (MFM ONLY)
;              00 .... 128 BYTE SECTORS
;              01 .... 256 BYTE SECTORS
;              10 .... 512 BYTE SECTORS
;              11 .... 1024 BYTE SECTORS
;
; CONTROLLER STATUS (GCR)
;            000X .... OK
;            0010 .... SECTOR NOT FOUND
;            0011 .... NO SYNC
;            0100 .... DATA BLOCK NOT FOUND
;            0101 .... DATA BLOCK CHECKSUM ERROR
;            0110 .... FORMAT ERROR
;            0111 .... VERIFY ERROR
;            1000 .... WRITE PROTECT ERROR
;            1001 .... HEADER BLOCK CHECKSUM ERROR
;            1010 .... DATA EXTENDS INTO NEXT BLOCK
;            1011 .... DISK ID MISMATCH/ DISK CHANGE
;            1100 .... RESERVED
;            1101 .... RESERVED
;            1110 .... SYNTAX ERROR
;            1111 .... NO DRIVE PRESENT
;
; CONTROLLER STATUS (MFM)
;            000X .... OK
;            0010 .... SECTOR NOT FOUND
;            0011 .... NO ADDRESS MARK
;            0100 .... RESERVED
;            0101 .... DATA CRC ERROR
;            0110 .... FORMAT ERROR
;            0111 .... VERIFY ERROR
;            1000 .... WRITE PROTECT ERROR
;            1001 .... HEADER BLOCK CHECKSUM ERROR
;            1010 .... RESERVED
;            1011 .... DISK CHANGE
;            1100 .... RESERVED
;            1101 .... RESERVED
;            1110 .... SYNTAX ERROR
;            1111 .... NO DRIVE PRESENT
;
;EXAMPLE BURST ROUTINES WRITTEN ON C 128
;       *=$1800
;
;  ROUTINE TO READ N-BLOCKS OF DATA
;  COMMAND CHANNEL MUST BE OPEN ON DRIVE
;  OPEN 15,8,15
;  BUFFER AND CMD_BUF, AND CMD_LENGTH MUST BE SETUP
;  PRIOR TO CALLING THIS COMMAND.
;
;serial  = $0a1c        ; fast serial flag
;d2pra   = $dd00
;clkout  = $10
;d1icr   = $dc0d
;d1sdr   = $dc0c
;stat    = $fa
;buffer  = $fb          ; $fb & $fc
;
;       lda  #15        ; logical file number
;       ldx  #8         ; device number
;       ldy  #15        ; secondary address
;       jsr  setlfs     ; setup logical file
;
;       lda  #0         ; noname
;       jsr  setnam     ; setup file name
;
;       jsr  open       ; open logical channel
;
; after the command channel is open subsequent calls should be from 'read'
;
;read   lda  #$00
;       sta  stat       ; clear status
;       lda  serial
;       and  #%10111111 ; clear bit 6 fast serial flag
;       sta  serial
;       ldx  #15
;       jsr  chkout     ; open channel for output
;       ldx  #0
;       ldy  cmd_length ; length of the command
;1$     lda  cmd_buf,x  ; get command
;       jsr  bsout      ; send the command
;       inx
;       dey
;       bne  1$
;
;       jsr  clrchn     ; send eoi
;       bit  serial     ; check speed of drive
;       bvc  error      ; slow serial drive
;
;       sei
;       bit  d1icr      ; clear interrupt control reg
;       ldx  cmd_buf+5  ; get # of sectors
;       lda  d2pra      ; read serial port
;       eor  #clkout    ; change state of clock
;       sta  d2pra      ; store back
;
;read_itlda  #8
;1$     bit  d1icr      ; wait for byte
;       beq  1$
;
;       lda  d2pra      ; read serial port
;       eor  #clkout    ; change state of clock
;       sta  d2pra      ; store back
;
;       Code to check status byte.
;
;   1) This code will check for mode
;      whether GCR or MFM.
;   2) Verify sector size.
;   3) Check for error, if ok then continue.
;      On error, check error switch if set continue
;      otherwise abort.
;   4) Verify switches
;
;       lda  d1sdr      ; get data from serial data reg
;       sta  stat       ; save status
;       and  #15
;       cmp  #2         ; just check for (3)
;       bcs  error
;
;       ldy  #0         ; even page
;top_rd lda  #8
;1$     bit  d1icr      ; wait for byte
;       beq  1$
;
;       lda  d2pra      ; toggle clock
;       eor  #clkout
;       sta  d2pra
;
;       lda  d1sdr      ; get data
;       sta  (buffer),y ; save data
;       iny
;       bne  top_rd     ; continue for buffer size
;
;       dex
;       beq  done_read  ; done ?
;
;       inc  buffer+1   ; next buffer
;       jmp  read_it
;
;done_read
;       clc
;       .byte  $24
;error  sec
;       rts             ; return to sender
;
;cmd_buf .text 'U0',0,0,0,0,0
;
;       *=$1800
;
;  ROUTINE TO WRITE N-BLOCKS OF DATA
;  COMMAND CHANNEL MUST BE OPEN ON DRIVE
;  OPEN 15,8,15
;  BUFFER AND CMD_BUF, AND CMD_LENGTH MUST BE SETUP
;  PRIOR TO CALLING THIS COMMAND.
;
;serial  = $0a1c        ; fast serial flag
;d2pra   = $dd00
;clkout  = $10
;old_clk = $fd
;clkin   = $40
;d1icr   = $dc0d
;d1sdr   = $dc0c
;stat    = $fa
;buffer  = $fb          ; $fb & $fc
;mmureg  = $d505
;d1timh  = $dc05        ; timer a high
;d1timl  = $dc04        ; timer a low
;d1cra   = $dc0e        ; control reg a
;
;       lda  #15        ; logical file number
;       ldx  #8         ; device number
;       ldy  #15        ; secondary address
;       jsr  setlfs     ; setup logical file
;       jsr  setnam     ; setup file name
;
;       jsr  open       ; open logical channel
;
;
; after the command channel is open subsequent calls should be from 'write'
;
;write  lda  #$00
;       sta  stat
;       lda  serial
;       and  #%10111111 ; clear bit 6 fast serial flag
;       sta  serial
;       ldx  #15
;       jsr  chkout     ; open channel for output
;
;       ldx  #0
;       ldy  cmd_length ; length of the command
;1$     lda  cmd_buf,x  ; get command
;       jsr  bsout      ; send the command
;       inx
;       dey
;       bne  1$
;
;       jsr  clrchn     ; send eoi
;
;       bit  serial     ; check speed of drive
;       bvc  error
;
;       sei
;       lda  #clkin
;       sta  old_clk    ; clock starts high
;
;       ldy  #0         ; even page
;       ldx  cmd_buf+5  ; get # of sectors
;writ_itjsr  spout      ; serial port out
;1$     lda  d2pra      ; check clock
;       cmp  d2pra      ; debounce
;       bne  1$
;
;       eor  old_clk
;       and  #clkin
;       beq  1$
;
;       lda  old_clk    ; change status of old clock
;       eor  #clkin
;       sta  old_clk
;
;       lda  (buffer),y ; send data
;       sta  d1sdr
;
;********* OPTIONAL **********
;
;       lda  #8         ; put code here or before spin
;2$     bit  d1icr      ; wait for transmission time
;       beq  2$
;
;*****************************
;
;       iny
;       bne  1$         ; continue for buffer size
;
; talker turn around
;
;  WAIT CODE HERE (OPTIONAL)
;
;       jsr  spin       ; serial port input
;       bit  d1icr      ; clear pending
;       jsr  clklo      ; set clk low, tell him we are ready
;
;       lda  #8
;3$     bit  d1icr      ; wait for status byte
;       beq  3$
;
;       lda  d1sdr      ; get data from serial data reg
;       sta  stat       ; save status
;       jsr  clkhi      ; set clock high
;
;       Code to check status byte.
;
;   1) This code will check for mode
;      whether GCR or MFM.
;   2) Verify sector size.
;   3) Check for error, if ok then continue.
;      On error, check error switch if set continue
;      otherwise abort.
;   4) Verify switches
;
;       lda  stat       ; retrieve status
;       and  #15
;       cmp  #2         ; just chk for error only (3)
;       bcs  error      ; finish
;
;       dex
;       beq  done_wr    ; done ?
;
;       inc  buffer+1   ; next buffer
;       jmp  wrt_it
;
;done_wr
;       cli
;       .byte $24
;error  sec
;       rts
;
;cmd_buf .byte 'U0',2,0,0,0,0
;
; subroutines
;
; NOTE: spout and spin are C128 kernal vectors (refer to C128 users manual)
;
;
;spout  lda  mmureg     ; change serial direction to output
;       ora  #$08
;       sta  mmureg
;       lda  #$7f
;       sta  d1icr      ; no irq's
;       lda  #$00
;       sta  d1timh
;       lda  #$03
;       sta  d1timl     ; low 6 us bit (fastest)
;       lda  d1cra
;       and  #$80       ; keep TOD
;       ora  #$55
;       sta  d1cra      ; setup CRA for output
;       bit  d1icr      ; clr pending
;       rts
;
;spin   lda  d1cra
;       and  #$80       ; save TOD
;       ora  #$08       ; change fast serial for input
;       sta  d1cra      ; input for 6526
;       lda  mmureg
;       and  #$f7
;       sta  mmureg     ; mmu serial direction in
;       rts
;
;clklo  lda  d2pra      ; set clock low
;       ora  #clkout
;       sta  d2pra
;       rts
;
;clkhi  lda  d2pra      ; set clock high
;       and  #$ff-clkout
;       sta  d2pra
;       rts
;
; ****** END EXAMPLES ******
;
; (1) FAST READ

fstrd   sta  cmd        ; save command for dos
        sta  ctl_cmd    ; save command for stbctt

        lda  ifr1       ; disk change
        lsr  a
        bcc  frd_00     ; br, ok

        ldx  #%00001011 ; no channel
        .byte skip2
ndkrd   ldx  #%01001111 ; no drive

fail    jsr  upinst     ; update dkmode
finbad  jsr  statqy     ; wait for state handshake
final   cpx  #2
        bcs  exbad

        rts

exbad   txa             ; retrieve status
        and  #15        ; bits 0-3 only
        ldx  #0         ; jobnum
        jmp  error      ; controller error entry


frd_00  jsr  spout

        bit  dkmode     ; gcr or mfm ?
        bpl  rdgcr


;       MFM READ

        lda  #9         ; read cmd
        jmp prcmd

rdgcr   jsr  autoi      ; check for auto init

frd_01  cli             ; let controller run
        lda  switch     ; check for B
        and  #%00100000
        bne  bfonly

        lda  cmdbuf+3   ; get track
        sta  hdrs
        lda  cmdbuf+4   ; get sector
        sta  hdrs+1
        ldx  #0         ; job #0
        lda  ctl_cmd    ; read ($80) or fread ($88)
        sta  jobs,x
        jsr  stbctt     ; hit controller hard

        sei             ; disable irqs
        jsr  upinst     ; update controller status

        bit  switch     ; check E
        bvs  igerr

        cpx  #2         ; error
        bcs  fail

igerr   jsr  hskrd      ; handshake on state of clkin

        lda  switch     ; check B
        bmi  notran

bfonly  ldy  #0         ; even page
frd_02  lda  $0300,y    ; get data
        sta  ctl_dat    ; setup data
        jsr  hskrd      ; handshake on state
        iny
        bne  frd_02

notran  dec  cmdbuf+5   ; any more sectors ?
        beq  exrd

        jsr  sektr      ; next sector
        jmp  frd_01     ; more to do

exrd    cli
        jmp  chksee     ; next track ?

; (2) FAST WRITE

fstwrt
        sta  cmd        ; save command for dos
        lda  ifr1       ; disk change
        lsr  a
        bcc  fwrt_0     ; br, ok

        ldx  #%00001011 ; no channel
        .byte  skip2
ndkwrt  ldx  #%01001111 ; no drv 1
        stx  ctl_dat    ; save status
        lda  switch     ; set internal switch
        ora  #%00001000
        sta  switch

fwrt_0  bit  dkmode     ; gcr or mfm ?
        bpl  wrtgcr


;       MFM WRITE

        lda  #10
        jmp  prcmd

wrtgcr  jsr  autoi      ; chk for autoi

        lda  switch     ; transmision required
        bmi  notrx

fwrt_1  sei             ; no irqs
        ldy  #0         ; even page
fwrt_2  lda  pb         ; debounce
        eor  #clkout    ; toggle state of clock
        bit  icr        ; clear pending
        sta  pb
fwrt_4  lda  pb
        bpl  fwrt_3     ; br, attn not low

        jsr  tstatn     ; chk for atn

fwrt_3  lda  icr        ; wait for byte
        and  #8
        beq  fwrt_4     ; chk for attn low only

        lda  sdr        ; get data
        sta  $0300,y    ; put away data
        iny
        bne  fwrt_2     ; more ?

        jsr  clkhi      ; release clock
notrx   cli             ; let controller run
        lda  switch     ; check for buffer transfer only
        and  #%00100000
        bne  nowrt

        lda  switch     ; check internal
        and  #%00001000
        beq  notrx0     ; br, ok...

        ldx  ctl_dat    ; get error
        jmp  fail       ; abort

notrx0  lda  cmdbuf+3   ; get track
        sta  hdrs
        lda  cmdbuf+4   ; get sector
        sta  hdrs+1
        ldx  #0         ; job #0
        lda  #write     ; get write job
        sta  jobs,x
        jsr  stbctt     ; wack controller in the head

        sei             ; no irqs ok !
        jsr  spout      ; go output
        jsr  upinst     ; update status
        jsr  hskrd      ; send it
        jsr  burst      ; wait for reverse
        jsr  spinp
        cli             ; irqs ok now

        bit  switch     ; check error abort switch
        bvs  nowrt

        cpx  #2         ; error on job ?
        bcs  fwrt_5     ; abort ?

nowrt   dec  cmdbuf+5   ; more sectors ?
        beq  fwrt_6

        jsr  sektr      ; increment sector
        jmp  fwrt_1

fwrt_5  jmp  exbad

fwrt_6  cli             ; done
        jmp  chksee     ; next track ?

; (3) FAST SEEK

fstsek  .proc
        lda  cmdbuf+2   ; check drive number
        and  #1
        bne  m3         ; drive 1 - error

        lda  #1
        sta  ifr1       ; new disk
        lda  #5         ; read address cmd
        jsr  prcmd      ; give it to controller

        ldx  mfmcmd     ; get status
        cpx  #2         ; ok ?
        bcc  m2

        ldx  #0
        stx  dkmode     ; force gcr,drv0,ok
        lda  #seek      ; seek

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        jsr  ptch0c     ; *** rom ds 12/08/86 ***, set track
;       sta  cmd        ; give command to dos

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        sta  jobs,x     ; give job to controller
        jsr  stbctt     ; bang the controller
        .byte  skip2    ; return status
m3      ldx  #%01001111 ; no drv 1
m2      jmp  fail       ; update status
        .pend

; (4) BURST FORMAT MFM/GCR

fstfmt  .proc
        lda  cmdbuf+2   ; check drive number
        and  #1
        bne  m1

        lda  cmdbuf+3   ; format gcr or mfm ?
        bpl  m2


;       FORMAT IN MFM

        lda  #8         ; format disk in mfm
        jmp  prcmd

m2      lda  #0
        sta  dkmode     ; force GCR,DRV0
        sta  nodrv      ; drive ok
        lda  cmdbuf+4
        sta  dskid      ; low id
        lda  cmdbuf+5
        sta  dskid+1    ; high id

        jsr  clrchn     ; close all channels
        lda  #1
        sta  track      ; track one
        lda  #$ff
        sta  jobrtn     ; set error recovery
        jsr  ptch55     ; *** rom ds 06/18/85 ***, format

        tax             ; save error
        .byte skip2
m1      ldx  #%01001111
        jsr  upinst     ; update status
        jmp  final      ; finish up ...
        .pend

; (5) SOFT INTERLEAVE

cpmint  sei
        bit  switch     ; read ?
        bpl  +          ; br, write

        jsr  spout      ; serial port output
        lda  cpmit      ; get current interleave
        sta  ctl_dat    ; send it
        jmp  hskrd

+       ldx  cmdsiz
        cpx  #4
        bcs  +

        ldx  #%00001110 ; syntax
        jsr  upinst     ; update dkmode

        lda  #badcmd
        jmp  cmderr

+       lda  cmdbuf+3
        sta  cpmit      ; save
        rts
; (6) QUERY DISK FORMAT

querdk  .proc
        jsr  fstsek     ; check disk format
        bit  dkmode     ; mfm or gcr ?
        bpl  m2

        lda  #13
        jsr  prcmd      ; generate sector table

        ldx  mfmcmd     ; status ok ?
        cpx  #2
        bcs  +

        jsr  maxmin     ; determine low/high sector
        jsr  fn_int     ; determine interleave
        txa             ; hard interleave
        pha             ; save it

+       sei             ; no irq's
        jsr  spout      ; serial port output
        lda  dkmode     ; get status and send it
        sta  ctl_dat
        jsr  hskrd      ; transmit status

        ldx  mfmcmd     ; was status ok ?
        cpx  #2
        bcs  m3

        lda  cpmsek     ; get number of sectors
        sta  ctl_dat
        jsr  hskrd      ; send it

        lda  cmd_trk    ; get logical track number
        sta  ctl_dat
        jsr  hskrd      ; send track

        lda  minsek
        sta  ctl_dat    ; send min.
        jsr  hskrd      ; wait for handshake

        lda  maxsek     ; send max.
        sta  ctl_dat
        jsr  hskrd      ; wait for handshake

        pla             ; get interleave
        sta  ctl_dat    ; send interleave

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        jmp  ptch63     ; *** rom ds 01/23/86 ***, add sector table
;       jsr  hskrd      ; wait for handshake

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

m2      rts
m3      pla             ; restore stack
        jmp  exbad
        .pend
; (7) QUERY/INIT STATUS

inqst   bit  switch     ; read/write op ?
        bpl  wrstat

        bit  switch     ; wp latch ?
        bvc  statqy

        lda  ifr1
        lsr  a
        bcc  statqy     ; ok, give old status

        lda  dkmode
        and  #$f0       ; clr old
        ora  #$0b       ; disk change
        sta  dkmode     ; updated status

statqy  sei             ; disable irqs
        jsr  spout      ; serial port out
        lda  dkmode     ; get status
        sta  ctl_dat
        jsr  hskrd      ; 6526 will send it

        lda  #0
        sta  erword

exchnl  jsr  spinp      ; serial port input
exchn2  cli
        rts

wrstat  lda  cmdbuf+3   ; new value
        sta  dkmode
        bit  switch     ; wp latch ?
        bvc  +

        lda  #1
        sta  ifr1       ; new disk

+       rts
; (8) BACKUP DISK

duplc1  ldx  #%00001110
        jsr  upinst     ; update dkmode

        lda  #badcmd
        jmp  cmderr

;       SUBROUTINES

chksee  .proc
        lda  cmdsiz     ; chk for next track
        cmp  #7
        bcc  m3

        lda  hdrs       ; where are we ?
        tay             ; save
        sbc  #1         ; one less
        asl  a
        sta  cur_trk
        cpy  #36
        php             ; save status
        ldy  cmdbuf+6   ; destination
        sty  drvtrk
        dey
        sty  cmd_trk    ; initial detent
        cpy  #35
        ror  a          ; rotate carry into neg
        plp
        and  #$80       ; set/clr neg
        bcc  m1         ; br, we are on side zero

        bmi  m2         ; br, we are on side one & want to goto side one

        clc
        lda  cmd_trk    ; setup for pete seke
        adc  #35        ; select side
        sta  cmd_trk
        bmi  m2         ; bra more or less

m1      bpl  m2         ; br, we are on side zero & want to goto side zero

        sec
        lda  cmd_trk
        sbc  #35        ; select side
        sta  cmd_trk
m2      jmp  seke       ; do it
m3      rts
        .pend

;******************************************************

upinst  stx  ctl_dat
        lda  dkmode     ; update main status w/ controller status
        and  #%11110000 ; clear old controller status
        ora  ctl_dat    ; or in controller status
        sta  dkmode     ; updated
        sta  ctl_dat
        rts

;******************************************************

hsktst  jsr  tstatn     ; test for atn
hskrd
-       lda  pb         ; debounce
        cmp  pb
        bne  -

        and  #$ff       ; set/clr neg flag
        bmi  hsktst     ; br, attn low

        eor  fastsr     ; wait for state chg
        and  #4
        beq  -

hsksnd  lda  ctl_dat    ; retrieve data

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        jmp  ptch68     ; *** rom ds 05/16/86 ***
;       sta  sdr        ; send it

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        lda  fastsr
        eor  #4         ; change state of clk
        sta  fastsr
        lda  #8
-       bit  icr        ; wait transmission time
        beq  -

        rts

;******************************************************

sektr   lda  cmdbuf+3   ; get track
        cmp  #36        ; side one ?
        bcc  +

        sbc  #35        ; get offset
+       tax
        lda  num_sec-1,x
        tax
        dex
        stx  ctl_dat    ; save
        clc
        lda  cmdbuf+4   ; get sector
        adc  cpmit      ; add interleave
        cmp  ctl_dat    ; less than maxsec ?
        bcc  gtsec
        sbc  ctl_dat    ; rap around
        beq  oksec      ; special case on max
        sec
        sbc  #1         ; less one
        .byte skip2
oksec   lda  ctl_dat
gtsec   sta  cmdbuf+4   ; new sector
        lda  #fread     ; exread job
        sta  ctl_cmd
        rts

;******************************************************

stbctr  ldx  jobnum
        php
        cli             ; let controller run free
        jsr  stbctl     ; strobe controller ( hit him hard )
        cmp  #2         ; was there an error ?
        bcc  +          ; br, nope

        jsr  stbret     ; let DOS retry
        lda  jobs,x     ; get error

+       tax             ; return status in .x
        plp             ; restore status
        rts

;******************************************************

stbctt  ldx  #0         ; buffer zero
        php
        sei             ; no irq's during i/o access
        lda  ledprt
        ora  #8
        sta  ledprt     ; led on
        cli             ; let controller run free
        jsr  stbctl     ; strobe controller ( hit him hard )
        cmp  #2         ; was there an error ?
        bcc  +          ; br, nope

        jsr  stbret     ; let DOS retry

+       sei
        lda  ledprt
        and  #$ff-8
        sta  ledprt     ; led off
        lda  jobs,x     ; get error return
        tax             ; return status in .x
        plp             ; restore original status
        rts

;******************************************************

stbret  lda  #$ff       ; micro-step if you can
        sta  jobrtn     ; set error recovery on
        stx  jobnum     ; set job #
        lda  cmdbuf+2   ; get command
        sta  ctl_cmd    ; reset command
        sta  cmd        ; set for dos
        sta  lstjob,x   ; set last job
        sta  jobs,x     ; -04 fix 02/24/86 ds, give it to the controller
        jsr  stbctl     ; wait for it
        jmp  watjob     ; let dos clean it up

;******************************************************

burtst  jsr  tstatn     ; test for atn
burst
-       lda  pb         ; debounce
        cmp  pb
        bne  -          ; same ?

        and  #$ff       ; set/clr neg flag
        bmi  burtst     ; br, attn low

        eor  fastsr     ; wait for state chg
        and  #4
        beq  -

        lda  fastsr
        eor  #4
        sta  fastsr     ; state change
        rts

;******************************************************

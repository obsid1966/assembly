*=$0002                 ; zero page
jobs     *=*+9          ; job que=8 last 2 for bams
hdrs     *=*+18         ; job headers
dskid    *=*+2          ; master copy of disk id
header   *=*+6          ; image of last header
wpsw     *=*+1          ; write protect change flag
drvst    *=*+1          ; lcc var's
                        ; bits 7 6 5 4  3 2 1 0
                        ;
                        ;         -- timeout
                        ;        ---- running
                        ;       ------ stepping
                        ;      -------- accelerating
                        ;
                        ;ie:
                        ;       $00 = no drive active
                        ;       $20 = running
                        ;       $30 = running and timeout
                        ;       $50 = stepping and running
                        ;       $80 = accelerating

drvtrk   *=*+1
cmd      *=*+1          ; temp job command
cmdsiz   *=*+1          ; command string size
acltim   *=*+2          ; acceleration/decceleration time delay
savsp    *=*+1          ; save stack pointer
autofg   *=*+1          ; auto init flag
secinc   *=*+1          ; sector inc for seq
ftnum    *=*+1
revcnt   *=*+1          ; error recovery count
bmpnt    *=*+2          ; bit map pointer
usrjmp   *=*+2          ; user jmp table ptr
wbam     *=*+1          ; bam status (0=clean)
ctmp     *=*+2          ; temps
tmp      *=*+7
tmpjbn   *=*+1
temp     *=*+6          ; work space
t0       =temp
t1       =temp+1
t2       =temp+2
t3       =temp+3
t4       =temp+4
ip       *=*+6          ; indirect ptr variable
prgtrk   *=*+1          ; last prog accessed
track    *=*+1          ; current track
sector   *=*+1          ; current sector
tos      *=*+1          ; top of stack (def: -1-7fh)
lindx    *=*+1          ; logical index
eoiflg   *=*+1          ; temp eoi
sa       *=*+1          ; secondary address
orgsa    *=*+1          ; original sa
data     *=*+1          ; temp data byte
r0       *=*+1
r1       *=*+1
r2       *=*+1
r3       *=*+1
r4       *=*+1
r5       *=*+1
result   *=*+4
accum    *=*+5
dirbuf   *=*+2
cont     *=*+1          ; bit counter for ser
f1ptr    *=*+1          ; file stream 1 pointer
recptr   *=*+1
ssnum    *=*+1
ssind    *=*+1
relptr   *=*+1
jobnum   *=*+1          ; current job #
bufuse   *=*+1          ; buffer allocation
nodrv    *=*+1          ; no drive flag
dskver   *=*+1          ; disk version
linuse   *=*+1          ; lindx use word
dirsec   *=*+1          ; directory sector
delsec   *=*+1          ; sector of 1st avail entry
delind   *=*+1          ; index "
lbused   *=*+1          ; last buffer used
numsec   *=*+1          ; number of sectors logical
fsflag   *=*+1          ; fast serial flag
                        ; bits 7 6 5 4  3 2 1 0
                        ;              - atn pending
                        ;             --- atn mode
                        ;            ----- clkin status
                        ;           ------- fast serial lock
                        ;         ---------- slow flag
                        ;        ------------ fast serial flag
                        ;       -------------- listen flag
                        ;      ---------------- talk flag
                        ;
                        ;
lsnadr   *=*+1          ; listen address
tlkadr   *=*+1          ; talker address
ledprint *=*+1          ; led var
                        ; bits 7 6 5 4  3 2 1 0
                        ;
                        ;          -- blink power led
                        ;        ----- activity led
                        ;
tempsa   *=*+1          ; temporary sa
cmdwat   *=*+1          ; command waiting flag
switch   *=*+1          ; burst command switch
controller_stat         ; controller status
         *=*+1
bufpnt   *=*+2          ; buffer pointer
dkmode   *=*+1          ; burst status
xjobrtn  *=*+1          ;
yreg     *=*+1          ; yreg
nextjob  *=*+1          ; controller nextjob
cindex   *=*+1          ; controller job index
info     *=*+2          ; controller job information variable
dirty    *=*+1          ; track cache dirty flag
cmdtrk   *=*+1          ; controller destination track
dkandmask
         *=*+1          ; burst status mask
dkoramask
         *=*+1          ; burst status mask
cache    *=*+2          ; cache pointer
iobyte   *=*+1          ; verify / crc check
                        ; bits 7 6 5 4  3 2 1 0
                        ;        --- huge rel = 0
                        ;        ---- crc check = 1
                        ;      ------- verify = 1
                        ;
pstartrk *=*+1          ; physical starting track
pmaxtrk  *=*+1          ; "      " ending track
startrk  *=*+1          ; logical starting track
psectorsiz
         *=*+1          ; physical sector size
pnumsec  *=*+1          ; physical number of sectors (side)
pendsec  *=*+1          ; physical ending sector
pstartsec
         *=*+1          ; physical starting sector
cachetrk
         *=*+1          ; current physical track cache
tcacheside
         *=*+1          ; translated current track cache side
cacheside
         *=*+1          ; current track cache side
setval   *=*+1          ; settling time value
hdrjob   *=*+1          ; shifted nextjob - hdr pointer
gap3     *=*+1          ; format gap
fillbyte *=*+1          ; format fill byte
sieeetim *=*+1          ; sieee timing
sieeeset *=*+1          ; sieee timing
blink    *=*+1          ; error blinking
cacheoff *=*+9          ; translated track cache offset

lintab   *=*+maxsa+1    ; sa:lindx table
buftab   *=*+cbptr+4    ; buffer byte pntrs
cb=buftab+cbptr
buf0     *=*+mxchns
buf1     *=*+mxchns
lrutbl   *=*+mxchns-1   ; least recently used table
entsec   *=*+mxfils     ; sector of directory entry
entind   *=*+mxfils     ; index of directory entry
fildrv   *=*+mxfils     ; default flag, drive #
pattyp   *=*+mxfils     ; pattern,replace,closed-flags,type
filtyp   *=*+mxchns     ; channel file type

; huge relfile stuff
grpnum   *=*+1          ; group number
relsw    *=*+1          ; huge relfile switch
                        ; bits 7 6 5 4  3 2 1 0
                        ;
                        ;           -- overflow = 1
                        ;          --- huge rel file = 0

sssgrp   *=*+mxchns     ; super ss group
ssssec   *=*+mxchns     ; super ss sector
ssstrk   *=*+mxchns     ; super ss track

*=$190
svects
vidle    *=*+2          ; indirect for idle
virq     *=*+2          ; indirect for irq
vnmi     *=*+2          ; indirect for nmi
vverdir  *=*+2          ; commands
vintdrv  *=*+2
vpart    *=*+2
vmem     *=*+2
vblock   *=*+2
vuser    *=*+2
vrecord  *=*+2
vutlodr  *=*+2
vdskcpy  *=*+2
vrename  *=*+2
vscrtch  *=*+2
vnew     *=*+2
verror   *=*+2
vatnsrv  *=*+2
vtalk    *=*+2
vlisten  *=*+2
vlcc     *=*+2
vtrans_ts
         *=*+2          ; track & sector translation
vcmder2  *=*+2          ; DOS command error

hdrs2    *=*+18         ; translated job headers
sids     *=*+9          ; side select for physical
ctltimh  *=*+1          ; controller timer var
ctltiml  *=*+1          ; *
motoracc *=*+1          ; acceleration startup

                        ; controller commands
wdrestore
         *=*+1          ; $08
wdseek   *=*+1          ; $18
wdstep   *=*+1          ; $28
wdstepin
         *=*+1          ; $48
wdstepout
         *=*+1          ; $68
wdreadsector
         *=*+1          ; $88
wdwritesector
         *=*+1          ; $aa
wdreadaddress
         *=*+1          ; $c8
wdreadtrack
         *=*+1          ; $e8
wdwritetrack
         *=*+1          ; $fa
wdforceirq
         *=*+1          ; $d0

dirst    *=*+1          ; starting directory sector
savects  *=*+4          ; save area for vectors
burst_stat
         *=*+1          ; burst controller status
vernum   *=*+1          ; DOS version number
dosver   *=*+1          ; & type
hi       *=*+1          ; high partition counter
lo       *=*+1          ; low "         "
minsek   *=*+1          ; burst min. sector #
maxsek   *=*+1          ; "  "  max. "    "
bufind   *=*+9          ; buffer indirects
wpstat   *=*+1          ; write protect status
dejavu   *=*+1          ; auto boot flag
                        ; bits 7 6 5 4  3 2 1 0
                        ;
                        ;        ---- boot on intdrv
                        ;      ------- boot on reset
jhandsk  *=*+3          ; handsk jmp

*=$200
cmdbuf   *=*+cmdlen+1   ; command buffer
cmdnum   *=*+1          ; command #
dirtrk   *=*+1          ; system track
maxtrk   *=*+1          ; max track + 1
type     *=*+1          ; active file type
f1cnt    *=*+1          ; file stream 1 count
f2cnt    *=*+1          ; file stream 2 count
f2ptr    *=*+1          ; file stream 2 pointer
filcnt   *=*+1          ; counter, file entries
index    *=*+1          ; current index in buffer
typflg   *=*+1          ; match by type flag
chnrdy   *=*+mxchns     ; channel status
chndat   *=*+mxchns     ; channel data byte
lstchr   *=*+mxchns     ; channel last char ptr
nbkl
recl     *=*+mxchns
nbkh
rech     *=*+mxchns
nr       *=*+mxchns
rs       *=*+mxchns
ss       *=*+mxchns
strsiz   *=*+1
entfnd   *=*+1          ; dir-entry found flag
dirlst   *=*+1          ; dir listing flag
rec      *=*+1
trkss    *=*+1
secss    *=*+1
lstjob   *=*+bfcnt+4    ; last job
dsec     *=*+mxchns     ; sec of dir entry
dind     *=*+mxchns     ; index of dir entry
prgsec   *=*+1          ; last program sector
wlindx   *=*+1          ; write lindx
nbtemp   *=*+2          ; # blocks temp
char     *=*+1          ; char under parser
limit    *=*+1          ; ptr limit in compar
filtbl   *=*+mxfils+1   ; filename pointer
filtrk   *=*+mxfils     ; 1st link/track
filsec   *=*+mxfils     ;    /sector
patflg   *=*+1          ; pattern presence flag
image    *=*+1          ; file stream image
drvcnt   *=*+1          ; number of drv searches
drvflg   *=*+1          ; drive search flag
found    *=*+1          ; found flag in dir searches
lstbuf   *=*+1          ; =0 if last block
mode     *=*+1          ; active file mode (r,w)
jobrtn   *=*+1          ; job return flag
ndbl     *=*+1          ; # of disk blocks free
ndbh     *=*+1
erword   *=*+1          ; error word for recovery
nambuf   *=*+36         ; directory buffer
errbuf   *=*+36         ; error msg buffer


        *=$BF00
        ; vector table

        jmp  irq
        jmp  jirq
        jmp  lcc
        jmp  jlcc
        jmp  setjb
        jmp  jsetjb
        jmp  errr
        jmp  jerrr
        jmp  kill
        jmp  conhdr
        jmp  sync
        jmp  jsync
        jmp  gcrbin
        jmp  jgcrbin
        jmp  chkblk
        jmp  get4gb
        jmp  jget4gb
        jmp  jslowd
        jmp  slowd
        jmp  jslower
        jmp  clrbam
        jmp  clnbam
        jmp  parsxq
        jmp  parse
        jmp  cmdset
        jmp  cmdrst
        jmp  prcmd
        jmp  moton
        jmp  motoff
        lda  cmdtbb
        jmp  dblbuf
        jmp  open
        jmp  close
        jmp  error
        jmp  fstload
        jmp  signature
        jmp  cntint
        jmp  end
        jmp  jend
        lda  cjumpl

        *=*+30          ; more room for vector jumps
        ; info tables

        .word cmdjmp


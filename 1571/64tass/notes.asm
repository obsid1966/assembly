;
;11/6/86 David G. Siracusa
;S.O enable was not disabled when exiting the 1571 controller.
;I don't know how the drive could ever work, miracles will
;never cease.   A symptom of this bug was made apparent with relative
;files would corrupt the disk.  NOTE: This would explain any quirk, occasional
;burp, or demonic possesion you thought the drive had.
;
;11/6/86 David G. Siracusa
;BAM swap bug.  When all buffers are allocated by the application, the
;DOS frees up the BAM buffer by marking it out of memory.  When it was
;reread it would also reread BAM for side one.  If BAM for side one is
;'dirty', it would be corrupted.  This fix uses hex 1B6 for a swap flag
;this is the ultimate in kludges!!!  The BAM for side one is rebuilt on
;the reread of BAM.
;
;11/6/86 David G. Siracusa
;Save@ is fixed.  Variable nodrv is now a 16 bit addressable var, stlbuf
;routine steals the buffer locked by drive one.
;
;11/7/86 David G. Siracusa
;The applications which addressed tracks > 35 now have the density set
;properly, worktable and trackn replace worktble and trknum respectfully.
;
;12/2/86 David G. Siracusa
;Some applications fell prey to the 1541a ROM change which changed equate
;'TIM' to 20h, it is now 3ah like -05 1541 ROM.
;
;12/08/86 David G. Siracusa
;Inquire failed because I moved the GCR density tables.  I neglected
;to set the HDR var in INQUIRE.  The byte before the table was an RTS
;($60) which was the perfect density for an uninitialized HDR var.  I
;set HDR to 1 so the proper density will be set.
;
;01/13/87 David G. Siracusa
;Partial MFM Format did not work because of the above SO problem, byte
;ready's were disabled to the 65c22a.
;

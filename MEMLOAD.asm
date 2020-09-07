       DEF  LTEST
       REF  LOADER,VMBW,VSBW

* Use this program in order to load all
* of the files needed to test SCRNWRT.
* It will execute the SCRNWRT tests
* automatically.

FILES  DATA FILEN1,FILEN2,FILEN3,FILEN4
       DATA LSTEND
PDATAE
FILEN1 TEXT 'DSK2.TESTFRAM'
FILEN2 TEXT 'DSK2.MEMTST'
FILEN3 TEXT 'DSK2.MEMBUF'
FILEN4 TEXT 'DSK2.VAR'
LSTEND TEXT ' '
       EVEN
	   
       COPY "DSK2.LOADTSTS.asm"
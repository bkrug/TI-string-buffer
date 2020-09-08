       DEF  LTEST
       REF  LOADER,VMBW,VSBW

* Use this program in order to load all
* of the files needed to test ARRAY.
* It will execute the ARRAY tests
* automatically.

FILES  DATA FILEN1,FILEN2,FILEN3,FILEN4
       DATA FILEN5,LSTEND
PDATAE
FILEN1 TEXT 'DSK2.TESTFRAM.obj'
FILEN2 TEXT 'DSK2.ARRYTST.obj'
FILEN3 TEXT 'DSK2.ARRAY.obj'
FILEN4 TEXT 'DSK2.MEMBUF.obj'
FILEN5 TEXT 'DSK2.VAR.obj'
LSTEND TEXT ' '
       EVEN

       COPY "DSK2.LOADTSTS.asm"
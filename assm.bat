REM Run this script with XAS99 to assemble all files
REM and add them to work.dsk
REM
REM See https://endlos99.github.io/xdt99/

xas99.py -C -R MEMBUF.asm -L MEMBUF.lst
xas99.py -C -R MEMLOAD.asm -L MEMLOAD.lst
xas99.py -C -R MEMTST.asm -L MEMTST.lst
xas99.py -C -R TESTFRAM.asm -L TESTFRAM.lst
xas99.py -C -R VAR.asm -L VAR.lst
xas99.py -C -R ARRAY.asm -L ARRAY.lst
xas99.py -C -R ARRYLOAD.asm -L ARRYLOAD.lst
xas99.py -C -R ARRYTST.asm -L ARRYTST.lst
if exist .\work.dsk delete work.dsk
xdm99.py -X sssd work.dsk
xdm99.py work.dsk -a MEMBUF.obj -f DIS/FIX80
xdm99.py work.dsk -a MEMLOAD.obj -f DIS/FIX80
xdm99.py work.dsk -a MEMTST.obj -f DIS/FIX80
xdm99.py work.dsk -a TESTFRAM.obj -f DIS/FIX80
xdm99.py work.dsk -a VAR.obj -f DIS/FIX80
xdm99.py work.dsk -a ARRAY.obj -f DIS/FIX80
xdm99.py work.dsk -a ARRYLOAD.obj -f DIS/FIX80
xdm99.py work.dsk -a ARRYTST.obj -f DIS/FIX80
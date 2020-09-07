xas99.py -C -R MEMBUF.asm -L MEMBUF.lst
xas99.py -C -R MEMLOAD.asm -L MEMLOAD.lst
xas99.py -C -R MEMTST.asm -L MEMTST.lst
xas99.py -C -R TESTFRAM.asm -L TESTFRAM.lst
xas99.py -C -R VAR.asm -L VAR.lst
if exist .\work.dsk delete work.dsk
xdm99.py -X sssd work.dsk
xdm99.py work.dsk -a MEMBUF.obj -f DIS/FIX80
xdm99.py work.dsk -a MEMLOAD.obj -f DIS/FIX80
xdm99.py work.dsk -a MEMTST.obj -f DIS/FIX80
xdm99.py work.dsk -a TESTFRAM.obj -f DIS/FIX80
xdm99.py work.dsk -a VAR.obj -f DIS/FIX80
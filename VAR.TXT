*
* Definitions in this file
*
* Register Workspaces
       DEF  ARRYWS,STRWS
*
       DEF  BUFADR,BUFEND

* Areas of memory that absolutely have
* to be in RAM and could never be part
* of a cartridge ROM should go here.

*
* holds address of buffer
BUFADR BSS  >2
* holds first address after the buffer
BUFEND BSS  >2

*
* Areas for workspace registers
*
* The >20 bytes would have been used
* as the workspace for all STRBUF
* routines.
ARRYWS BSS  >10
STRWS  BSS  >20
       END
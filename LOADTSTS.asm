PABBUF EQU  >1000
PAB    EQU  >F80
STATUS EQU  >837C
PNTR   EQU  >8356
* Byte 0 = Open
* Byte 1 = Status/Display/Fixed
* Byte 4 = max record length 80
* Byte 5 = actual length to write
* Byte 6-7 are not relevant
* Byte 8 = status o file
* Byte 9 = file name length
PDATA  DATA >0004,PABBUF,>5000,>0000,>0000

LTEST  
* Store Screen position in R7
       CLR  R7
* Store file information in R3,R4, and R5
       LI   R3,PAB+8
       LI   R4,FILES
* Write PAB header
LTEST1 LI   R0,PAB
       LI   R1,PDATA
       LI   R2,10
       BLWP @VMBW
* Write filename to screen
       MOV  R7,R0
       MOV  *R4+,R1
	   MOV  *R4,R2
	   S    R1,R2
       BLWP @VMBW
	   AI   R7,32
* Write file name to PAB
       LI   R0,PAB+10
	   BLWP @VMBW
* Write file length to PAB
       LI   R0,PAB+9
       MOV  R2,R1
       SWPB R1
       BLWP @VSBW
*
       LI   R6,PAB+9
       MOV  R6,@PNTR
* Load the assembled code
       BLWP @LOADER
* If the Eqaul bit is set, report error
       JEQ  RPTERR
* See if we should run another file
LTEST2 CI   R4,PDATAE-2
       JL   LTEST1
* Enter the test program
       B    @RUNTST
*
*
ERRMSG TEXT 'LOADER routine error: '
ERRCD  BSS  1
ERRCD1 EVEN
ERRFL  TEXT 'File: '
ERRFL1
*
RPTERR
* Add error code to message
       AI   R0,>3000
       MOVB R0,@ERRCD
* Display error message
       MOV  R7,R0
       LI   R1,ERRMSG
       LI   R2,ERRCD1-ERRMSG
       BLWP @VMBW
* Display particular file to fail
       AI   R0,>20
       LI   R1,ERRFL
       LI   R2,ERRFL1-ERRFL
       BLWP @VMBW
       A    R2,R0
       DECT R4
       MOV  *R4+,R1
	   MOV  *R4,R2
	   S    R1,R2
       BLWP @VMBW
JMP    LIMI 2
       LIMI 0
       JMP  JMP

       TEXT 'LOOKHERE'
*
* First loaded program will be found here:
RUNTST
       END
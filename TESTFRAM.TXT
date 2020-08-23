* Program entry point
       DEF  RUNTST
* Creates HEX value as text string
       DEF  MAKETX
* Prints text at screen bottom
	   DEF  PRINTL
*******
* Assert block contents are equal
	   DEF  ABLCK
* Assert Ones Corresponding, Zeros Corresponding
	   DEF  AOC,AZC
* Assert Words Equal, Words Not Equal
       DEF  AEQ,ANEQ
* Assert Word Logical Low
       DEF  AL

*******
* List of test routines
* First word: Number of tests
* Next word: address of first test
* Next 6 bytes: ASCII name of test
       REF  TSTLST
* Name of results output file
	   REF  RSLTFL
*
       REF  VMBW,VMBR,VSBW,DSRLNK

RUNTST B    @RUNT

PASSED DATA >0000
FAILED DATA >0000
WORKSP BSS  >20
TSTWS  BSS  >20
STACK  BSS  >100

* Number of tests to run
TSTCNT DATA 0
* Current address within test list
TSTADR DATA 0

* Run all tests
* ----------------------
RUNT   LWPI WORKSP
       LI   R12,STACK
* Open test result file
       BL   @OPENF
* Display test start message
       LI   R0,STARTM
       LI   R1,ENDM-STARTM
       BL   @SCRLPT
* Initialize variables for tracking
* test run progress
       LI   R0,TSTLST
       MOV  *R0+,@TSTCNT
       MOV  R0,@TSTADR
* Write name of the next test
TSTLP  MOV  @TSTADR,R0
       INCT R0
       LI   R1,6
       BL   @SCRLPT
* Clear and load test workspace
       LI   R0,TSTWS
TSTL05 CLR  *R0+
       CI   R0,TSTWS+>20
       JL   TSTL05
       LWPI TSTWS
* Branch and link to the next test
       MOV  @TSTADR,R11
       MOV  *R11,R11
       BL   *R11
* Restore local workspace
       LWPI WORKSP
* Print pass message
TSTL10 LI   R0,23*32+6
       LI   R1,PASSM
       LI   R2,PASSME-PASSM
       BLWP @VMBW
TSTL20
* Update test progress variables
       LI   R1,8
       A    R1,@TSTADR
       DEC  @TSTCNT
* Make next iteration in loop
       JH   TSTLP
* Display test completion message
       LI   R0,ENDM
       LI   R1,ENDME-ENDM
       BL   @SCRLPT
* Close test result file
       BL   @CLOSEF
*
       LIMI 2
LOOP   JMP  LOOP

STARTM TEXT 'Testing'
ENDM   TEXT 'Done'
ENDME
PASSM  TEXT ' passed.'
PASSME
FAILM  TEXT ' failed.'
FAILME
       EVEN

       
PASST  INC  @PASSED
       RT
 
FAILT  INC  @FAILED
       RT
 
* Make Hexadecimal Text
* ----------------------
* R0: Word to convert
* R1: Address of output text (4 bytes)
MAKETX DATA WORKSP,MAKEP
MAKEP  LI   R12,STACK
       MOV  *R13,R0
       MOV  @2(R13),R1
       BL   @MAKEHX
       RTWP
MAKEHX MOV  R11,*R12+
       BL   @MAKEP1
       SWPB R0
       BL   @MAKEP1
       SWPB R0
* return
       DECT R12
       MOV  *R12,R11
       RT
 
MAKEP1 MOV  R11,*R12+
       MOV  R4,*R12+
* High Nibble
       MOVB R0,R4
       SRL  R4,4
       BL   @CONVB
       MOVB R4,*R1
       INC  R1
* Low Nibble
       MOVB R0,R4
       SLA  R4,4
       SRL  R4,4
       BL   @CONVB
       MOVB R4,*R1
       INC  R1
* Return
       DECT R12
       MOV  *R12,R4
       DECT R12
       MOV  *R12,R11
       RT
* Convert Byte to ASCII code
CONVB  CI   R4,>0A00
       JHE  CNVB2
       AI   R4,>3000
       RT
CNVB2  AI   R4,>3700
       RT
 
* Scroll screen upward and place text
* at the bottom of the screen. Can be
* multiple lines.
* Also write to file.
* -----------------------------------
* R0: Address of text.
* R1: Length of text.
PRINTL DATA WORKSP,PRINTP
LINLNG DATA 32
SCRN   BSS  >300
CLRTXT TEXT '                                '
       EVEN
PRINTP LI   R12,STACK
       MOV  *R13,R0
       MOV  @2(R13),R1
       BL   @WRITEF
       BL   @SCRLP
       RTWP

SCRLPT MOV  R11,*R12+
* If text length > 23*32, limit it.
       CI   R1,23*32
	   JLE  SCROL0
	   LI   R1,23*32
*
SCROL0 BL   @WRITEF
       BL   @SCRLP
       DECT R12
       MOV  *R12,R11
       RT
       
SCRLP  MOV  R11,*R12+
       MOV  R8,*R12+
       MOV  R9,*R12+
       MOV  R2,*R12+
       MOV  R3,*R12+
 
       MOV  R0,R8
       MOV  R1,R9
* Find ceiling of text length / 32
       CLR  R0
       MOV  R9,R1
       DIV  @LINLNG,R0
       MOV  R1,R1
       JEQ  SCROLL
       INC  R0
* R0 contains number of lines to print.
* If R0 = 0, then return to caller.
SCROLL MOV  R0,R0
       JNE  SCROL1
       B    @SCRLRT
* Scroll text by number of lines in R0.
SCROL1 SLA  R0,5
       LI   R1,SCRN
       LI   R2,>300
       S    R0,R2
       BLWP @VMBR
       CLR  R0
       BLWP @VMBW
* Clear the last line of text.
       MOV  R2,R3
       LI   R0,>2E0
       LI   R1,CLRTXT
       LI   R2,>20
       BLWP @VMBW
*Write new text.
*R3 contains length of text scrolled up.
*   Identical to text start position.
       MOV  R3,R0
       MOV  R8,R1
       MOV  R9,R2
       BLWP @VMBW
       MOV  R8,R0
       MOV  R9,R1
* return
SCRLRT DECT R12
       MOV  *R12,R3
       DECT R12
       MOV  *R12,R2
       DECT R12
       MOV  *R12,R9
       DECT R12
       MOV  *R12,R8
       DECT R12
       MOV  *R12,R11
       RT
 
* Open file
* ---------
* RSLTFL: the location of the filename
* Must write to RSLTFL and call OPENF
* before calling WRITEF
PABBUF EQU  >1000
PAB    EQU  >F80
STATUS EQU  >837C
PNTR   EQU  >8356
* Byte 0 = Open
* Byte 1 = Status/Display/Variable
* Byte 4 = max record length 80
* Byte 5 = actual length to write
* Byte 6-7 are not relevant
* Byte 8 = status o file
* Byte 9 = file name length
PDATA  DATA >0012,PABBUF,>5000,>0000,>000F
       EVEN
RCDL   EQU  PDATA+5
WRITE  BYTE >03
CLOSE  BYTE >01
OPENF
* Copy PAB into VDP RAM
       LI   R0,PAB
       LI   R1,PDATA
       LI   R2,9
       BLWP @VMBW
* Copy filename to VDP RAM
       LI   R0,PAB+9
       LI   R1,RSLTFL
       MOV  *R1,R2
       INC  R2
       BLWP @VMBW
* Open file
       LI   R6,PAB+9
       MOV  R6,@PNTR
       BLWP @DSRLNK
       DATA 8
 
       B    @ERRORF

* Write one line of text to file or
* printer.
* ----------------------
* R0: Address of text.
* R1: Length of text.
WRTMSG TEXT 'Writing stuff to disk.'
WRTM0  EVEN
WRITEF
       MOV  R0,*R12+
       MOV  R1,*R12+
       MOV  R2,*R12+
       MOV  R6,*R12+
       MOV  R11,*R12+
* Write line to VDP RAM
       MOV  R1,R2
       MOV  R0,R1
       LI   R0,PABBUF
       BLWP @VMBW
* Update record length
       SWPB R2
       MOVB R2,@PDATA+5
* Change I/O op-code to write.
       MOVB @WRITE,@PDATA
* Rewrite data
       LI   R0,PAB
       LI   R1,PDATA
       LI   R2,9
       BLWP @VMBW
* Do write operation
       LI   R6,PAB+9
       MOV  R6,@PNTR
       BLWP @DSRLNK
       DATA 8
*
       BL   @ERRORF
 
       DECT R12
       MOV  *R12,R11
       DECT R12
       MOV  *R12,R6
       DECT R12
       MOV  *R12,R2
       DECT R12
       MOV  *R12,R1
       DECT R12
       MOV  *R12,R0
       RT
 
* Close file
* ----------
CLOSEF
* Change I/O op-code to close
       LI   R0,PAB
       MOVB @CLOSE,R1
       BLWP @VSBW
* Close file
       LI   R6,PAB+9
       MOV  R6,@PNTR
       BLWP @DSRLNK
       DATA 8
*
       B    @ERRORF
 
* Report Error
* ------------
ERRGEN TEXT 'Some error occurred.'
ERRMSG TEXT 'File Error Code '
ERRCD  BSS  >1
ERR0
ZEROCR BYTE '0'
       EVEN
ERRORF
       MOV  R0,*R12+
       MOV  R1,*R12+
       MOV  R11,*R12+
       MOV  R0,R0
       JNE  ERR2
       LI   R0,ERRGEN
       LI   R1,ERRMSG-ERRGEN
       BL   @SCRLP
* Read Error Code
ERR2   MOVB @PDATA+1,R0
       SRL  R0,5
       AI   R0,>3000
       MOVB R0,@ERRCD
* If error code is not '0' or
* bit 2 of status byte is on,
* report the error.
       CB   R0,@ZEROCR
       JNE  ERR1
       MOVB @STATUS,R0
       ANDI R0,>2000
       JNE  ERR1
       JMP  ERRRT
* Display Error Message
ERR1   LI   R0,ERRMSG
       LI   R1,ERR0-ERRMSG
       BL   @SCRLP
* Return
ERRRT
       DECT R12
       MOV  *R12,R11
       DECT R12
       MOV  *R12,R1
       DECT R12
       MOV  *R12,R0
       RT

********************************

* Assert Blocks Are Identical
* ----------------------
* R0: Address of Expected block
* R1: Address of Actual block
* R2: Length of expected block
* R2: Address of fail message
* R3: Length of fail message
*
* Return true if contents of two blocks
* are equal. Displays first point where
* they are different.
ABLCK  DATA WORKSP,ABLCKP
ABLMES TEXT 'Expected '
ABLM1  BSS  >4
       TEXT ' but actual '
ABLM2  BSS  >4
       TEXT ' at byte offset '
ABLM3  BSS  >4
       TEXT '.'
ABLME  EVEN
ABLCKP
* Copy Parameters
       BL   @COPYP
* R5 = Current Byte
       CLR  R5
* Compare each 16-bit word
AB1    C    *R0+,*R1+
       JNE  ABFL
	   INCT R5
	   C    R5,R2
	   JL   AB1
* Report success
       RTWP
* Report Failure
* Backtrack to unmatching bytes.
ABFL   DECT R0
	   DECT R1
* 
	   MOV  R1,R6
* Convert values to Hexadecimal Text.
* R0 already contains address of 
* the expected value
       MOV  *R0,R0
	   LI   R1,ABLM1
       BL   @MAKEHX
* the actual value is copied from R6
       MOV  *R6,R0
       LI   R1,ABLM2
       BL   @MAKEHX
* 
       MOV  R5,R0
	   LI   R1,ABLM3
	   BL   @MAKEHX
* Display standard failure message
       LI   R0,ABLMES
       LI   R1,ABLME-ABLMES
       BL   @SCRLPT
* Display user-defined failure message
       MOV  @6(13),R0
       MOV  @8(13),R1
	   CI   R1,>200
	   JL   AB2
	   LI   R1,>200
AB2    BL   @SCRLPT
* Don't return to the test being run. No
* need to run extra assertions
* in the same test.
       B    @TSTL20

* Assert Ones Corresponding
* ----------------------
* R0: Bits expected to be set
* R1: Actual value
* R2: Address of fail message
* R3: Length of fail message
* Assert Words Are Equal
* ----------------------
* Return true if ones in R2
* are also set in R3. Displays 
* their contents if not true.
AOC    DATA WORKSP,AOCP
AOCMES TEXT 'A: '
AOCM1  BSS  >4
       TEXT ' B: '
AOCM2  BSS  >4
       TEXT ' Ones in A should have '
	   TEXT 'corresponding ones in B.'
AOCME  EVEN
AOCP
* Copy Parameters
       BL   @COPYP
* Output Test Name
       COC  R0,R1
       JEQ  AOCS
* Report failure
       BL   @RF
       DATA AOCM1,AOCM2
       DATA AOCMES,AOCME-AOCMES
* Report success
AOCS   RTWP

* Assert Zeros Corresponding
* ----------------------
* R0: Bits expected to be reset
* R1: Actual value
* R2: Address of fail message
* R3: Length of fail message
* Assert Words Are Equal
* ----------------------
* Return true if ones in R2 have 
* corresponding zeros in R3.
* Displays ther contents otherwise.
AZC    DATA WORKSP,AZCP
AZCMES TEXT 'A: '
AZCM1  BSS  >4
       TEXT ' B: '
AZCM2  BSS  >4
       TEXT ' Ones in A should have '
	   TEXT 'corresponding zeros in B.'
AZCME  EVEN
AZCP
* Copy Parameters
       BL   @COPYP
* Output Test Name
       CZC  R0,R1
       JEQ  AZCS
* Report failure
       BL   @RF
       DATA AZCM1,AZCM2
       DATA AZCMES,AZCME-AZCMES
* Report success
AZCS   RTWP

* Assert Words are Equal
* ----------------------
* R0: Expected value
* R1: Actual value
* R2: Address of fail message
* R3: Length of fail message
* Assert Words Are Equal
* ----------------------
* Return true if contents of R2 and R3
* are equal. Displays their contents if
* not equal.
* See DSKx.TESTFRAME for paramter 
* signature.
AEQ    DATA WORKSP,AEQP
AEQMES TEXT 'Expected '
AEQM1  BSS  >4
       TEXT ' but actual '
AEQM2  BSS  >4
       TEXT '.'
AEQME  EVEN
AEQP
* Copy Parameters
       BL   @COPYP
* Output Test Name
       C    R0,R1
       JEQ  AEQS
* Report failure
       BL   @RF
       DATA AEQM1,AEQM2
       DATA AEQMES,AEQME-AEQMES
* Report success
AEQS   RTWP

* Assert Words Are Not Equal
* --------------------------
* Return true if contents of R2 and R3
* are not equal. Displays their 
* contents if equal.
ANEQ   DATA WORKSP,ANEQP
ANEQM  TEXT 'Expected unequal values, but '
       TEXT 'both values are '
ANEQM1 BSS  >4
       TEXT '.'
ANEQME EVEN
ANEQP
* Copy Parameters
       BL   @COPYP
* Output Test Name
       C    R0,R1
       JNE  ANEQS
* Report failure
       BL   @RF
       DATA ANEQM1,ANEQM1
       DATA ANEQM,ANEQME-ANEQM
* Report success
ANEQS  RTWP

* Assert Words Logical Low
* --------------------------
* Passes assert if contents of 'actual'
* is unsigned less than 'expected'.
AL     DATA WORKSP,ALP
ALM    TEXT 'Expected '
ALM1   BSS   >4
       TEXT ' to be unsigned less than '
ALM2   BSS  >4
       TEXT '.'
ALME   EVEN
ALP
* Copy Parameters
       BL   @COPYP
* Output Test Name
       C    R0,R1
       JL   ALS
* Report failure
       BL   @RF
       DATA ALM1,ALM2
       DATA ALM,ALME-ALM
* Report success
ALS    RTWP

* Routines shared by assert
* routines.
* ----------------------
* Copy Parameters to Registers
COPYP  LI   R12,STACK
       MOV  *R13+,R0
       MOV  *R13+,R1
       MOV  *R13+,R2
       MOV  *R13+,R3
       AI   R13,-8
       RT

* Report Failure
* R0: Expected Value
* R1: Actual Value
* R2: User-defined failure message
* R3: Message length
* Memory Addresses after BL command
* +02: Dest address of expected text
* +04: Dest address of actual text
* +06: Address of standard failure message
* +08: length of failure message
RF     
       MOV  R11,R10
       MOV  R1,R4
* Convert values to Hexadecimal Text.
* R0 already contains the expected value
       MOV  *R10+,R1
       BL   @MAKEHX
* the actual value is copied from R4
       MOV  R4,R0
       MOV  *R10+,R1
       BL   @MAKEHX
* Display standard failure message
       MOV  *R10+,R0
       MOV  *R10+,R1
       BL   @SCRLPT
* Display user-defined failure message
       MOV  R2,R0
       MOV  R3,R1
       BL   @SCRLPT
* Don't return to the test being run. No
* need to run extra assertions
* in the same test.
       B    @TSTL20

       END       
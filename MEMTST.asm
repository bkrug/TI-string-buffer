       DEF  TSTLST,RSLTFL
       REF  AEQ,ABLCK
       REF  ASEQ,ASNEQ
*
       REF  BUFINT,BUFCPY,BUFALC,BUFREE
       REF  BUFSRK,BUFGRW
*
       REF  BUFADR,BUFEND

TSTLST DATA TSTEND-TSTLST-2/8
* Copy memory block. Non-overlapping.
       DATA TCPY1
       TEXT 'TCPY1 '
* Copy memory block. Length is zero.
       DATA TCPY2
       TEXT 'TCPY2 '
* Copy memory block. Overlapping.
       DATA TCPY3
       TEXT 'TCPY3 '
* Copy memory block. Overlapping.
       DATA TCPY4
       TEXT 'TCPY4 '
* Initialize a >1000 bytes buffer.
       DATA TINT1
       TEXT 'TINT1 '
* Fail to initialize with >8000 bytes.
       DATA TINT2
       TEXT 'TINT2 '
* Fail to initialize with >2 bytes.
       DATA TINT3
       TEXT 'TINT3 '
* Fail to initialize with >13 bytes.
       DATA TINT4
       TEXT 'TINT4 '
* Allocate space in empty buffer.
       DATA TALC1
       TEXT 'TALC1 '
* Allocate space following another
*    allocation.
       DATA TALC2
       TEXT 'TALC2 '
* Allocate space between two allocated
*    spaces.
       DATA TALC3
       TEXT 'TALC3 '
* Allocate space between two allocated
*    spaces, leave some unallocated
*    remaining.
       DATA TALC4
       TEXT 'TALC4 '
* Allocate space.
*    Earlier empty space too small.
       DATA TALC5
       TEXT 'TALC5 '
* Allocate last remaining space in buffer.
       DATA TALC6
       TEXT 'TALC6 '
* No unallocated space is large enough.
       DATA TALC7
       TEXT 'TALC7 '
* Allocate odd number of bytes
       DATA TALC8
       TEXT 'TALC8 '
* Deallocate only allocated space
       DATA TFRE1
       TEXT 'TFRE1 '
* Deallocate last of several allocated
*    spaces
       DATA TFRE2
       TEXT 'TFRE2 '
* Deallocate space and merge multiple
*    free space
       DATA TFRE3
       TEXT 'TFRE3 '
* Deallocate space between two free
*    spaces
       DATA TFRE4
       TEXT 'TFRE4 '
* Deallocate space between two allocated
*    spaces
       DATA TFRE5
       TEXT 'TFRE5 '
* Deallocate space after allocated but
*    before deallocated space
       DATA TFRE6
       TEXT 'TFRE6 '
* Deallocate space at end of buffer
       DATA TFRE7
       TEXT 'TFRE7 '
* Don't shrink. Small enough.
       DATA TSRK1
       TEXT 'TSRK1 '
* Don't shrink. Exactlly twice needed.
       DATA TSRK2
       TEXT 'TSRK2 '
* Shrink without merging following block.
       DATA TSRK3
       TEXT 'TSRK3 '
* Shrink and merge following free block.
       DATA TSRK4
       TEXT 'TSRK4 '
* Don't grow a block. More space is left.
       DATA TGRW1
       TEXT 'TGRW1 '
* Don't grow a block. It is just right.
       DATA TGRW2
       TEXT 'TGRW2 '
* Grow a block, without moving it.
       DATA TGRW3
       TEXT 'TGRW3 '
* Grow a block, without moving it,
*    merge some free spaces.
       DATA TGRW4
       TEXT 'TGRW4 '
* Grow and move a block.
* Original block was followed by an
* allocated block.
       DATA TGRW5
       TEXT 'TGRW5 '
* Grow and move a block.
* Original block was followed by an
* unallocated block.
       DATA TGRW6
       TEXT 'TGRW6 '
* Grow and move a block, and merge some
*    free spaces.
       DATA TGRW7
       TEXT 'TGRW7 '
* Fail to grow a block, do not
*    deallocate original location
       DATA TGRW8
       TEXT 'TGRW8 '
TSTEND
RSLTFL BYTE RSLTFE-RSLTFL-1
       TEXT 'DSK2.TESTRESULT.TXT'
RSLTFE
       EVEN
*
SPACE  BSS  >400

*
* Copy memory block. Non-overlapping.
TCPY1
* Act
       LI   R0,TCPY1A
       LI   R1,TCPY1C
       LI   R2,TCPY1B-TCPY1A
       BLWP @BUFCPY
* Assert no error was detected
       BLWP @ASNEQ
       TEXT 'Expected no error to be detected'
       BYTE 0
*       S    R5,R5
*       BLWP @ASEQ
*       LI   R5,4
*       BLWP @ASEQ
*       S    R5,R5
*       BLWP @ASNEQ
*       LI   R5,4
*       BLWP @ASNEQ
* Assert the data was copied correctly.
       LI   R0,TCPY1A
       LI   R1,TCPY1C
       LI   R2,TCPY1B-TCPY1A
       BLWP @ABLCK
       TEXT 'Copied string should match original.'
       BYTE 0
       EVEN
*
       RT
TCPY1A TEXT 'Some data to copy.'
TCPY1B EVEN
       BSS  >10
TCPY1C BSS  >20

*
* Copy memory block. Length is zero.
TCPY2
* Act
       LI   R0,TCPY2A
       LI   R1,TCPY2C
       LI   R2,0
       BLWP @BUFCPY
* No real assertion.
* If this test fails, it will probably
* mean an infinate loop.
       RT
TCPY2A BSS  >2
TCPY2C BSS  >2

*
* Copy memory block. Overlapping.
* Source block is earlier than
* destination block.
TCPY3
* Act
       LI   R0,TCPY3B
       LI   R1,TCPY3D
       LI   R2,TCPY3C-TCPY3B
       BLWP @BUFCPY
* Assert
       LI   R0,TCPY3A
       LI   R1,TCPY3D
       LI   R2,TCPY3B-TCPY3A
       BLWP @ABLCK
       TEXT 'Copied string should match original.'
       BYTE 0
       EVEN
*
       RT
* Expected text
TCPY3A TEXT 'This is some data that may be copied._'
       EVEN
* Source to copy from
TCPY3B TEXT 'This is some data that may be copied._'
       EVEN
TCPY3C BSS  >20
TCPY3D EQU  TCPY3B+>8

*
* Copy memory block. Overlapping.
* Source block is later than
* destination block.
TCPY4
* Act
       LI   R0,TCPY4C
       LI   R1,TCPY4E
       LI   R2,TCPY4D-TCPY4C
       BLWP @BUFCPY
* Assert
       LI   R0,TCPY4A
       LI   R1,TCPY4E
       LI   R2,TCPY4B-TCPY4A
       BLWP @ABLCK
       TEXT 'Copied string should match original.'
       BYTE 0
       EVEN
*
       RT
* Expected text
TCPY4A TEXT 'This is some data that may be copied._'
TCPY4B EVEN
       BSS  >20
* Source to copy from
TCPY4C TEXT 'This is some data that may be copied._'
TCPY4D
TCPY4E EQU  TCPY4C->8
       EVEN

*
* Initialize a >1000 bytes buffer.
* Expect the first word to contain the
* header for one empty chunk covering
* the entire buffer.
TINT1
* Act
       LI   R0,SPACE
       LI   R1,>200
       BLWP @BUFINT
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error to occur initializing buffer'
       BYTE 0
* Assert R0 = zero (no error)
       MOV  R0,R1
       CLR  R0
       BLWP @AEQ
       TEXT 'There should be no allocation error.'
       BYTE 0
       EVEN
* Assert R0 = zero (no error)
       LI   R0,>200
       MOV  @SPACE,R1
       BLWP @AEQ
       TEXT 'The first word should contain >0200.'
       BYTE 0
       EVEN
*
       RT
 
*
* Fail to initialize with >8000 bytes.
* Expect the allocation to fail because
* >8000 is too big.
TINT2
* Act
       LI   R0,SPACE
       LI   R1,>8000
       BLWP @BUFINT
* Assert some error has been detected
       BLWP @ASEQ
       TEXT 'Expected an error initializing buffer'
       BYTE 0
* Assert R0 = >FFFF (error)
       MOV  R0,R1
       SETO R0
       BLWP @AEQ
       TEXT 'Allocation should fail. '
       TEXT '>8000 is too big.'
       BYTE 0
       EVEN
*
       RT

*
* Fail to initialize with >2 bytes.
* Expect the allocation to fail because
* >0002 is too small.
TINT3
* Act
       LI   R0,SPACE
       LI   R1,>2
       BLWP @BUFINT
* Assert some error has been detected
       BLWP @ASEQ
       TEXT 'Expected an error initializing buffer'
       BYTE 0
* Assert R0 = >FFFF (error)
       MOV  R0,R1
       SETO R0
       BLWP @AEQ
       TEXT 'Allocation should fail. '
       TEXT '>03 is too small.'
       BYTE 0
       EVEN
*
       RT

*
* Fail to initialize with >13 bytes.
* Expect the allocation to fail because
* space must be even.
TINT4
* Act
       LI   R0,SPACE
       LI   R1,>13
       BLWP @BUFINT
* Assert some error has been detected
       BLWP @ASEQ
       TEXT 'Expected an error initializing buffer'
       BYTE 0
* Assert R0 = >FFFF (error)
       MOV  R0,R1
       SETO R0
       BLWP @AEQ
       TEXT 'Allocation should fail. '
       TEXT 'Allocated space must be even.'
       BYTE 0
       EVEN
*
       RT

*
* Allocate space in empty buffer.
TALC1
* Arrange
       LI   R0,TALC1A
       MOV  R0,@BUFADR
       LI   R0,TALC1B
       MOV  R0,@BUFEND
* Act
       LI   R0,>E
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TALC1A+>02
       BLWP @AEQ
       TEXT 'R0 should have contained address '
       TEXT 'of newly allocated space. '
       TEXT 'It should be at beginning of buffer.'
       BYTE 0
       EVEN
* >10 bytes should be allocated
* (>E bytes + header)
       LI   R0,>8010
       MOV  @TALC1A,R1
       BLWP @AEQ
       TEXT 'Space should now be allocated.'
       BYTE 0
       EVEN
* >30 bytes remain unallocated
       LI   R0,>0030
       MOV  @TALC1A+>10,R1
       BLWP @AEQ
       TEXT 'Space should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC1A
* Header
       DATA >0040
* Allocated space
       BSS  >3E
TALC1B

* Allocate space following another
*    allocation.
TALC2
* Arrange
       LI   R0,TALC2A
       MOV  R0,@BUFADR
       LI   R0,TALC2B
       MOV  R0,@BUFEND
* Act
       LI   R0,>C
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TALC2A+>22
       BLWP @AEQ
       TEXT 'R0 should have contained address '
       TEXT 'of allocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TALC2A,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
* >E bytes should be allocated
* (>C bytes + header)
       LI   R0,>800E
       MOV  @TALC2A+>20,R1
       BLWP @AEQ
       TEXT 'Space should now be allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8018
       MOV  @TALC2A+>8,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0012
       MOV  @TALC2A+>2E,R1
       BLWP @AEQ
       TEXT 'Space should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC2A DATA >8008
       BSS  >06
       DATA >8018
       BSS  >16
       DATA >0020
       BSS  >1E
TALC2B

* Allocate space between two allocated
*    spaces.
TALC3
* Arrange
       LI   R0,TALC3A
       MOV  R0,@BUFADR
       LI   R0,TALC3B
       MOV  R0,@BUFEND
* Act
       LI   R0,>16
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TALC3A+>0A
       BLWP @AEQ
       TEXT 'R0 should have contained address '
       TEXT 'of allocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TALC3A,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
* >18 bytes should be allocated
* (>16 bytes + header)
       LI   R0,>8018
       MOV  @TALC3A+>08,R1
       BLWP @AEQ
       TEXT 'Space should now be allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TALC3A+>20,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
* >10 bytes remain unallocated
       LI   R0,>0010
       MOV  @TALC3A+>30,R1
       BLWP @AEQ
       TEXT 'Space should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC3A DATA >8008
       BSS  >06
       DATA >0018
       BSS  >16
       DATA >8010
       BSS  >0E
       DATA >0010
       BSS  >0E
TALC3B

* Allocate space between two allocated
*    spaces, leave some unallocated
*    remaining.
TALC4
* Arrange
       LI   R0,TALC4A
       MOV  R0,@BUFADR
       LI   R0,TALC4B
       MOV  R0,@BUFEND
* Act
       LI   R0,>14
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TALC4A+>0A
       BLWP @AEQ
       TEXT 'R0 should have contained address '
       TEXT 'of allocated space.'
       BYTE 0
       EVEN
* >08 bytes remain allocated
       LI   R0,>8008
       MOV  @TALC4A,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
* >16 bytes should be allocated
* (>14 bytes + header)
       LI   R0,>8016
       MOV  @TALC4A+>08,R1
       BLWP @AEQ
       TEXT 'Space should now be allocated.'
       BYTE 0
       EVEN
* >02 bytes remain unallocated
       LI   R0,>0002
       MOV  @TALC4A+>1E,R1
       BLWP @AEQ
       TEXT 'Space should remain unallocated.'
       BYTE 0
       EVEN
* >10 bytes remain allocated
       LI   R0,>8010
       MOV  @TALC4A+>20,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
* >10 bytes remain unallocated
       LI   R0,>0010
       MOV  @TALC4A+>30,R1
       BLWP @AEQ
       TEXT 'Space should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC4A DATA >8008
       BSS  >06
       DATA >0018
       BSS  >16
       DATA >8010
       BSS  >0E
       DATA >0010
       BSS  >0E
TALC4B

*
* Allocate space.
*    Earlier empty space too small.
TALC5
* Arrange
       LI   R0,TALC5A
       MOV  R0,@BUFADR
       LI   R0,TALC5Z
       MOV  R0,@BUFEND
* Act
       LI   R0,>E
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TALC5E+2
       BLWP @AEQ
       TEXT 'R0 should have contained address '
       TEXT 'of allocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TALC5A,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0004
       MOV  @TALC5B,R1
       BLWP @AEQ
       TEXT 'Space should remain unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8004
       MOV  @TALC5C,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8020
       MOV  @TALC5D,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TALC5E,R1
       BLWP @AEQ
       TEXT 'Space should now be allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0008+>06
       MOV  @TALC5E+>10,R1
       BLWP @AEQ
       TEXT 'Remaining unallocated space merged '
       TEXT 'with following unallocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TALC5G,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC5A DATA >8008
       BSS  >06
TALC5B DATA >0004
       BSS  >2
TALC5C DATA >8004
       BSS  >2
TALC5D DATA >8020
       BSS  >1E
TALC5E DATA >0018
       BSS  >16
TALC5F DATA >0006
       BSS  >4
TALC5G DATA >8010
       BSS  >E
TALC5Z

*
* Allocate last remaining space in buffer.
TALC6
* Arrange
       LI   R0,TALC6A
       MOV  R0,@BUFADR
       LI   R0,TALC6B
       MOV  R0,@BUFEND
* Act
       LI   R0,>1C
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TALC6A+>18
       BLWP @AEQ
       TEXT 'R0 should have contained address '
       TEXT 'of allocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>8016
       MOV  @TALC6A,R1
       BLWP @AEQ
       TEXT 'Space should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>801E
       MOV  @TALC6A+>16,R1
       BLWP @AEQ
       TEXT 'The last bit of space should now be allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC6A DATA >8016
       BSS  >14
       DATA >001E
       BSS  >1C
TALC6B

*
* No unallocated space is large enough.
TALC7
* Arrange
       LI   R0,TALC7A
       MOV  R0,@BUFADR
       LI   R0,TALC7B
       MOV  R0,@BUFEND
* Act
       LI   R0,>12
       BLWP @BUFALC
* Assert an error has been detected
       BLWP @ASEQ
       TEXT 'Expected an error due to lack of memory'
       BYTE 0
* Assert
       MOV  R0,R1
       SETO R0
       BLWP @AEQ
       TEXT 'An error should be reported. '
       TEXT 'There is not enough space.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC7A DATA >8016
       BSS  >14
       DATA >0010
       BSS  >0E
       DATA >801C
       BSS  >1A
TALC7B

* Allocate an odd number of bytes
TALC8
* Arrange
       LI   R0,TALC8A
       MOV  R0,@BUFADR
       LI   R0,TALC8B
       MOV  R0,@BUFEND
* Act
       LI   R0,>5
       BLWP @BUFALC
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R1,TALC8C+2
       BLWP @AEQ
       TEXT 'Address of allocation should '
       TEXT 'be in R0.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TALC8C,R1
       BLWP @AEQ
       TEXT 'Allocated space should have been '
       TEXT 'rounded up to an even number, '
       TEXT 'plus 2 more bytes for header.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TALC8A DATA >8016
       BSS  >14
TALC8C DATA >0010
       BSS  >0E
       DATA >801C
       BSS  >1A
TALC8B

*
* Only one block of space is allocated.
* Deallocated it.
TFRE1
* Arrange
       LI   R0,TFRE1A
       MOV  R0,@BUFADR
       LI   R0,TFRE1B
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE1A+>02
       BLWP @BUFREE
*
       LI   R0,>0026
       MOV  @TFRE1A,R1
       BLWP @AEQ
       TEXT 'Space should be deallocated '
       TEXT 'and merged with following free space.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE1A DATA >8016
       BSS  >14
       DATA >0010
       BSS  >0E
TFRE1B

*
* Deallocate last of several allocated
*    spaces.
TFRE2
* Arrange
       LI   R0,TFRE2A
       MOV  R0,@BUFADR
       LI   R0,TFRE2B
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE2A+>32
       BLWP @BUFREE
*
       LI   R0,>8010
       MOV  @TFRE2A,R1
       BLWP @AEQ
       TEXT 'Space should still be allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8020
       MOV  @TFRE2A+>10,R1
       BLWP @AEQ
       TEXT 'Space should still be allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0028
       MOV  @TFRE2A+>30,R1
       BLWP @AEQ
       TEXT 'Space should no longer be allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE2A DATA >8010
       BSS  >0E
       DATA >8020
       BSS  >1E
       DATA >8008
       BSS  >06
       DATA >0020
       BSS  >1E
TFRE2B

*
* Deallocate space and merge multiple
*    free space
TFRE3
* Arrange
       LI   R0,TFRE3A
       MOV  R0,@BUFADR
       LI   R0,TFRE3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE3B+>2
       BLWP @BUFREE
* Assert
       LI   R0,>0014
       MOV  @TFRE3A,R1
       BLWP @AEQ
       TEXT 'We cant merge this. '
       TEXT 'We would have to start from beginning '
       TEXT 'of the buffer.'
       BYTE 0
       EVEN
*
       LI   R0,>0006+>18+>10
       MOV  @TFRE3B,R1
       BLWP @AEQ
       TEXT 'Space should now be deallocated '
       TEXT 'and merged with other blocks.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE3A DATA >0014
       BSS  >12
TFRE3B DATA >8006
       BSS  >04
       DATA >0018
       BSS  >16
       DATA >0010
       BSS  >0E
TFRE3Z

*
* Deallocate space between two free
*    spaces
TFRE4
* Arrange
       LI   R0,TFRE4A
       MOV  R0,@BUFADR
       LI   R0,TFRE4Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE4B+>2
       BLWP @BUFREE
* Assert
       LI   R0,>0014
       MOV  @TFRE4A,R1
       BLWP @AEQ
       TEXT 'We cant merge this. '
       TEXT 'We would have to start from beginning '
       TEXT 'of the buffer.'
       BYTE 0
       EVEN
*
       LI   R0,>000C+>18
       MOV  @TFRE4B,R1
       BLWP @AEQ
       TEXT 'Space should now be deallocated '
       TEXT 'and merged with other blocks.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE4A DATA >0014
       BSS  >12
TFRE4B DATA >800C
       BSS  >0A
       DATA >0018
       BSS  >16
TFRE4Z

*
* Deallocate space between two allocated
*    spaces
TFRE5
* Arrange
       LI   R0,TFRE5A
       MOV  R0,@BUFADR
       LI   R0,TFRE5Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE5B+>2
       BLWP @BUFREE
* Assert
       LI   R0,>8012
       MOV  @TFRE5A,R1
       BLWP @AEQ
       TEXT 'Block remains allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0004
       MOV  @TFRE5B,R1
       BLWP @AEQ
       TEXT 'Block is no longer allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TFRE5C,R1
       BLWP @AEQ
       TEXT 'Block remains allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE5A DATA >8012
       BSS  >10
TFRE5B DATA >8004
       BSS  >02
TFRE5C DATA >8010
       BSS  >0E
TFRE5Z

*
* Deallocate space after allocated but
*    before deallocated space
TFRE6
* Arrange
       LI   R0,TFRE6A
       MOV  R0,@BUFADR
       LI   R0,TFRE6Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE6B+>2
       BLWP @BUFREE
* Assert
       LI   R0,>8014
       MOV  @TFRE6A,R1
       BLWP @AEQ
       TEXT 'Block remains allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0006+>16
       MOV  @TFRE6B,R1
       BLWP @AEQ
       TEXT 'Block is no longer allocated '
       TEXT 'and is merged with the next.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TFRE6C,R1
       BLWP @AEQ
       TEXT 'Block remains allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE6A DATA >8014
       BSS  >12
TFRE6B DATA >8006
       BSS  >04
       DATA >0016
       BSS  >14
TFRE6C DATA >8010
       BSS  >0E
TFRE6Z

*
* Deallocate space at end of buffer
TFRE7
* Arrange
       LI   R0,TFRE7A
       MOV  R0,@BUFADR
       LI   R0,TFRE7Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TFRE7D+>2
       BLWP @BUFREE
* Assert
       LI   R0,>8014
       MOV  @TFRE7A,R1
       BLWP @AEQ
       TEXT 'Block remains allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0002
       MOV  @TFRE7B,R1
       BLWP @AEQ
       TEXT 'Block remains unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8026
       MOV  @TFRE7C,R1
       BLWP @AEQ
       TEXT 'Block remains allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0012
       MOV  @TFRE7D,R1
       BLWP @AEQ
       TEXT 'Block is no longer allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TFRE7A DATA >8014
       BSS  >12
TFRE7B DATA >0002
TFRE7C DATA >8026
       BSS  >24
TFRE7D DATA >8012
       BSS  >10
TFRE7Z

*
* Don't shrink.
* Block needs >0C bytes and has less
* than twice that.
TSRK1
* Arrange
       LI   R0,TSRK1A
       MOV  R0,@BUFADR
       LI   R0,TSRK1Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TSRK1A+2
       LI   R1,>16
       BLWP @BUFSRK
* Assert
       LI   R0,>8024
       MOV  @TSRK1A,R1
       BLWP @AEQ
       TEXT 'Allocation should not shrink. '
       TEXT 'Small enough already.'
       BYTE 0
       EVEN
*
       LI   R0,>0010
       MOV  @TSRK1B,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TSRK1A DATA >8024
       BSS  >22
TSRK1B DATA >0010
       DATA >0E
TSRK1Z

*
* Don't shrink.
* Block needs >6 bytes and has exactly
* than twice that.
TSRK2
* Arrange
       LI   R0,TSRK2A
       MOV  R0,@BUFADR
       LI   R0,TSRK2Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TSRK2B+2
       LI   R1,>06
       BLWP @BUFSRK
* Assert
       LI   R0,>8024
       MOV  @TSRK2A,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>800E
       MOV  @TSRK2B,R1
       BLWP @AEQ
       TEXT 'Block allocation should not shrink.'
       BYTE 0
       EVEN
*
       LI   R0,>0010
       MOV  @TSRK2C,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TSRK2A DATA >8024
       BSS  >22
TSRK2B DATA >800E
       BSS  >0C
TSRK2C DATA >0010
       DATA >0E
TSRK2Z

*
* Shrink without merging following block.
* New size is twice as big as required 
* space.
TSRK3
* Arrange
       LI   R0,TSRK3A
       MOV  R0,@BUFADR
       LI   R0,TSRK3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TSRK3B+2
       LI   R1,>04
       BLWP @BUFSRK
* Assert
       LI   R0,>8024
       MOV  @TSRK3A,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>800A
       MOV  @TSRK3B,R1
       BLWP @AEQ
       TEXT 'Block allocation should shrink.'
       BYTE 0
       EVEN
*
       LI   R0,>0002
       MOV  @TSRK3B+>0A,R1
       BLWP @AEQ
       TEXT 'A new unallocated block should appear.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TSRK3C,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TSRK3A DATA >8024
       BSS  >22
TSRK3B DATA >800C
       BSS  >0A
TSRK3C DATA >8010
       DATA >0E
TSRK3Z

*
* Shrink and merge following free block.
TSRK4
* Arrange
       LI   R0,TSRK4A
       MOV  R0,@BUFADR
       LI   R0,TSRK4Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TSRK4B+2
       LI   R1,>8
       BLWP @BUFSRK
* Assert
       LI   R0,>8014
       MOV  @TSRK4A,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8012
       MOV  @TSRK4B,R1
       BLWP @AEQ
       TEXT 'Block allocation should shrink.'
       BYTE 0
       EVEN
*
       LI   R0,>0016
       MOV  @TSRK4B+>12,R1
       BLWP @AEQ
       TEXT 'A new unallocated block should be '
       TEXT 'merged with another unallocated block.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TSRK4D,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer prior to action
TSRK4A DATA >8014
       BSS  >12
TSRK4B DATA >8018
       BSS  >16
TSRK4C DATA >0010
       DATA >0E
TSRK4D DATA >8010
       DATA >0E
TSRK4Z

*
* Don't grow a block. More space is left.
TGRW1
* Arrange
       LI   R0,TGRW1A
       MOV  R0,@BUFADR
       LI   R0,TGRW1Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW1C+2
       LI   R1,>12
       BLWP @BUFGRW
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW1C+2
       BLWP @AEQ
       TEXT 'Block should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>0004
       MOV  @TGRW1A,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TGRW1B,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8016
       MOV  @TGRW1C,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0006
       MOV  @TGRW1D,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer before action
TGRW1A DATA >0004
       BSS  2
TGRW1B DATA >8008
       BSS  6
TGRW1C DATA >8016
       BSS  >14
TGRW1D DATA >0006
       BSS  >4
TGRW1Z

*
* Don't grow a block. It's just right.
TGRW2
* Arrange
       LI   R0,TGRW2A
       MOV  R0,@BUFADR
       LI   R0,TGRW2Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW2B+2
       LI   R1,>16
       BLWP @BUFGRW
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW2B+2
       BLWP @AEQ
       TEXT 'Block should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>0010
       MOV  @TGRW2A,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8018
       MOV  @TGRW2B,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TGRW2C,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0006
       MOV  @TGRW2D,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer before action
TGRW2A DATA >0010
       BSS  >E
TGRW2B DATA >8018
       BSS  >16
TGRW2C DATA >8008
       BSS  >6
TGRW2D DATA >0006
       BSS  >4
TGRW2Z

*
* Grow a block, without moving it.
GRWAM3 EQU  >20                  * Growth amount
TGRW3
* Arrange
       LI   R0,TGRW3A
       MOV  R0,@BUFADR
       LI   R0,TGRW3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW3C+2
       LI   R1,GRWAM3
       BLWP @BUFGRW
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW3C+2
       BLWP @AEQ
       TEXT 'Block should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TGRW3A,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0008
       MOV  @TGRW3B,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8002+GRWAM3
       MOV  @TGRW3C,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated, '
       TEXT 'but be bigger.'
       BYTE 0
       EVEN
*
       LI   R0,>0026
       MOV  @TGRW3C+>02+GRWAM3,R1
       BLWP @AEQ
       TEXT 'This is a new unallocated block.'
       BYTE 0
       EVEN
*
       LI   R0,>8006
       MOV  @TGRW3E,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer before action
TGRW3A DATA >8010
       BSS  >E
TGRW3B DATA >0008
       BSS  >6
TGRW3C DATA >8008
       BSS  >6
TGRW3D DATA >0040
       BSS  >3E
TGRW3E DATA >8006
       BSS  >4
TGRW3Z

*
* Grow a block, without moving it.
* Merge some of the following free space.
GRWAM4 EQU  >20            Amount of space requested for allocation
TGRW4
* Arrange
       LI   R0,TGRW4A
       MOV  R0,@BUFADR
       LI   R0,TGRW4Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW4A+2
       LI   R1,GRWAM4
       BLWP @BUFGRW
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW4A+2
       BLWP @AEQ
       TEXT 'Block should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8002+GRWAM4
       MOV  @TGRW4A,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated, '
       TEXT 'but be bigger.'
       BYTE 0
       EVEN
*
       LI   R0,>0046
       MOV  @TGRW4A+>2+GRWAM4,R1
       BLWP @AEQ
       TEXT 'This is a new unallocated block. '
       TEXT 'It merges several free blocks.'
       BYTE 0
       EVEN
*
       LI   R0,>8006
       MOV  @TGRW4B,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       RT
* Buffer before action
TGRW4A DATA >8010
       BSS  >E
       DATA >0040
       BSS  >3E
       DATA >0008
       BSS  >6
       DATA >0010
       BSS  >E
TGRW4B DATA >8006
       BSS  >4
TGRW4Z

*
* Grow and move a block.
* Original block was followed by an
* allocated block.
GRWAM5 EQU  >20            Amount of space requested for allocation
TGRW5
* Arrange
       LI   R0,TGRW5A
       MOV  R0,@BUFADR
       LI   R0,TGRW5Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW5A+2
       LI   R1,GRWAM5
       BLWP @BUFGRW
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW5E+2
       BLWP @AEQ
       TEXT 'Block needed to move to '
       TEXT 'have enough space.'
       BYTE 0
       EVEN
*
       LI   R0,>0018
       MOV  @TGRW5A,R1
       BLWP @AEQ
       TEXT 'Original block should now be unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8004
       MOV  @TGRW5B,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0010
       MOV  @TGRW5C,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8010
       MOV  @TGRW5D,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8002+GRWAM5
       MOV  @TGRW5E,R1
       BLWP @AEQ
       TEXT 'This should be the newly allocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>003E
       MOV  @TGRW5E+>2+GRWAM5,R1
       BLWP @AEQ
       TEXT 'This should be left over free space.'
       BYTE 0
       EVEN
*
       RT
* Buffer before action
TGRW5A DATA >8018
       BSS  >16
TGRW5B DATA >8004
       BSS  >02
TGRW5C DATA >0010
       BSS  >0E
TGRW5D DATA >8010
       BSS  >0E
TGRW5E DATA >0060
       BSS  >5E
TGRW5Z

*
* Grow and move a block.
* Original block was followed by an
* unallocated block.
GRWAM6 EQU  >26            Amount of space requested for allocation
TGRW6
* Arrange
       LI   R0,TGRW6A
       MOV  R0,@BUFADR
       LI   R0,TGRW6Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW6B+2
       LI   R1,GRWAM6
       BLWP @BUFGRW
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW6E+2
       BLWP @AEQ
       TEXT 'Block needed to move to '
       TEXT 'have enough space.'
       BYTE 0
       EVEN
*
       LI   R0,TGRW6Y
       LI   R1,TGRW6E+2
       LI   R2,>14
       BLWP @ABLCK
       TEXT 'Original block contents should '
       TEXT 'have been copied to new block.'
       BYTE 0
       EVEN
*
       LI   R0,>8018
       MOV  @TGRW6A,R1
       BLWP @AEQ
       TEXT 'Block should remain unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>0026
       MOV  @TGRW6B,R1
       BLWP @AEQ
       TEXT 'Block should now be unallocated '
       TEXT 'and merged with next block.'
       BYTE 0
       EVEN
*
       LI   R0,>8004
       MOV  @TGRW6D,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,GRWAM6+>2+>8000
       MOV  @TGRW6E,R1
       BLWP @AEQ
       TEXT 'This should be the newly allocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>50-GRWAM6->2
       MOV  @TGRW6E+GRWAM6+>2,R1
       BLWP @AEQ
       TEXT 'This should be a new block of '
       TEXT 'unallocated space.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TGRW6F,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       RT
* Expected data to be copied
TGRW6Y DATA >AABB,>CCDD,>EEFF,>0011
       DATA >2233,>4455,>6677,>8899
       DATA >1234,>5678
* Buffer before action
TGRW6A DATA >8018
       BSS  >16
TGRW6B DATA >8016
       DATA >AABB,>CCDD,>EEFF,>0011
       DATA >2233,>4455,>6677,>8899
       DATA >1234,>5678
       DATA >0010
       BSS  >0E
TGRW6D DATA >8004
       BSS  >02
TGRW6E DATA >0050
       BSS  >4E
TGRW6F DATA >8008
       BSS  >06       
TGRW6Z

*
* Grow and move a block, and merge some
*    free spaces.
GRWAM7 EQU  >1F            Amount of space requested for allocation
GRWRD7 EQU  >20            Same as GRWAM7 rounded to an even number
TGRW7
* Arrange
       LI   R0,TGRW7A
       MOV  R0,@BUFADR
       LI   R0,TGRW7Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW7A+2
       LI   R1,GRWAM7
       BLWP @BUFGRW
* Assert an error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error looking for memory space'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,TGRW7C+2
       BLWP @AEQ
       TEXT 'Block needed to move to '
       TEXT 'have enough space.'
       BYTE 0
       EVEN
*
       LI   R0,TGRW7Y
       LI   R1,TGRW7C+2
       LI   R2,>0E
       BLWP @ABLCK
       TEXT 'Original block contents should '
       TEXT 'have been copied to new block.'
       BYTE 0
       EVEN
*
       LI   R0,>0010
       MOV  @TGRW7A,R1
       BLWP @AEQ
       TEXT 'Block should now be unallocated.'
       BYTE 0
       EVEN
*
       LI   R0,>8008
       MOV  @TGRW7B,R1
       BLWP @AEQ
       TEXT 'Block should remain allocated.'
       BYTE 0
       EVEN
*
       LI   R0,GRWRD7+>2+>8000
       MOV  @TGRW7C,R1
       BLWP @AEQ
       TEXT 'Block should be newly allocated.'
       BYTE 0
       EVEN
*
       LI   R0,>50+>08+>08+>10-GRWRD7->2
       MOV  @TGRW7C+GRWRD7+>2,R1
       BLWP @AEQ
       TEXT 'This free space includes previously '
       TEXT 'unallocated blocks merged together.'
       BYTE 0
       EVEN
*
       RT
* Data to have been copied
TGRW7Y DATA >0123,>4567,>89AB,>CDEF
       DATA >1122,>3344,>5566
* Buffer before action
TGRW7A DATA >8010
       DATA >0123,>4567,>89AB,>CDEF
       DATA >1122,>3344,>5566
TGRW7B DATA >8008
       BSS  >06
TGRW7C DATA >0050
       BSS  >4E
       DATA >0008
       BSS  >06
       DATA >0008
       BSS  >06
       DATA >0010
       BSS  >0E
TGRW7Z

*
* Fail to grow and move a block,
*    and the old block should not be deallocated.
*
TGRW8
* Arrange
       LI   R0,TGRW8A
       MOV  R0,@BUFADR
       LI   R0,TGRW8Z
       MOV  R0,@BUFEND
* Act
       LI   R0,TGRW8A+2
       LI   R1,>20
       BLWP @BUFGRW
* Assert an error has been detected
       BLWP @ASEQ
       TEXT 'Expected an error due to lack of memory'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,>FFFF
       BLWP @AEQ
       TEXT 'Expecting an out-of-space '
       TEXT 'error.'
       BYTE 0
       EVEN
*
       LI   R0,TGRW8Y
       LI   R1,TGRW8A
       LI   R2,>10
       BLWP @ABLCK
       TEXT 'Original block contents should '
       TEXT 'be undesturbed.'
       BYTE 0
       EVEN
*
       RT
* Original Data (including header)
TGRW8Y DATA >8010
       DATA >0123,>4567,>89AB,>CDEF
       DATA >1122,>3344,>5566
* Buffer before action
TGRW8A DATA >8010
       DATA >0123,>4567,>89AB,>CDEF
       DATA >1122,>3344,>5566
TGRW8B DATA >0008
       BSS  >06
       DATA >8050
       BSS  >4E
       DATA >0008
       BSS  >06
TGRW8Z

       END
       DEF  TSTLST,RSLTFL
*
       REF  AEQ,ANEQ,ABLCK,AL,AH
       REF  ASEQ,ASNEQ
*
       REF  ARYALC,ARYADD,ARYINS,ARYDEL
       REF  ARYADR
*
       REF  BUFADR,BUFEND

TSTLST DATA TSTEND-TSTLST-2/8
* Allocate array with 2-byte elements
       DATA ALC1
       TEXT 'ALC1  '
* Allocate array with 8-byte elements
       DATA ALC2
       TEXT 'ALC2  '
* There is not enough space to allocate
* this array.
       DATA ALC3
       TEXT 'ALC3  '
* Add element to empty array
       DATA ADD1
       TEXT 'ADD1  '
* Add element to 2-byte elem array
       DATA ADD2
       TEXT 'ADD2  '
* Add element to 4-byte elem array
       DATA ADD3
       TEXT 'ADD3  '
* Add element, mem-block grows
*    without moving
       DATA ADD4
       TEXT 'ADD4  '
* Add element, mem-block grows
*    without moving
       DATA ADD5
       TEXT 'ADD5  '
* Add element, mem-block grows and moves
       DATA ADD6
       TEXT 'ADD6  '
* Add element, mem-block grows and moves
       DATA ADD7
       TEXT 'ADD7  '
* Receive an error when adding element
       DATA ADD8
       TEXT 'ADD8  '
* Insert an element at the beginning of
*   an array
       DATA INS1
       TEXT 'INS1  '
* Insert an element at the middle of
*   an array
       DATA INS2
       TEXT 'INS2  '
* Insert an element at the end of
*   an array
       DATA INS3
       TEXT 'INS3  '
* Grow array without moving it
       DATA INS4
       TEXT 'INS4  '
* Grow array and move it.
*   No empty block follows the original.
       DATA INS5
       TEXT 'INS5  '
* Grow array and move it.
*   An empty block follows the original.
       DATA INS6
       TEXT 'INS6  '
* An error occurs growing array.
       DATA INS7
       TEXT 'INS7  '
* An error occurs because index is
*    out-of-range
       DATA INS8
       TEXT 'INS8  '
* Delete element from beggining
       DATA DEL1
       TEXT 'DEL1  '
* Delete element from middle
       DATA DEL2
       TEXT 'DEL2  '
* Delete element from end
       DATA DEL3
       TEXT 'DEL3  '
* Delete element and shrink block
       DATA DEL4
       TEXT 'DEL4  '
* Delete element and shrink block
       DATA DEL5
       TEXT 'DEL5  '
* Out-of-range error when deleting
       DATA DEL6
       TEXT 'DEL6  '
* Get address of an array element
	DATA ADR1
	TEXT 'ADR1  '
* Request address of out-of-range element
	DATA ADR2
	TEXT 'ADR2  '
TSTEND
RSLTFL BYTE RSLTFE-RSLTFL-1
       TEXT 'DSK2.TESTRESULT.TXT'
RSLTFE
       EVEN

OUTMEM EQU  -1              Out of memory
OUTRNG EQU  -2              Index Out of Range

*
* Allocate array with 2-byte elements
ALC1
* Arrange
       LI   R0,ALC1Y
       MOV  R0,@BUFADR
       LI   R0,ALC1Z
       MOV  R0,@BUFEND
* Act
* Store result address in R10
* (2^1 = 2)
       LI   R0,1
       BLWP @ARYALC
       MOV  R0,R10
* Assert
       LI   R0,ALC1Y+>12
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'R0 should return the address at which '
       TEXT 'the array was assigned to. '
       TEXT 'This the first free address in the buffer.'
       BYTE 0
       EVEN
*
       LI   R0,ALC1A
       MOV  R10,R1
       LI   R2,ALC1B-ALC1A
       BLWP @ABLCK
       TEXT 'First word should specify 0 elements '
       TEXT 'exist in the array. '
       TEXT 'Second word should specify element '
       TEXT 'length using "1" for 2 bytes. '
       TEXT '(2^1 = 2)'
       BYTE 0
       EVEN
*
       RT
* Expected array contents.
ALC1A  DATA >0000,>0001
ALC1B
* Initial buffer space
ALC1Y  DATA >8010
       BSS  >0E
       DATA >0020
       BSS  >1E
       DATA >8010
       BSS  >0E
ALC1Z

*
* Allocate array with 8-byte elements
ALC2
* Arrange
       LI   R0,ALC2Y
       MOV  R0,@BUFADR
       LI   R0,ALC2Z
       MOV  R0,@BUFEND
* Act
* Store result address in R10
* (2^3 = 8)
       LI   R0,3
       BLWP @ARYALC
       MOV  R0,R10
* Assert
       LI   R0,ALC2Y+2
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'R0 should return the address at which '
       TEXT 'the array was assigned to. '
       TEXT 'This the first free address in the buffer.'
       BYTE 0
       EVEN
*
       LI   R0,ALC2A
       MOV  R10,R1
       LI   R2,ALC2B-ALC2A
       BLWP @ABLCK
       TEXT 'First word should specify 0 elements '
       TEXT 'exist in the array. '
       TEXT 'Second word should specify element '
       TEXT 'length using "3" for 8 bytes. '
       TEXT '(2^3 = 8)'
       BYTE 0
       EVEN
*
       RT
* Expected array contents.
ALC2A  DATA >0000,>0003
ALC2B
* Initial buffer space
ALC2Y  DATA >0040
       BSS  >3E
ALC2Z

*
* Fail to allocate an array.
* No space.
ALC3
* Arrange
       LI   R0,ALC3Y
       MOV  R0,@BUFADR
       LI   R0,ALC3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,5
       BLWP @ARYALC
* Assert
       MOV  R0,R1
       LI   R0,>FFFF
       BLWP @AEQ
       TEXT 'The array should not have been loaded.'
       BYTE 0
       EVEN
*
       RT
* Initial buffer space
ALC3Y  DATA >8040
       BSS  >3E
ALC3Z

*
* Add an element to an empty array
ADD1
* Arrange
       LI   R0,ADD1Y
       MOV  R0,@BUFADR
       LI   R0,ADD1Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD1X+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,ADD1X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>0001
       MOV  *R9,R1
       BLWP @AEQ
       TEXT 'Array should now have one element.'
       BYTE 0
       EVEN
*
       LI   R0,>8028
       MOV  @ADD1X,R1
       BLWP @AEQ
       TEXT 'Memory block should not grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD1X+6
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'New element is first in the array. '
       TEXT 'Its address should be right after '
       TEXT 'the array header, which is 4-bytes long.'
       BYTE 0
       EVEN
*
       RT
* Initial buffer space
ADD1Y  DATA >8008
       BSS  >06
ADD1X  
* Array's block header
       DATA >8028
* Array header
       DATA >0000,>0003
       BSS  >1A
       DATA >0010
       BSS  >16
ADD1Z

*
* Add an element to an array with
* 2-byte elements.
ADD2
* Arrange
       LI   R0,ADD2Y
       MOV  R0,@BUFADR
       LI   R0,ADD2Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD2Y+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,ADD2Y+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8020
       MOV  @ADD2Y,R1
       BLWP @AEQ
       TEXT 'Memory block should not grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD2Y+2+4+6
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Array should have four elements '
       TEXT 'but the contents of the new element '
       TEXT 'are non-deterministic.'
       BYTE 0
       EVEN
*
       RT
* Expected array contents.
* Basically only the element count
* should change.
* We don't care about the inital
* contents of the new element.
ADD2A
       DATA >0004,>0001
       DATA >0101,>0202,>0303
ADD2B
* Initial buffer space
ADD2Y  
* Array's block header
       DATA >8020
* Array header
       DATA >0003,>0001
* The 3 elements in the array
       DATA >0101,>0202,>0303
       BSS  >14
       DATA >0010
       BSS  >E
ADD2Z

*
* Add an element to an array with
* 4-byte elements.
ADD3
* Arrange
       LI   R0,ADD3Y
       MOV  R0,@BUFADR
       LI   R0,ADD3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD3X+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10       
* Assert
       LI   R0,ADD3X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,ADD3X+2+4+8
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Location of new element should '
       TEXT 'follow last previous element.'
       BYTE 0
       EVEN
*
       LI   R0,>8020
       MOV  @ADD3X,R1
       BLWP @AEQ
       TEXT 'Memory block should not grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD3A
       LI   R1,ADD3X+2
       LI   R2,>0C
       BLWP @ABLCK
       TEXT 'Array should now have three '
       TEXT 'elements, and the first two '
       TEXT 'elements should not change.'
       BYTE 0
       EVEN
*
       RT
* Expected array contents after adding
* an element.
ADD3A  DATA >0003,>0002
       DATA >3003,>0330,>2002,>0220
ADD3B
* Initial buffer contents
ADD3Y  DATA >0004
       BSS  >2
ADD3X  DATA >8020
* Array header
       DATA >0002,>0002
* Array contents
       DATA >3003,>0330,>2002,>0220
* Unused contents of the same block
       BSS  >12
*
       DATA >0010
ADD3Z

*
* Add an element. Grow the memory block.
* Block will not move.
ADD4
* Arrange
       LI   R0,ADD4Y
       MOV  R0,@BUFADR
       LI   R0,ADD4Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD4X+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10 
* Assert
       LI   R0,ADD4X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,ADD4X+2+4+24
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Location of new element should '
       TEXT 'follow last previous element.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+ADD4W-ADD4X
       MOV  @ADD4X,R1
       BLWP @AL
       TEXT 'Memory block should have grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD4A
       LI   R1,ADD4X+2
       LI   R2,ADD4B-ADD4A
       BLWP @ABLCK
       TEXT 'Array should now have four '
       TEXT 'elements, and the first three '
       TEXT 'elements should not change.'
       BYTE 0
       EVEN
*
       RT
* Expected array contents after adding
*    an element
ADD4A  DATA >0004,>0003
       DATA >1111,>0101,>1001,>0110
       DATA >2222,>0202,>2002,>0220
       DATA >3333,>0303,>3003,>0330
ADD4B
* Initial buffer contents
ADD4Y  DATA >0010
       BSS  >0E
ADD4X  DATA >8000+ADD4W-ADD4X
       DATA >0003,>0003
       DATA >1111,>0101,>1001,>0110
       DATA >2222,>0202,>2002,>0220
       DATA >3333,>0303,>3003,>0330
       BSS  >4
ADD4W  DATA >0040
       BSS  >3E
ADD4Z

*
* Add an element. Grow the memory block.
* Block will not move.
ADD5
* Arrange
       LI   R0,ADD5Y
       MOV  R0,@BUFADR
       LI   R0,ADD5Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD5X+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10 
* Assert
       LI   R0,ADD5X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,ADD5X+2+4+10
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Location of new element should '
       TEXT 'follow last previous element.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+ADD5W-ADD5X
       MOV  @ADD5X,R1
       BLWP @AL
       TEXT 'Memory block should have grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD5A
       LI   R1,ADD5X+2
       LI   R2,ADD5B-ADD5A
       BLWP @ABLCK
       TEXT 'Array should now have six '
       TEXT 'elements, and the first five '
       TEXT 'elements should not change.'
       BYTE 0
       EVEN
*
       RT
* Expected array contents after adding
*    an element
ADD5A
       DATA >0006,>0001
       DATA >1111,>2222,>3333,>4444
       DATA >5555
ADD5B
* Initial buffer contents
ADD5Y  DATA >0008
       BSS  >06
       DATA >8008
       BSS  >06
ADD5X  DATA >8000+ADD5W-ADD5X
* Array header
       DATA >0005,>0001
* Array elements (2-bytes each)
       DATA >1111,>2222,>3333,>4444
       DATA >5555
ADD5W  DATA >0020
       BSS  >1E
       DATA >8010
       BSS  >0E
ADD5Z

*
* Add an element. Grow the memory block.
* Memory block will move.
ADD6
* Arrange
       LI   R0,ADD6Y
       MOV  R0,@BUFADR
       LI   R0,ADD6Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD6Y+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10 
* Assert
       LI   R0,>FFFF
       MOV  R9,R1
       BLWP @ANEQ
       TEXT 'Array have been allocated.'
       BYTE 0
       EVEN
*
       LI   R0,ADD6Y+2
       MOV  R9,R1
       BLWP @ANEQ
       TEXT 'Array should have moved.'
       BYTE 0
       EVEN
*
       MOV  R9,R0
       AI   R0,4+12
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Location of new element should '
       TEXT 'follow last previous element.'
       TEXT 'That should be 4 + 4*3 bytes '
       TEXT 'from the array header.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+ADD6X-ADD6Y
       MOV  R9,R1
       DECT R1
       MOV  *R1,R1
       BLWP @AL
       TEXT 'Memory block should have grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD6A
       MOV  R9,R1
       LI   R2,ADD6B-ADD6A
       BLWP @ABLCK
       TEXT 'Array should now have four '
       TEXT 'elements, and the first three '
       TEXT 'elements should not change.'
       BYTE 0
       EVEN
*
       RT
* Expected array contents after adding
*    an element
ADD6A
       DATA >0004,>0002
       DATA >1111,>1000,>2222,>2000
       DATA >3333,>3000
ADD6B
* Initial buffer contents
ADD6Y  DATA >8000+ADD6X-ADD6Y
* Array header
       DATA >0003,>0002
* Array elements (4-bytes each)
       DATA >1111,>1000,>2222,>2000
       DATA >3333,>3000
ADD6X  DATA >8010
       BSS  >0E
       DATA >0050
       BSS  >4E
ADD6Z

*
* Add an element. Grow the memory block.
* Memory block will move.
* In this case, there is a small free
* block following array, but it's too
* small.
ADD7
* Arrange
       LI   R0,ADD7Y
       MOV  R0,@BUFADR
       LI   R0,ADD7Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD7Y+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10 
* Assert
       LI   R0,>FFFF
       MOV  R9,R1
       BLWP @ANEQ
       TEXT 'Array have been allocated.'
       BYTE 0
       EVEN
*
       LI   R0,ADD7Y+2
       MOV  R9,R1
       BLWP @ANEQ
       TEXT 'Array should have moved.'
       BYTE 0
       EVEN
*
       MOV  R9,R0
       AI   R0,4+8
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Location of new element should '
       TEXT 'follow last previous element.'
       TEXT 'That should be 4 + 1*8 bytes '
       TEXT 'from the array header.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+ADD7X-ADD7Y
       MOV  R9,R1
       DECT R1
       MOV  *R1,R1
       BLWP @AL
       TEXT 'Memory block should have grown.'
       BYTE 0
       EVEN
*
       LI   R0,ADD7A
       MOV  R9,R1
       LI   R2,ADD7B-ADD7A
       BLWP @ABLCK
       TEXT 'Array should now have four '
       TEXT 'elements, and the first three '
       TEXT 'elements should not change.'
       BYTE 0
       EVEN
*
       RT
* Expected array contents after adding
*    an element
ADD7A
       DATA >0002,>0003
       DATA >1111,>1000,>0001,>1001
ADD7B
* Initial buffer contents
ADD7Y  DATA >8000+ADD7X-ADD7Y
* Array header
       DATA >0001,>0003
* Array elements (8-bytes each)
       DATA >1111,>1000,>0001,>1001
ADD7X  DATA >0006
       BSS  >04
       DATA >8008
       BSS  >06
       DATA >0050
       BSS  >4E
ADD7Z

*
* Receive an error when attempting to
* add an element.
ADD8
* Arrange
       LI   R0,ADD8Y
       MOV  R0,@BUFADR
       LI   R0,ADD8Z
       MOV  R0,@BUFEND
* Act
       LI   R0,ADD8X+2
       BLWP @ARYADD
       MOV  R0,R9
       MOV  R1,R10 
* Assert
       LI   R0,>FFFF
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'There should not be enough '
       TEXT 'memory to re-allocate the '
       TEXT 'array.'
       BYTE 0
       EVEN
*
       RT
* Initial buffer contents
ADD8Y  DATA >8008
       BSS  >6
ADD8X  DATA >800E
* Array header
       DATA >0001,>0003
* Array elements (8-bytes each)
       DATA >1111,>1000,>0001,>1001
       DATA >0006
       BSS  >04
       DATA >8008
       BSS  >06
       DATA >8020
       BSS  >1E
ADD8Z

*
* Insert an element at the beginning of
*   an array
INS1
* Arrange
       LI   R0,INS1Y
       MOV  R0,@BUFADR
       LI   R0,INS1Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS1X+2
       LI   R1,0
       BLWP @ARYINS
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,INS1X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,INS1X+2+4
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Element address should be '
       TEXT 'directly after the array header.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+INS1W-INS1X
       MOV  @INS1X,R1
       BLWP @AEQ
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,INS1A
       LI   R1,INS1X+2
       LI   R2,INS1B-INS1A
       BLWP @ABLCK
       TEXT 'Array should have one more '
       TEXT 'element. The elements should have '
       TEXT 'been copied backwards to insert '
       TEXT 'one more 2-byte element.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
INS1A  DATA >0003,>0001
       DATA >0220,>0220,>0330
INS1B
* Initial Buffer Contents
INS1Y  DATA >8008
       BSS  >6
INS1X  DATA >8000+INS1W-INS1X
       DATA >0002,>0001
       DATA >0220,>0330
       BSS  >8
INS1W  DATA >0040
       BSS  >3E
INS1Z

*
* Insert an element at the middle of
*   an array
INS2
* Arrange
       LI   R0,INS2Y
       MOV  R0,@BUFADR
       LI   R0,INS2Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS2X+2
       LI   R1,2
       BLWP @ARYINS
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,INS2X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,INS2X+2+4+8
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Element address should be '
       TEXT 'directly after the second '
       TEXT 'element.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+INS2W-INS2X
       MOV  @INS2X,R1
       BLWP @AEQ
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,INS2A
       LI   R1,INS2X+2
       LI   R2,INS2B-INS2A
       BLWP @ABLCK
       TEXT 'Array should have one more '
       TEXT 'element. The elements should have '
       TEXT 'been copied backwards to insert '
       TEXT 'one more 4-byte element.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
INS2A
       DATA >0005,>0002
       DATA >1001,>1110,>2002,>2220
       DATA >4004,>4440
       DATA >4004,>4440,>5005,>5550
INS2B
* Initial Buffer Contents
INS2Y  DATA >0008
       BSS  >6
       DATA >8010
       BSS  >0E
INS2X  DATA >8000+INS2W-INS2X
       DATA >0004,>0002
       DATA >1001,>1110,>2002,>2220
       DATA >4004,>4440,>5005,>5550
       BSS  >8
INS2W  DATA >0040
       BSS  >3E
INS2Z

*
* Insert an element at the end of
*   an array
INS3
* Arrange
       LI   R0,INS3Y
       MOV  R0,@BUFADR
       LI   R0,INS3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS3X+2
       LI   R1,2
       BLWP @ARYINS
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,INS3X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,INS3X+2+4+16
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Element address should be '
       TEXT 'at the end of the array.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+INS3W-INS3X
       MOV  @INS3X,R1
       BLWP @AEQ
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,INS3A
       LI   R1,INS3X+2
       LI   R2,INS3B-INS3A
       BLWP @ABLCK
       TEXT 'Array should have one more '
       TEXT 'element.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
INS3A
       DATA >0003,>0003
       DATA >1001,>1110,>0111,>0110
       DATA >2002,>2220,>0222,>0220
INS3B
* Initial Buffer Contents
INS3Y  DATA >0008
       BSS  >6
INS3X  DATA >8000+INS3W-INS3X
       DATA >0002,>0003
       DATA >1001,>1110,>0111,>0110
       DATA >2002,>2220,>0222,>0220
       BSS  >10
INS3W  DATA >0040
       BSS  >3E
       DATA >8010
       BSS  >0E
INS3Z

*
* Insert an element at index 1.
*   Grow the block, but do not
*   move the data.
INS4
* Arrange
       LI   R0,INS4Y
       MOV  R0,@BUFADR
       LI   R0,INS4Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS4X+2
       LI   R1,1
       BLWP @ARYINS
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,INS4X+2
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,INS4X+2+4+2
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Element address should be '
       TEXT 'after the array header and one '
       TEXT '2-byte element.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+INS4W-INS4X
       MOV  @INS4X,R1
       BLWP @AL
       TEXT 'Block size should have grown.'
       BYTE 0
       EVEN
*
       LI   R0,INS4A
       LI   R1,INS4X+2
       LI   R2,INS4B-INS4A
       BLWP @ABLCK
       TEXT 'Array should have one more '
       TEXT 'element. The elements should have '
       TEXT 'been copied backwards to insert '
       TEXT 'one more 2-byte element.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
INS4A  DATA >0004,>0001
       DATA >0110,>0330,>0330,>0440
INS4B
* Initial Buffer Contents
INS4Y
INS4X  DATA >8000+INS4W-INS4X
       DATA >0003,>0001
       DATA >0110,>0330,>0440
INS4W  DATA >0010
       BSS  >0E
       DATA >8020
       BSS  >1E
       DATA >0010
       BSS  >0E
INS4Z

*
* Insert an element at the middle of
*   an array.
* Grow array and move it.
*   No empty block follows the original.
INS5
* Arrange
       LI   R0,INS5Y
       MOV  R0,@BUFADR
       LI   R0,INS5Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS5X+2
       LI   R1,3
       BLWP @ARYINS
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,INS5X+2
       MOV  R9,R1
       BLWP @ANEQ
       TEXT 'Array should have moved.'
       BYTE 0
       EVEN
*
       MOV  R9,R0
       AI   R0,4+12
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Element address should be '
       TEXT 'directly after the third '
       TEXT 'element.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+INS5W-INS5X
       MOV  R9,R1
       DECT R1
       MOV  *R1,R1
       BLWP @AL
       TEXT 'Block size should have '
       TEXT 'grown.'
       BYTE 0
       EVEN
*
       LI   R0,INS5A
       MOV  R9,R1
       LI   R2,INS5B-INS5A
       BLWP @ABLCK
       TEXT 'Array should have one more '
       TEXT 'element. The elements should have '
       TEXT 'been copied backwards to insert '
       TEXT 'one more 4-byte element.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
INS5A
       DATA >0005,>0002
       DATA >1001,>1110,>2002,>2220
       DATA >3003,>3330,>5005,>5550
       DATA >5005,>5550
INS5B
* Initial Buffer Contents
INS5Y  DATA >8018
       BSS  >16
INS5X  DATA >8000+INS5W-INS5X
       DATA >0004,>0002
       DATA >1001,>1110,>2002,>2220
       DATA >3003,>3330,>5005,>5550
       BSS  >2
INS5W  DATA >8004
       BSS  >2
       DATA >0060
       BSS  >5E
INS5Z

*
* Insert an element at the end of
*   an array.
* Grow array and move it.
*   A small empty block follows the original.
INS6
* Arrange
       LI   R0,INS6Y
       MOV  R0,@BUFADR
       LI   R0,INS6Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS6X+2
       LI   R1,3
       BLWP @ARYINS
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,INS6X+2
       MOV  R9,R1
       BLWP @ANEQ
       TEXT 'Array should have moved.'
       BYTE 0
       EVEN
*
       MOV  R9,R0
       AI   R0,4+24
       MOV  R10,R1
       BLWP @AEQ
       TEXT 'Element address should be '
       TEXT 'directly after the third '
       TEXT 'element.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+INS6W-INS6X
       MOV  R9,R1
       DECT R1
       MOV  *R1,R1
       BLWP @AL
       TEXT 'Block size should have '
       TEXT 'grown.'
       BYTE 0
       EVEN
*
       LI   R0,INS6A
       MOV  R9,R1
       LI   R2,INS6B-INS6A
       BLWP @ABLCK
       TEXT 'Array should have one more '
       TEXT 'element.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
INS6A
       DATA >0004,>0003
       DATA >1001,>1110,>0110,>0111
       DATA >2002,>2220,>0220,>0222
       DATA >3003,>3330,>0330,>0333
INS6B
* Initial Buffer Contents
INS6Y  DATA >8018
       BSS  >16
INS6X  DATA >8000+INS6W-INS6X
       DATA >0003,>0003
       DATA >1001,>1110,>0110,>0111
       DATA >2002,>2220,>0220,>0222
       DATA >3003,>3330,>0330,>0333
       BSS  >2
INS6W  DATA >0004
       BSS  >2
       DATA >8004
       BSS  >2
       DATA >0060
       BSS  >5E
INS6Z

*
* An error occurs due to a lack of
*   free space.
INS7
* Arrange
       LI   R0,INS7Y
       MOV  R0,@BUFADR
       LI   R0,INS7Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS7X+2
       LI   R1,2
       BLWP @ARYINS
* Assert an error through status bit
       BLWP @ASEQ
       TEXT 'Expected equal status bit to '
       TEXT 'be set.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,>FFFF
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'There should be an error.'
       BYTE 0
       EVEN
*
       RT
* Initial Buffer Contents
INS7Y  DATA >8018
       BSS  >16
INS7X  DATA >8000+INS7W-INS7X
       DATA >0003,>0003
       DATA >1001,>1110,>0110,>0111
       DATA >2002,>2220,>0220,>0222
       DATA >3003,>3330,>0330,>0333
       BSS  >2
INS7W  DATA >0004
       BSS  >2
       DATA >8004
       BSS  >2
INS7Z

*
* An error occurs because the index
*   is out of range
INS8
* Arrange
       LI   R0,INS8Y
       MOV  R0,@BUFADR
       LI   R0,INS8Z
       MOV  R0,@BUFEND
* Act
       LI   R0,INS8X+2
       LI   R1,4
       BLWP @ARYINS
* Assert an error through status bit
       BLWP @ASEQ
       TEXT 'Expected equal status bit to '
       TEXT 'be set.'
       BYTE 0
* Move output of BLWP @ARYINS
       MOV  R0,R9
       MOV  R1,R10
* Assert
       LI   R0,>FFFE
       MOV  R9,R1
       BLWP @AEQ
       TEXT 'There are only three elements. '
       TEXT 'It is not possible to insert at '
       TEXT 'index 4.'
       BYTE 0
       EVEN
*
       RT
* Initial Buffer Contents
INS8Y  DATA >8018
       BSS  >16
INS8X  DATA >8000+INS8W-INS8X
       DATA >0003,>0002
       DATA >1001,>1110
       DATA >2002,>2220
       DATA >3003,>3330
       BSS  >20
INS8W  
INS8Z

*
* Delete element from the beginning of
* the array without shrinking the block
DEL1
* Arrange
       LI   R0,DEL1Y
       MOV  R0,@BUFADR
       LI   R0,DEL1Z
       MOV  R0,@BUFEND
* Act
       LI   R0,DEL1X+2
       LI   R1,0
       BLWP @ARYDEL
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,DEL1X+2
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+DEL1W-DEL1X
       MOV  @DEL1X,R1
       BLWP @AEQ
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,DEL1A
       LI   R1,DEL1X+2
       LI   R2,DEL1B-DEL1A
       BLWP @ABLCK
       TEXT 'Array should have one fewer '
       TEXT 'elements.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
DEL1A
       DATA >0003,>0001
       DATA >0220,>0330,>0440
DEL1B
* Initial Buffer Contents
DEL1Y  DATA >8008
       BSS  >6
DEL1X  DATA >8000+DEL1W-DEL1X
       DATA >0004,>0001
       DATA >0110,>0220,>0330,>0440
       BSS  >2
DEL1W  DATA >0010
       BSS  >0E
DEL1Z

*
* Delete element from the middle of
* the array without shrinking the block
DEL2
* Arrange
       LI   R0,DEL2Y
       MOV  R0,@BUFADR
       LI   R0,DEL2Z
       MOV  R0,@BUFEND
* Act
       LI   R0,DEL2X+2
       LI   R1,2
       BLWP @ARYDEL
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,DEL2X+2
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+DEL2W-DEL2X
       MOV  @DEL2X,R1
       BLWP @AEQ
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,DEL2A
       LI   R1,DEL2X+2
       LI   R2,DEL2B-DEL2A
       BLWP @ABLCK
       TEXT 'Array should have one fewer '
       TEXT 'elements.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
DEL2A
       DATA >0004,>0002
       DATA >0110,>1111,>0220,>2222
       DATA >0440,>4444
       DATA >0550,>5555
DEL2B
* Initial Buffer Contents
DEL2Y  DATA >8010
       BSS  >0E
       DATA >0010
       BSS  >0E
DEL2X  DATA >8000+DEL2W-DEL2X
       DATA >0005,>0002
       DATA >0110,>1111,>0220,>2222
       DATA >0330,>3333,>0440,>4444
       DATA >0550,>5555
       BSS  >4
DEL2W  
DEL2Z

*
* Delete element from the middle of
* the array without shrinking the block
DEL3
* Arrange
       LI   R0,DEL3Y
       MOV  R0,@BUFADR
       LI   R0,DEL3Z
       MOV  R0,@BUFEND
* Act
       LI   R0,DEL3X+2
       LI   R1,3
       BLWP @ARYDEL
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,DEL3X+2
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+DEL3W-DEL3X
       MOV  @DEL3X,R1
       BLWP @AEQ
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,DEL3A
       LI   R1,DEL3X+2
       LI   R2,DEL3B-DEL3A
       BLWP @ABLCK
       TEXT 'Array should have one fewer '
       TEXT 'elements.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
DEL3A
       DATA >0003,>0003
       DATA >0110,>1111,>1011,>1001
       DATA >0220,>2222,>2022,>2002
       DATA >0330,>3333,>3033,>3003
DEL3B
* Initial Buffer Contents
DEL3Y  DATA >8010
       BSS  >0E
       DATA >0010
       BSS  >0E
DEL3X  DATA >8000+DEL3W-DEL3X
       DATA >0004,>0003
       DATA >0110,>1111,>1011,>1001
       DATA >0220,>2222,>2022,>2002
       DATA >0330,>3333,>3033,>3003
       DATA >0440,>4444,>4044,>4004
       BSS  >6
DEL3W  DATA >8010
       BSS  >0E
       DATA >0010
       BSS  >0E
DEL3Z

*
* Delete element and shrink block.
* It is the last block in the buffer.
DEL4
* Arrange
       LI   R0,DEL4Y
       MOV  R0,@BUFADR
       LI   R0,DEL4Z
       MOV  R0,@BUFEND
* Act
       LI   R0,DEL4X+2
       LI   R1,1
       BLWP @ARYDEL
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,DEL4X+2
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+DEL4W-DEL4X
       MOV  @DEL4X,R1
       BLWP @AH
       TEXT 'Block size should have '
       TEXT 'shrunk.'
       BYTE 0
       EVEN
*
       LI   R0,DEL4A
       LI   R1,DEL4X+2
       LI   R2,DEL4B-DEL4A
       BLWP @ABLCK
       TEXT 'Array should have one fewer '
       TEXT 'elements.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
DEL4A
       DATA >0002,>0003
       DATA >0110,>1111,>1011,>1001
       DATA >0330,>3333,>3033,>3003
DEL4B
* Initial Buffer Contents
DEL4Y  DATA >8010
       BSS  >0E
       DATA >0010
       BSS  >0E
DEL4X  DATA >8000+DEL4W-DEL4X
       DATA >0003,>0003
       DATA >0110,>1111,>1011,>1001
       DATA >0220,>2222,>2022,>2002
       DATA >0330,>3333,>3033,>3003
       BSS  >20
DEL4W  
DEL4Z

*
* Delete element and shrink block.
* It is followed by an allocated block.
DEL5
* Arrange
       LI   R0,DEL5Y
       MOV  R0,@BUFADR
       LI   R0,DEL5Z
       MOV  R0,@BUFEND
* Act
       LI   R0,DEL5X+2
       LI   R1,3
       BLWP @ARYDEL
* Assert no error through status bit
       BLWP @ASNEQ
       TEXT 'Expected status bit to claim '
       TEXT 'no error.'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,DEL5X+2
       BLWP @AEQ
       TEXT 'Array should not have moved.'
       BYTE 0
       EVEN
*
       LI   R0,>8000+DEL5W-DEL5X
       MOV  @DEL5X,R1
       BLWP @AH
       TEXT 'Block size should not have '
       TEXT 'changed.'
       BYTE 0
       EVEN
*
       LI   R0,DEL5A
       LI   R1,DEL5X+2
       LI   R2,DEL5B-DEL5A
       BLWP @ABLCK
       TEXT 'Array should have one fewer '
       TEXT 'elements.'
       BYTE 0
       EVEN
*
       RT
* Expected Array Contents
DEL5A
       DATA >0003,>0002
       DATA >1011,>1001
       DATA >2022,>2002
       DATA >3033,>3003
DEL5B
* Initial Buffer Contents
DEL5Y  DATA >8010
       BSS  >0E
DEL5X  DATA >8000+DEL5W-DEL5X
       DATA >0004,>0002
       DATA >1011,>1001
       DATA >2022,>2002
       DATA >3033,>3003
       DATA >4044,>4004
       BSS  >20
DEL5W  DATA 8018
       BSS  >16
DEL5Z

*
* Out-of-range when deleting element
DEL6
* Arrange
       LI   R0,DEL6Y
       MOV  R0,@BUFADR
       LI   R0,DEL6Z
       MOV  R0,@BUFEND
* Act
       LI   R0,DEL6X+2
       LI   R1,10
       BLWP @ARYDEL
* Assert an error to be detected
       BLWP @ASEQ
       TEXT 'Expected status bit to reflect '
       TEXT 'out-of-range error.'
       BYTE 0
* Assert
       MOV  R0,R1
       LI   R0,>FFFE
       BLWP @AEQ
       TEXT 'Should have an out-of-range error.'
       BYTE 0
       EVEN
*
       RT
* Initial Buffer Contents
DEL6Y  DATA >8010
       BSS  >0E
DEL6X  DATA >8000+DEL6W-DEL6X
       DATA >0004,>0002
       DATA >1011,>1001
       DATA >2022,>2002
       DATA >3033,>3003
       DATA >4044,>4004
       BSS  >20
DEL6W  DATA >8018
       BSS  >16
DEL6Z

*
* Get address of an array element
*
ADR1
* Arrange
       LI   R0,ADR1Y
	MOV  R0,@BUFADR
	LI   R1,ADR1Z
	MOV  R1,@BUFEND
* Act
* Outputs element address to R1
       LI   R0,ADR1X
	LI   R1,3
	BLWP @ARYADR
* Assert no error has been detected
       BLWP @ASNEQ
       TEXT 'Expected no error because element is in array'
       BYTE 0
* Assert
	LI   R0,ADR1W
       MOV  R1,R1
	BLWP @AEQ
	TEXT 'Should get the address of the '
	TEXT 'element at index 3. It contains '
	TEXT 'the number 4 over and over.'
	BYTE 0
	EVEN
*
       RT
* Initial buffer contents
ADR1Y  DATA >8020
       BSS  >1E
	DATA >0004
	BSS  >02
       DATA >8000+ADR1W-ADR1X
ADR1X  DATA >0004,>0003
	DATA >1111,>1111,>1111,>1111
	DATA >2222,>2222,>2222,>2222
	DATA >3333,>3333,>3333,>3333
ADR1W  DATA >4444,>4444,>4444,>4444
	DATA >5555,>5555,>5555,>5555
       DATA >800A
       BSS  >08
ADR1Z

*
* Ask for address of an array element,
* but get an error because element is out of range.
*
ADR2
* Arrange
       LI   R0,ADR1Y
	MOV  R0,@BUFADR
	LI   R1,ADR1Z
	MOV  R1,@BUFEND
* Act
* Outputs element address to R1
       LI   R0,ADR1X
	LI   R1,5
	BLWP @ARYADR
* Assert an error has been detected
       BLWP @ASEQ
       TEXT 'Expected an error because highest '
       TEXT 'index in array is 4, not 5.'
       BYTE 0
* Assert
	LI   R0,OUTRNG
       MOV  R1,R1
	BLWP @AEQ
	TEXT 'Should get out-of-range error '
       TEXT 'because there are not 5 elements '
       TEXT 'in the array.'
	BYTE 0
	EVEN
*
       RT

       END
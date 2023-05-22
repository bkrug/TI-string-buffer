       DEF  BUFINT,BUFALC,BUFCPY,BUFREE
       DEF  BUFSRK,BUFGRW
       DEF  BLKUSE
*
       REF  STRWS,BUFADR,BUFEND
* This library of routines stores
* chunks in a way that is inspired by
* but different from the C language's
* malloc() and free() methods.
*
* Using this library you can reserve an
* area of memory of a particular size at
* a particular address with memory 
* chunks of various sizes.
*
* Each chunk contains a header pointing
* to the next chunk. The header is two
* bytes in size, and the rest stores 
* content.
*
* Among the 16 header bits,
* the first bit is set if the chunk is
* used, otherwise reset. The other 15
* are the offset to the next chunk. 
* The next chunk can be at most >7FFE
* bytes further away. Chunks are 
* expected to be sequentially located. 
* Note that if the block size is >20, 
* then the first two bytes will be 
* header bytes and only >1E bytes can 
* hold data. 

* Mask to set or reset the "used" bit.
BLKUSE DATA >8000

* 
* **** BUFINT ****
* Reserve Space for a memory buffer
*
* R0 - buffer memory address
* R1 - buffer size (>4 to >7FFE valid)
*
* Output:
* R0 - >0000 if successful
*      >FFFF if error
*
BUFINT DATA STRWS,BUFINT+4
* Get routine parameters
       MOV  *R13,R8
       MOV  @2(13),R9
       MOV  R8,@BUFADR
* Return error if buffer size is less
* than or equal to 4
       CI   R9,4
       JLE  INTEND
* Return error if buffer size is greater
* than or equal to >8000
       MOV  R9,R9
       JLT  INTEND
* Return error if buffer size is odd.
       COC  @ONE,R9
       JEQ  INTEND       
* Record empty chunk covering whole
* space.
       MOV  R9,*R8
* Record address of end of buffer.
       A    R9,R8
       MOV  R8,@BUFEND
* Report success.
       CLR  *R13
       RTWP
* Report error.
INTEND SETO *R13
       RTWP
ONE    DATA >0001
 
* 
* **** BUFCPY ****
* Copy data between two locations.
*
* R0 - source address.
* R1 - destination address
* R2 - size of data to copy.
*
* The calling code is responsile for
* ensuring that there is sufficient
* space for the copy.
BUFCPY DATA STRWS,BUFCPY+4
       MOV  *R13,R8
       MOV  @2(13),R9
       MOV  @4(13),R10
*
       BL   @CPYRTN
       RTWP

* Input:
* R8 - source address.
* R9 - destination address
* R10 - size of data to copy.
* Output
* R8-R10,R12
CPYRTN
* If data length is 0, return
       MOV  R10,R10
       JEQ  CPYRT
* Let R12 = size of data to copy
       MOV  R10,R12
* Let R10 = end of source range
       A    R8,R10
* Check if source and destination
* overlap.
       C    R8,R9
       JH   CPYST
       C    R10,R9
       JL   CPYST
* Let R9 = end of destination range
       A    R12,R9
* Copy from end to start
CPY1   DEC  R9
       DEC  R10
       MOVB *R10,*R9
       C    R10,R8
       JH   CPY1
       RT
* Copy from start to end
CPYST  MOVB *R8+,*R9+
       C    R8,R10
       JL   CPYST
CPYRT  RT

* 
* **** BUFALC ****
* Reserve space in the buffer
*
* Input:
* R0 - size
* Output:
* R0 - the new address of assigned space
*    - >FFFF implies an error
BUFALC DATA STRWS,BUFALC+4
* Get routine parameters
       MOV  *R13,R0
*
       BL   @ALCRTN
       MOV  R0,*R13
       RTWP

* Input:
* R0 - size
* Output:
* R0 - the new address of assigned space
*    - >FFFF implies an error
* R1
* R2
* R9
* R10
* R12
ALCRTN
* Round R0 up to an even number.
       INC  R0
       SRL  R0,1
       SLA  R0,1
* Add 2 to space requirement due to
* header size.
       INCT R0
* R0 now contains the required number
* of bytes.
* Find a free chunk of that size or 
* greater.
       MOV  @BUFADR,R1
ALC1   MOV  *R1,R2
       CZC  @BLKUSE,R2
       JEQ  ALC3
       SZC  @BLKUSE,R2
ALC2   A    R2,R1
       C    R1,@BUFEND
       JL   ALC1
* We passed out of the buffer.
* Report an error in caller's R0.
       SETO R0
       RT
* Chunk is free, but is it large enough?
* First try to merge other free chunks.
ALC3   MOV  R11,R12
       BL   @TRYMRG
       MOV  R12,R11
* If required space is still larger than
* the size of merged chunk, continue
* loop.
       C    R0,R9
       JH   ALC2
* This chunk at R1 is large enough.
* Save a copy of its address.
       MOV  R1,R2
* Mark the chunk as used
       SOC  @BLKUSE,*R1
* If the chunk is large enough to split,
* do so.
* Note that it is not possible for R9-R0
* to equal 1. If the difference is not 
* zero, then there is enough space to add
* a chunk header.
       S    R0,R9
       JEQ  ALC4
* Decrease offset at newly filled chunk.
       S    R9,*R1
* Record the remainder of the offset at
* next chunk.
       A    R0,R1
       MOV  R9,*R1
* R2 contains the address of the 
* chunk. Change it to address of chunk
* contents.
ALC4   INCT R2
* R2 now contains the address of the 
* string. Put address in caller's R0.
       MOV  R2,R0
       RT
 
*
* **** BUFREE ****
* Remove an existing chunk from the
* buffer and mark the space as free.
*
* Input:
* R0 - string address inside of buffer
BUFREE DATA STRWS,BUFREE+4
* Get routine parameters
       MOV  *R13,R1
* The block to free is located two bytes
* before the string address.
       DECT R1
* Mark the block free
       SZC  @BLKUSE,*R1
* Merge this newly freed chunk with 
* the following chunk if it is free.
       BL   @TRYMRG
       RTWP

*
* Try Merge Free Space
*
* Input:
* R1 - Address of a free chunk
*
* Output:
* R1 - (unchanged)
* R9 - new size of chunk
* R10 - next full chunk
TRYMRG
* Store the address of first chunk.
       MOV  R1,R10
* Initially add 0 to R10's contents so we
* can ensure that the first chunk is
* really free.
       CLR  R9
* Each header contains an offset to the
* next block. Find the some of the
* offsets of consecutive free blocks.
TMRG1  A    R9,R10
       C    R10,@BUFEND
       JHE  TMGR2
       MOV  *R10,R9
       CZC  @BLKUSE,R9
       JEQ  TMRG1
* Calculate new offset
TMGR2  MOV  R10,R9
       S    R1,R9
       JEQ  TMRG3
* If new offset is greater than 0, put 
* it in header of first chunk.
       MOV  R9,*R1
TMRG3  RT

*
* Shrink allocation to twice the
* required space if not already
* smaller.
*
* Input:
* R0 - address inside of buffer
* R1 - required space
BUFSRK DATA STRWS,BUFSRK+4
* Let R8 = address of block
* Let R9 = required space * 2 + 2
       MOV  *R13,R8
       DECT R8
       MOV  @2(13),R9
       SLA  R9,1
       INCT R9
* Let R10 = current block size
       MOV  *R8,R10
       SZC  @BLKUSE,R10
* Check if too big
       C    R10,R9
       JLE  LESRT
* Mark block header with less space
* Let R10 = spare space
       S    R9,R10
       SOC  @BLKUSE,R9
       MOV  R9,*R8
* Create a new empty block header
       SZC  @BLKUSE,R9
       A    R9,R8
       MOV  R10,*R8
* Merge new free block with later free
* blocks.
       MOV  R8,R1
       BL   @TRYMRG
*
LESRT  RTWP

*
* Grow allocation if necessary.
*
* Input:
* R0 - address of block
* R1 - required size
* Output:
* R0 - new address of block
*
BUFGRW DATA STRWS,BUFGRW+4
* Let R8 = address of block header
* Let R9 = required size + 2
       MOV  *R13,R8
       DECT R8
       MOV  @2(13),R9
       INCT R9
* Let R10 = current block size
       MOV  *R8,R10
       SZC  @BLKUSE,R10
* Check if already big enough      
       C    R10,R9
       JHE  GRWRT
* Let R9 = twice the desired size + 2
       SLA  R9,1
       DECT R9
* Let R11 = address of next block
       MOV  R8,R11
       A    R10,R11
* Confirm that next block is free
       MOV  *R11,R12
       COC  @BLKUSE,R12
       JEQ  GRWNEW
* Let R12 = total size of both blocks
       A    R10,R12
* Confirm that total size is big enough
       C    R12,R9
       JL   GRWNEW
* Grow the original block
       MOV  R9,*R8
       SOC  @BLKUSE,*R8
* Let R12 = new size of free block
       S    R9,R12
* If we used all the free space, return
       JEQ  GRWRT
* Let R8 = address of new free block
       A    R9,R8
* Create new free block
       MOV  R12,*R8
* Merge with following free block
       MOV  R8,R1
       BL   @TRYMRG
       RTWP
* Need to move the data
GRWNEW
* Allocate new block
       MOV  R9,R0
       DECT R0
       BL   @ALCRTN
* Report new block address to caller
       MOV  R0,*R13
* If allocation failed, return to caller
       CI   R0,>FFFF
       JEQ  GRWRT
* Deallocate old block
       SZC  @BLKUSE,*R8
* Merge with following free block
       MOV  R8,R1
       BL   @TRYMRG
* Copy data from old block
       MOV  R0,R9
       MOV  *R8,R10
       INCT R8
       BL   @CPYRTN
*
GRWRT  RTWP

       END
       DEF  ARYALC,ARYADD,ARYINS,ARYDEL
       DEF  ARYADR
*
       REF  BUFALC,BUFREE,BUFCPY,BUFSRK
       REF  BUFGRW
       REF  ARRYWS,BLKUSE

*
* Array format:
*   Word 0: number of items in array
*   Word 1: exponent representing size
*           of each item in the array
*          (1 for 2 bytes,
*           2 for 4 bytes,
*           3 for 8 bytes, etc.)
*   Rest of the memory is a list of
*   items in the array.
*

*
* Allocate space for an array.
* Initially there will be space for
* 8 items.
*
* Input:
* R0 - Size of each item
* Output:
* R0 - address of array
*      >FFFF indicates error
ARYALC DATA ARRYWS,ARYALC+4
* Input of zero is invalid
       MOV  *R13,R0
       MOV  *R13,R3
       JEQ  ALC2
* Get array item size * 4 + 4.
* We'll initially give array space for
* 4 items and the array header
       LI   R2,4
       SLA  R2,0
       C    *R2+,*R2+           Add four to R2
* Allocate space
       MOV  R2,R0
       BLWP @BUFALC
* Handle memory error
       CI   R0,>FFFF
       JEQ  ALC2
* Notify caller of array address
       MOV  R0,*R13
* Declare that the array length is 0
       CLR  *R0+
* Put record item size in bytes 2 and 3.
       MOV  R3,*R0
       RTWP
* Notify caller of error
ALC2   SETO *R13
       RTWP


*
* Add element to end of array.
*
* Input:
* R0 - array address
* Output:
* R0 - address of array
*      >FFFF indicates error
* R1 - address of new item
ARYADD DATA ARRYWS,ARYADD+4
* Let R3 = Insert index
       MOV  *R13,R3
      MOV  *R3,R3
* Use Insert Routine except that insert
* index does not come from the caller.
       B    @INSERT

*
* Insert element into the array.
*
* Input:
* R0 - array address
* R1 - index to insert at
* Output:
* R0 - address of array
*      >FFFF indicates error
* R1 - address of new item
ARYINS DATA ARRYWS,ARYINS+4
       MOV  @2(13),R3
INSERT
* Let R0 = element exponent size
* Let R10 = array address
       BL   @ADRSIZ
* Check for out-of-range index.
       C    R3,*R10
       JH   INSERR
*
       BL   @REALC
       BL   @CPYBCK
* Let caller's R1 = address of new
*   element
INS1   MOV  R0,@2(13)
* Increase length of array
       MOV  *R13,R10
       INC  *R10
       RTWP
* Report out-of-range error
INSERR LI   R8,>FFFE
       MOV  R8,*R13
       RTWP

*
* Remove element from the array.
*
* Input:
* R0 - array address
* R1 - index to delete at
* Output:
* R0 - address of array
*      >FFFF indicates error
ARYDEL DATA ARRYWS,ARYDEL+4
*
       BL   @ADRSIZ
       MOV  R0,R9
* Check for out-of-range index.
       C    @2(13),*R10
       JH   INSERR
* ---- Main delete function ----
* Get address directly after array.
       MOV  *R10,R2
       SLA  R2,0
       A    R10,R2
       C    *R2+,*R2+
* Get destination to copy to.
       MOV  @2(13),R1
       SLA  R1,0
       A    R10,R1
       C    *R1+,*R1+
* Get source to copy from.
       LI   R8,1
       SLA  R8,0
       MOV  R1,R0
       A    R8,R0
* Get length to copy
       S    R1,R2
*
       BLWP @BUFCPY
* Decrease array length
       DEC  *R10
*
* ---- Adjust memory block size ----
* Get new memory size of the array in R1.
* Calc: array length * Item size + 4
       MOV  R9,R0
       MOV  *R10,R1
       SLA  R1,0
       C    *R1+,*R1+
* Let R0 = address of array
       MOV  *R13,R0
* Shrink memory allocation if needed
       BLWP @BUFSRK
*
       RTWP


*
* Get index address
*
* Input:
* R0 - array address
* R1 - index of item
* Output:
* R1 - address of item
ARYADR DATA ARRYWS,ARYADR+4
       BL   @ADRSIZ
       MOV  @2(13),R8
       SLA  R8,0
       A    R10,R8
       C    *R8+,*R8+
       MOV  R8,@2(13)
       RTWP

*
* Get address of array and exponent of
* size of each item.
*
* Output:
*  R0 - exponent for item size
*  R10 - address of array
ADRSIZ
* First get address of array
       MOV  *R13,R10
* Get memory size of array item
       MOV  R10,R9
       INCT R9
       MOV  *R9,R0
       RT

*
* Check if it is necessary to move the
* array to an area of a larger size.
*
* Input:
*  R0 - exponent for item size
*  R10 - address of array
* Output:
*  R0, R1, R2, R3
*  R9 - exponent for item size
*  R10 - new address of array
REALC
* Continue to store item size in R9
       MOV  R0,R4
*
* Get potential size of array after add.
* Put in R2
* Calc: (array length + 1) * Item size + 4
       MOV  *R10,R2
       INC  R2
       SLA  R2,0
       C    *R2+,*R2+
*
* Grow the memory block if necessary.
       MOV  R10,R0
       MOV  R2,R1
       BLWP @BUFGRW
*
       MOV  R4,R9
* Report new address to caller
       MOV  R0,*R13
       MOV  R0,R10
* If error, leave workspace routine.
       CI   R0,>FFFF
       JEQ  RTERR
*
REALC2 RT
*
RTERR  RTWP


*
* Copy part of memory backwards.
* The insertion algorithm needs this.
*
* Input:
*  R3 - index at witch to insert
*  R9 - exponent for item size
*  R10 - address of array
*  R13 - caller's workspace
* Output:
*  R0
*  R1 - Address of insertion index
*  R2,R3,R4,R7,R8
CPYBCK
* R0 must have memory size of item
       MOV  R9,R0
* Let R2 = size of array
       MOV  *R10,R2
       SLA  R2,0
       C    *R2+,*R2+
* Let R1 = length of each element
       LI   R1,1
       SLA  R1,0
* Let R0 = offset of insert element
* from array start
       SLA  R3,0
       C    *R3+,*R3+
       MOV  R3,R0
* Let R2 = number of bytes to move
       S    R0,R2
* Let R0 = address of insert element
       A    R10,R0
* Let R1 = address of following element
       A    R0,R1
*
       BLWP @BUFCPY
*
       RT

       END
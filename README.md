# Editor/Assembler Memory Management

This repository contains utility routines to help you manage memory within an Editor/Assembler program developed for a TI-99/4A computer or a TMS9900 microprocessor.
The routines allow the calling code to allocate memory areas of various length, and mark these memory areas as free or change their size.
There are also routines that allow calling code to manage arrays.
I wrote this code after learning how malloc is implemented in C, but it is not identical to malloc.

## Including this library in your own program

The assembled object files of a given relase are at this link (https://github.com/bkrug/TI-string-buffer/releases).
They are available on a Disk Image, in FIAD (File in a disk) format with TIFILES headers, or in files without a TIFILES header.

Use the *.NOHEADER.obj files if you plan to assemble your program from Windows or Linux with something like XDT99.

Use the *.obj files with the TIFILE headers or the disk image, if you plan to assemble your program from a TI-99 emulator.

Object files:
* VAR.obj contains only memory locations for variables, including space for workspace registers.
* MEMBUF.obj contain only static executable object code. It is dependent on VAR.obj
* ARRAY.obj contains only static executable object code. It is dependent on VAR.obj and MEMBUF.obj

Static and volatile object code are kept separate in case the larger project requires code to be located in ROM.

## Example Code

See the unit tests for more complete documentation, but here is the general idea.

           DEF  BUFINT,BUFALC,BUFFREE
           DEF  BUFSRK,BUFGRW
           .
           .
    STRNG1 BSS  2
    STRNG2 BSS  2
    STRNG3 BSS  2
    SPACE  EQU  >E000
           .
           .
    * Mark 4 KB at address SPACE (>E000) as an area where memory blocks can be allocated an deallocated.
    * A buffer must be initialized before any memory is dynamically allocated.
           LI   R0,SPACE
           LI   R1,>1000
           BLWP @BUFINT

    * Allocate >220 bytes of memory, and store the address at STRNG1
           LI   R0,>220
           BLWP @BUFALC
           MOV  R0,@STRNG1

    * Allocate >2E bytes of memory, and store the address at STRNG2
           LI   R0,>2E
           BLWP @BUFALC
           MOV  R0,@STRNG2

    * Allocate >80 bytes of memory, and store the address at STRNG3
           LI   R0,>80
           BLWP @BUFALC
           MOV  R0,@STRNG3

    * The data stored at the address stored in STRNG2 is no longer needed.
    * Deallocate the space so that it may be used for other data.
           MOV  @STRNG2,R0
           BLWP @BUFREE

    * There is less data stored at the address in STRNG3 now.
    * Reduce the reserved size in case some other part of the program can use it.
           MOV  @STRNG3,R0
           LI   R1,>2C
           BLWP @BUFSRK

    * More space is required for the data at the address in STRNG3.
    * Reserve more space.
    * The BUFGRW routine may need to move the data in order to find enough space.
    * So re-store the address in R0 in STRNG3, regardless of whether the address changed or not.
           MOV  @STRNG3,R0
           LI   R1,>F8
           BLWP @BUFGRW
           MOV  R0,@STRNG3

Note that the BUF routines don't do anything magical to prevent a different routine from overwriting data.
Your program is expected to not write anything between addresses >E000 and >EFFF unless it is using a memory address acquired from BUFALC or BUFGRW.

Errors can be handled as follows.

    * If there is not enough space to allocate another kilobyte,
    * The value >FFFF will be stored in R0
           LI   R0,>400
           BLWP @BUFALC
           CI   R0,>FFFF
           JEQ  GOTERR

    * But checking the contents of R0 is optional.
    * The BUF and ARY routines will also set the EQ bit when they detect an error.
    * This code has the same result.
           LI   R0,>400
           BLWP @BUFALC
           JEQ  GOTERR

    * ARYINS has two possible errors.
    * A program has the option of handling them differently.
    *
    * This code tries to insert an element at index 37 of some array.
    * >FFFF indicates insufficient memory.
    * >FFFE indicates that the array is not large enough to have such an index
           MOV  @MYARRY,R0
           LI   R1,37
           BLWP @BUFALC
           CI   R0,>FFFF
           JEQ  MEMERR
           CI   R1,>FFFE
           JEQ  IDXERR


## Routines

### MEMBUF Routines

#### BUFINT
```
Input:
R0 - buffer memory address
R1 - buffer size (>4 to >7FFE valid)
Output:
R0 - >0000 if successful
     >FFFF if error
```

Reserves an exact amount of space as a memory buffer.
Call BUFINT once at the beginning of your program.
It is distinct from BUFALC which may be called multiple times.

The buffer size in R1 must be an even number from >4 to >7FFE.
If the output value is >FFFF, then the calling code placed an invalid value in R1.

#### BUFALC
```
Input:
R0 - number of bytes required for a memory block
Output:
R0 - address of the allocated memory.
     >FFFF if insufficient space
```

Finds a location in the memory buffer large enough for the requested block size.
The address returned in R0 will always be inside the area reserved by BUFINT.

If you attempt to allocate an odd number of bytes, BUFALC will round up to the next even number.

#### BUFREE
```
Input:
R0 - address of previously allocated block
```

Marks a previously allocated block of memory as free.
A future call to BUFALC or BUFGRW may reserve this space for a different memory block.
After calling BUFREE, your program should not attempt to write to that allocation any more.

#### BUFSRK
```
Input:
R0 - address of previously allocated block
R1 - required space
```

Conditionally shrinks the size of a previously allocated memory block.
If the required space less than half as big as the current allocation, the memory block is shrunk.
Otherwise the routine does nothing.
This routine never moves an allocated block.

#### BUFGRW
```
Input:
R0 - address of previously allocated block
R1 - required size
Output:
R0 - new address of block
     >FFFF if insufficient space
```

Conditionally grows the size of a previously allocated memory block.
If the current block size is already equal to or larger than the requested size, then the routine does nothing.
Otherwise, the routine reserves twice as much space as the requested amount.

The block address may need to move as a result of the grow opperation.
If that happens, the new address will be output to R0.
The contents from the old block will be copied to the new block.
The old block will be marked as free.

#### BUFCPY
```
Input:
R0 - source address.
R1 - destination address
R2 - size of data to copy.
```

Copies several bytes of memory from the source address to the destination address.
The routine copies bytes, not words of memory.

It is alright for memory addresses to be odd numbers.

It is alright for the size to be an odd number.

It is alright for the source and destination blocks to overlap, for example, when deleting or inserting a character in a string.

### ARRAY Routines

#### ARYALC
```
Input:
R0 - Exponent for the size of each element
Output:
R0 - address of array
     >FFFF if insufficient space 
```

Allocates space for an array.
The allocated space will be in the buffer reserved by BUFINT.

Each element in the array will have a length that is equal to a power of two.
If R0 contains "1", each element will be 2 bytes long.
If R0 contains "2", each element will be 4 bytes long.
If R0 contains "3", each element will be 8 bytes long.
If R0 contains "4", each element will be 16 bytes long.
etc.

#### ARYADD
```
Input:
R0 - array address
Output:
R0 - new address of array
     >FFFF if insufficient space 
R1 - address of new item
```

Increases the array size by one element.
Reports the address of the new element in R1.
The array may have moved as a result of growing.
The new address is reported in R0.

#### ARYINS
```
Input:
R0 - array address
R1 - index to insert at
Output:
R0 - new address of array
     >FFFF if insufficient space 
     >FFFE if index is out of range
R1 - address of new item
```

Inserts a new element in the array.
The array size increases by one element, and the contents of part of the array are moved.
Reports the address of the new element in R1.
The array may have moved as a result of growing.
The new address is reported in R0.

#### ARYDEL
```
Input:
R0 - array address
R1 - index of element to delete
Output:
R0 - >FFFE if index is out of range
     unchanged otherwise
```

Deletes an element in the array.
The array size decreases by one element, and the contents of part of the array are moved.

#### ARYADR
```
Input:
R0 - array address
R1 - index of desired element
Output:
R1 - address of element
     >FFFE if index is out of range
```

Gets the address of a particular element within an array.

## Running Unit Tests

To run unit tests in this project:
1. Run assm.py
2. Pick a file from the "Fiad" folder.
3. Load the Editor/Assembler cartridge
4. Select E/A menu option #3
5. Enter the file you picked.
6. Enter RUNTST as the program to run.
7. Several tests and their results will appear on the screen.

## Release versioning.

Object files in each release contain a comment specifying the version number.

## Files in the Repo

### MEMBUF

MEMBUF.TXT contains the source code for the module.

MEMTST.TXT contains the source code for some unit tests.

### ARRAY

ARRAY.TXT - a set of routines for managing arrays in Assembly.
All arrays have elements whose size is a power of two (2,4,8,16, ...).
The routines allow you to insert, add, or delete items.
You can also get the address of an item with a given index.

ARRYTST.TXT - Array tests

### MISC

VAR.TXT - Contains memory addresses that are to contain values that could change.

TESTFRAM.TXT is utility code that the unit tests need.

assm.py - A python script to reassemble all of the source code. Requires xdt99.

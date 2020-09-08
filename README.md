# Editor/Assembler Memory Management

This repository contains utility routines to help you manage memory within an Editor/Assembler program developed for a TI-99/4A computer or a TMS9900 microprocessor.
The routines allow the calling code to allocate memory areas of various length, and mark these memory areas as free or change their size.
There are also routines that allow calling code to manage arrays.
I wrote this code after learning how malloc is implemented in C, but it is not identical to malloc.

## Including this library in your own program

The assembled object files of a given relase are at this link (https://github.com/bkrug/TI-string-buffer/releases).
They are available on a Disk Image or in FIAD (File in a disk) format with TIFILES headers.

Object files:
* MEMBUF.O contain only static executable object code.
* ARRAY.O contains only static executable object code. It is dependent on MEMBUF.O
* VAR.O contains only memory locations for variables, including space for workspace registers.

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
           LI   R0,SPACE
           LI   R1,>1000
           BLWP @BUFINT
           
           LI   R0,>220
           BLWP @BUFALC
           MOV  R0,@STRNG1
           
           LI   R0,>2E
           BLWP @BUFALC
           MOV  R0,@STRNG2
           
           LI   R0,>80
           BLWP @BUFALC
           MOV  R0,@STRNG3
           
           MOV  @STRNG2,R0
           BLWP @BUFREE
           
           MOV  @STRNG3,R0
           LI   R1,>2C
           BLWP @BUFSRK
           
           MOV  @STRNG3,R0
           LI   R1,>F8
           BLWP @BUFGRW
           MOV  R0,@STRNG3

In the above example, BUFINT marked 4 KB at address SPACE (>E000) as an area where memory blocks can be allocated an deallocated.

The code snippet allocated >220 bytes of memory.
The BUFALC routine reported the address of the allocated memory in R0.
The code snipped stored this allocated address at address STRING1.

It allocated >2E bytes of memory, but later deallocated that memory block using the BUFREE routine.

At one point, the code allocated >80 bytes of memory and stored the address at STRNG3.
Later the code used BUFSRK and BUFGRW to change the reserved memory block size.
BUFGRW may have needed to move the memory block when it grew, so the address was re-saved in STRNG3.
BUFGRW will copy block contents to the new location when it needs to move a block.

Note that the BUF routines don't do anything magical to prevent a different routine from overwriting data.
Your program is expected to not write anything between addresses >E000 and >EFFF unless it is using a memory address acquired from BUFALC or BUFGRW.

## Routines

### MEMBUF Routines

BUFINT
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

BUFALC
```
Input:
R0 - number of bytes required for a memory block
Output:
R0 - address of the allocated memory.
     >FFFF if error
```

Finds a location in the memory buffer large enough for the requested block size.
The address returned in R0 will always be inside the area reserved by BUFINT.

If you attempt to allocate an odd number of bytes, BUFALC will round up to the next even number.

BUFREE
```
Input:
R0 - address of previously allocated block
```

Marks a previously allocated block of memory as free.
A future call to BUFALC or BUFGRW may reserve this space for a different memory block.
After calling BUFREE, your program should not attempt to write to that allocation any more.

## Running Unit Tests

To run unit tests in this project:
1. Choose a source file whose name ends "LOAD.asm"
2. Read the list of files inside of the source file.
3. Assemble "~LOAD.asm" and all of the files mentioned in the list.
(a) If your object code is not going to be located in DSK2, edit the file list in ~LOAD.asm to reflect the correct location.
(b) Assemble the code such that the object code has an extension of .O but is otherwise named the same as the source.
4. Select E/A menu option #3
5. Enter ~LOAD.obj as the file to load.
6. Enter LTEST as the program to run.
7. As list of files will be displayed on the screen as they are loaded. Then the tests will run. You sould see the messages 'Testing' and 'Done' if all tests pass. Otherwise you should see a message for the first failing test.

## Release versioning.

Object files in each release contain a comment specifying the version number.

## Files in the Repo

### MEMBUF

MEMBUF.TXT contains the source code for the module.

MEMTST.TXT contains the source code for some unit tests.

MEMLOAD.TXT loads object code to run unit tests on MEMBUF

### ARRAY

ARRAY.TXT - a set of routines for managing arrays in Assembly.
All arrays have elements whose size is a power of two (2,4,8,16, ...).
The routines allow you to insert, add, or delete items.
You can also get the address of an item with a given index.

ARRYTST.TXT - Array tests

ARRYLOAD.TXT - Loads and runs array tests and their dependencies.

### MISC

VAR.TXT - Contains memory addresses that are to contain values that could change.

TESTFRAM.TXT is utility code that the unit tests need.

LOADTSTS.TXT contains a script to load an run an aribtraty list of object code files.

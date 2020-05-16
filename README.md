# Editor/Assembler Memory Management

This repository contains utility routines to help you manage memory within an Editor/Assembler program developed for a TI-99/4A computer or a TMS9900 microprocessor. This was written with the idea that a program might create, delete, or change several different strings of data, and that they might all be of different lengths. I wrote this code after learning how malloc is implemented in C, but it is not identical to malloc.

## Including this library in your own program

Download the object files listed in a particular release (https://github.com/bkrug/TI-string-buffer/releases) and copy them to the disk that contains your own program.
Object files in the release have the .O extension.

ARRAY.O and MEMBUF.O only contain executable object code. 
VAR.O contains only memory locations for variables, including space for workspace registers.
You may wish to re-assemble VAR.TXT instead of using the included VAR.O.
That way you can place workspace registers in a part of the TI's scratch pad RAM that you do not use.

Note that ARRAY.O is dependent on MEMBUF.O.

## Tutorial

See the unit tests for more complete documentation, but here is the general idea.

BUFINT initializes initializes a chunk buffer.
The buffer is able to contain many different areas of memory allocated at different sizes.
The below code initilizes a buffer with 4KB of space and allocates two chunks of different sizes.
The addresses are then stored at STRING1 and STRING2 so that a different part of the program can then populate the chunk with an appropriate amount of data.
If there is an error, such as insufficient memory, BUFINT or BUFALC would place >FFFF in R0.

           DEF  BUFINT,BUFALC
           .
           .
    SPACE  EQU  >E000
           .
           .
           LI   R0,SPACE
           LI   R1,>1000
           BLWP @BUFINT
           
           LI   R0,219
           BLWP @BUFALC
           MOV  R0,@STRNG1
           
           LI   R0,18
           BLWP @BUFALC
           MOV  R0,@STRNG2

In the below example, a string of text was originally allocated with space for 18 characters.
The program later gives the user the chance to type a longer string.
Assume that there is an area of memory which holds a string as the user is typing.
This area can be at address TYPESP.
This area gets used for user input over and over again, and is not meant to store text for the entire program runtime.
The following code will:
* copy the original string from the chunk buffer to the user-input address of TYPESP.
* free up the original memory location
* allocate space for the longer string
* copy the new string into the chunk buffer at the allocated location.

           *R0 holds a copy-from address.
           *R1 holds a copy-to address.
           *R2 holds the number of bytes to copy. 
           *Here we assume that R4 somehow contains the length of the original string.
           *In a real program, perhaps the first byte or word of the memory chunk would store the string length.
           MOV  @STRNG2,R0
           LI   R1,TYPESP
           MOV  R4,R2
           BLWP @BUFCPY
           .
           .
           
           *Later some logic determines that the new user input is longer
           MOV  @STRNG2,R0
           BLWP @BUFREE
           
           *The new string length is in R7 somehow.
           MOV  R7,R0
           BLWP @BUFALC
           MOV  R0,@STRNG2
           
           * Note that BUFCPY is just copying between memory addresses.
           * It doesn't really care if either address is part of the chunk buffer or not.
           LI   R0,TYPESP
           MOV  @STRNG2,R1
           MOV  R7,R2
           BLWP @BUFCPY


## Routines

Below is a list of the routines that are defined in this library.
They can be called using BLWP.
See MEMBUF.TXT and ARRAY.TXT to see which registers are used for input and output in the routine.

The buffer code allows the caller to allocate a given amount of space in the addressable RAM. The memory allocated to the buffer cannot be changed in size, but any stream of data within the buffer can be deleted or moved if space requirements change.

BUFINT
Allocates a certain amount of memory in the range of 4 to >8000 bytes (must be an even number).

BUFALC
Allocates copies a chunk of data from some source location (usually outside the buffer) into the buffer, reserving the specified amount of space

BUFCPY
Copies a chunk of memory from one location inside of the bugger to a location (likely outside of the buffer).

BUFREE
Marks a used chunk of memory as free.

ARYALC
Allocates space for an array.

ARYADD
Adds elements to the end of the array

ARYINS
Inserts elements into the array

ARYDEL
Removes an element from the array

ARYADR
Reports the address of an array element with a given index

## Running Unit Tests

To run unit tests in this project:
1. Choose a source file whose name ends "LOAD.TXT"
2. Read the list of files inside of the source file.
3. Assemble "~LOAD.TXT" and all of the files mentioned in the list.
(a) If your object code is not going to be located in DSK2, edit the file list in ~LOAD.TXT to reflect the correct location.
(b) Assemble the code such that the object code has an extension of .O but is otherwise named the same as the source.
4. Select E/A menu option #3
5. Enter ~LOAD.TXT as the file to load.
6. Enter LTEST as the program to run.
7. As list of files will be displayed on the screen as they are loaded. Then the tests will run. You sould see the messages 'Testing' and 'Done' if all tests pass. Otherwise you should see a message for the first failing test.

## Files in the Repo

### MEMBUF

MEMBUF.TXT contains the source code for the module.

BUFTST.TXT contains the source code for some unit tests.

BUFLOAD.TXT loads object code to run unit tests on MEMBUF

### ARRAY

ARRAY.TXT - a set of routines for managing arrays in Assembly.
All arrays have elements whose size is a power of two (2,4,8,16, ...).
The routines allow you to insert, add, or delete items.
You can also get the address of an item with a given index.

ARRYTST.TXT - Array tests

ARRYLOAD.TXT - Loads and runs array tests and their dependencies.

### MISC

VAR.TXT - Contains memory addresses that are to contain values that could change.

TESTUTIL.TXT is utility code that the unit tests need.

LOADTSTS.TXT contains a script to load an run an aribtraty list of object code files.

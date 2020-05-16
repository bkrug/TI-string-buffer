# Editor/Assembler Memory Management

This repository contains utility routines to help you manage memory within an Editor/Assembler program developed for a TI-99/4A computer or a TMS9900 microprocessor. This was written with the idea that a program might create, delete, or change several different strings of data, and that they might all be of different lengths. I wrote this code after learning how malloc is implemented in C, but it is not identical to malloc.

## Routines

The buffer code allows the caller to allocate a given amount of space in the addressable RAM. The memory allocated to the buffer cannot be changed in size, but any stream of data within the buffer can be deleted or moved if space requirements change.

BUFINT
Allocates a certain amount of memory in the range of 4 to >8000 bytes (must be an even number).

BUFALC
Allocates copies a chunk of data from some source location (usually outside the buffer) into the buffer, reserving the specified amount of space

BUFGET
Copies a chunk of memory from one location inside of the bugger to a location (likely outside of the buffer).

BUFREE
Marks a used chunk of memory as free.

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

MEMBUF.TXT contains the source code for the module. This is the only file you would need if using this module in a larger program.

BUFTST.TXT contains the source code for some unit tests.

BUFLOAD.TXT loads object code to run unit tests on MEMBUF

### ARRAY

ARRAY.TXT - a set of routines for managing arrays in Assembly.
All arrays have items whose size is a power of two (2,4,8,16, ...).
The routines allow you to insert, add, or delete items.
You can also get the address of an item with a given index.
These routines depend upon MEMBUF.TXT

ARRYTST.TXT - Array tests

ARRYLOAD.TXT - Loads and runs array tests and their dependencies.

### MISC

VAR.TXT - Contains memory addresses that are to contain values that could change.

TESTUTIL.TXT is utility code that the unit tests need.

LOADTSTS.TXT contains a script to load an run an aribtraty list of object code files.

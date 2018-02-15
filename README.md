# Editor/Assembler Memory Management

This repository contains utility routines to help you manage memory within an Editor/Assembler program developed for a TI-99/4A computer or a TMS9900 microprocessor. This was written with the idea that a program might create, delete, or change several different strings of data, and that they might all be of different lengths. I wrote this code after learning how malloc is implemented in C, but it is not identical to malloc.

* MEMBUF.TXT contains the source code for the module. This is the only file you would need if using this module in a larger program.
* BUFTST.TXT contains the source code for some unit tests.
* TESTUTIL.TXT is utility code that the unit tests need.
* LBUFTST.TXT loads assembled versions of the above three files into memory without requiring you to type each file name.

The buffer code allows the caller to allocate a given amount of space in the addressable RAM. The memory allocated to the buffer cannot be changed in size, but any stream of data within the buffer can be deleted or moved if space requirements change.

BUFINT
Allocates a certain amount of memory in the range of 4 to >8000 bytes (must be an even number).

BUFALC
Allocates copies a chunk of data from some source location (usually outside the buffer) into the buffer, reserving the specified amount of space

BUFGET
Copies a chunk of memory from one location inside of the bugger to a location (likely outside of the buffer).

BUFREE
Marks a used chunk of memory as free.

The compiled code uses 230 bytes of memory.

If you wish to run unit tests on the code, assemble all three source files, load them through E/A option 3, and run RUNTST.
The source files end with the .TXT extension because that seems to be a requirement for my preference of editing the source in NOTEPAD++ and assemblying in the Classic99 emulator.

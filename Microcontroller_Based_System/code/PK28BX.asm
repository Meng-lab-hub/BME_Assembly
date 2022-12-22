; -----------------------------------------------------------
; Microcontroller Based Systems Homework
; -------------------------------------------------------------------
; Task description: 
;   Search for the largest element in a number sequence (array) stored in the internal memory. 
;   Every element is an 8 bit unsigned integer.
;   Inputs: Start address of the array (pointer), number of elements
;   Output: Largest element in a register
; -------------------------------------------------------------------
; Definitions
; -------------------------------------------------------------------
; Address symbols for creating pointers
ARRAY_LEN  EQU 16
ARRAY_ADDR_IRAM  EQU 0x40
; Test data for input parameters
; (Try also other values while testing your code.)
; Store numbers (bytes) in the code memory as an array
ORG 0x0070 ; Move if more code memory is required for the program code
ARRAY_ADDR_CODE:
DB 0x00, 0x01,  0x7F, 0x80,  0x55, 0xAA,  0x00, 0xCC,  0x00, 0x12,  0x12, 0x33,  0x55, 0xAA,  0x42, 0x34
; Interrupt jump table
ORG 0x0000;
    SJMP  MAIN                  ; Reset vector
; Beginning of the user program, move it freely if needed
ORG 0x0010
; -------------------------------------------------------------------
; MAIN program
; -------------------------------------------------------------------
; Purpose: Prepare the inputs and call the subroutines
; -------------------------------------------------------------------
MAIN:
    ; Prepare input parameters for the subroutine
	MOV R4,#HIGH(ARRAY_ADDR_CODE)
	MOV R5,#LOW(ARRAY_ADDR_CODE)
	MOV R6,#ARRAY_ADDR_IRAM
	MOV R7,#ARRAY_LEN
	CALL CODE2IRAM ; Copy the array from code memory to internal memory
	
	MOV R6, #ARRAY_ADDR_IRAM ;Base address of the number array in the internal memory moved to R6
	MOV R7, #ARRAY_LEN ;Array length constant vale moved to R7
; Infinite loop: Call the subroutine repeatedly
LOOP:
    CALL FIND_MAX_NUMBER ; Call Find max number subroutine
    SJMP  LOOP
; ===================================================================      
;                           SUBROUTINE(S)
; ===================================================================      ; -------------------------------------------------------------------
; CODE2IRAM
; -------------------------------------------------------------------
; Purpose: Copy the number array from code memory to internal memory
; -------------------------------------------------------------------
; INPUT(S):
;   R4 - Base address of the number array in code memory - HIGH byte
;   R5 - Base address of the number array in code memory - LOW byte
;   R6 - Base address of the number array in the internal memory
;   R7 - Number array size (in bytes)
; OUTPUT(S): 
;   The array is copied from code memory to internal memory using indexed addressing mode of DPTR
; MODIFIES:
;   DPH, DPL, A, R2, DPTR, R0,R3
; -------------------------------------------------------------------
CODE2IRAM:
; [TODO: Place your code here]
	MOV DPH,R4 ; Highorder base address of array
	MOV DPL,R5 ; Loworder base address of array
	MOV A,R6   ; Base address of the number array in the internal memory is moved to A to use later after getting elements of array using indexed addressing mode
	MOV R0,A   ;Base address of the number array in the internal memory is moved to A to use later after getting elements of array using indexed addressing mode

	MOV A,R7    ;Array size is being stored in Acc.
	MOV R2,A	;Array size is being stored to R2 to be used later when R7 gets updated at end of loop
	
TOP:	CLR A	;Clear Acc. register
	MOVC A,@A+DPTR ; Move one byte from code memory to Accumulator
	MOV @R0,A ; Move from Accumulator to Inernal memory pointed by R0
	INC DPTR ; Point to next byte location in Code momory
	INC R0 ; Point to next byte location in Intenal memory
	DJNZ R7,TOP ; Decrement ArraySize counter, and if not zero jump to TOP
	
	RET ; Return to Main
; -------------------------------------------------------------------
; FIND_MAX_NUMBER
; -------------------------------------------------------------------
; Purpose: Find the maximum number (byte) in the array
; -------------------------------------------------------------------
; INPUT(S):
;   R6 - Base address of the number array in the internal memory
;   R7 - Array size (in bytes)
; OUTPUT(S): 
;   Maximum element is stored at address 60H in internal memory.
; MODIFIES:
;   A, R0, R3,
; -------------------------------------------------------------------
FIND_MAX_NUMBER:
; [TODO: Place your code here]
	MOV A,R6	; Base address of the number array in the internal memory is moved to A
	MOV R0,A ;Base address of the number array in the Acc. is moved to R0
	MOV A,@R0 ; Get the byte whose address is pointed by R0 from internal memory in Accumulator
	MOV A,R2	;Array size is being moved to A
	MOV R7,A	;Array size is being moved to R7 so as to initiate R7 with given array size at the begining whenever FIND_MAX_NUMBER subroutine is called
BACK:	INC R0 ; Point to next byte in internal memory
	MOV B,@R0 	; move the array element at next byte in memory to register B, so for comparing Acc. and B
	CJNE A,B,L1 ; Compare Acc. and byte in register B and if not equal goto L1
L1:	JNC L2 ; if Accumuator is greater then jump to L2
	MOV A,B ; else bring the bigger number in register B to Acc
L2:	DJNZ R7,BACK  ;Decrement ArraySize counter, and if not zero go to Back
	MOV 60H,A ;MOve the largest element in array to internal memory address  60H
	RET ; Return to Main
; [TODO: You can also create other subroutines if needed.]
; End of the source file
END
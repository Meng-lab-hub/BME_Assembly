; -----------------------------------------------------------
; Microcontroller Based Systems Homework
; Author name: Kormoua Khongmeng
; Neptun code: I3MLPQ
; -------------------------------------------------------------------
; Task description: 
;   Search for the largest element in a number sequence (array) stored in the code memory. 
;   Every element is an 8 bit unsigned integer.
;   Inputs: Start address of the array (pointer), number of elements
;   Output: Largest element in a register
; -------------------------------------------------------------------


; Definitions
; -------------------------------------------------------------------

; Symbols for creating pointers

ARRAY_LEN  EQU 16

; Test data for input parameters
; (Try also other values while testing your code.)

; Store numbers (bytes) in the code memory as an array

ORG 0x0070 ; Move if more code memory is required for the program code
ARRAY_ADDR_CODE:
DB 0x11, 0x22,  0x33, 0x44,  0x12, 0x35,  0x12, 0x12,  0x34, 0x00,  0x34, 0x12,  0x55, 0x12,  0x12, 0x34

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
	
	MOV R7, #ARRAY_LEN
	MOV DPTR ,#ARRAY_ADDR_CODE
		
; Infinite loop: Call the subroutine repeatedly
LOOP:

    CALL FIND_MAX_NUMBER ; Call Find max number subroutine

    SJMP  LOOP




; ===================================================================           
;                           SUBROUTINE(S)
; ===================================================================           


; -------------------------------------------------------------------
; FIND_MAX_NUMBER
; -------------------------------------------------------------------
; Purpose: Find the largest byte in an array
; -------------------------------------------------------------------
; INPUT(S):
;   DPTR - Base address of the number array in code memory (16 bits)
;   R7 - Number array size (in bytes)
; OUTPUT(S): 
;   R3 - Value of the maximal element
; MODIFIES:
;   R3
; -------------------------------------------------------------------

FIND_MAX_NUMBER:

    ; [TODO: Place your code here]

        PUSH AR2                ; Save all the contents of each register to the stack first
        PUSH AR4                ; | in this way, the subroutine will only modify the register
        PUSH AR5                ; | as least as possible, theoritically only the register that
        PUSH AR6                ; | is kept the output will be modified.
        PUSH AR7                ; |
        PUSH PCON               ; |
        PUSH IE                 ; |
        PUSH IP                 ; |
        PUSH PSW                ; |
        PUSH ACC                ; |
        PUSH B                  ; |
        PUSH DPH                ; |
        PUSH DPL                ; |

        CLR A                   ; Read first element which for now is the biggest element.
        MOVC A, @A+DPTR         ; | in this case is R3. we will use this as the first element 
        MOV R3, A               ; | to compare with the rest of the array 

        INC DPTR                ; Move the pointer to the next element since the first element 
                                ; | is already copied.
        DEC R7                  ; One of the element has been copied care of so decrement the
                                ; | size of the element left in the array

    SUBROUTINELOOP:

        CLR A                   ; Read the next element to be compare from the array
        MOVC A, @A+DPTR         ; |

        MOV R4, A               ; This method will substract the new element from the
        MOV A, R3               ; | biggest element that we have so far, so I need to 
        SUBB A, R4              ; | put the biggest element so far to A, and the new element  
                                ; | to another register, in this case R4

        JC NEWVALUEISBIGGER       ; For substraction method, if the new value is bigger a carry
                                ; | flag will be set, so we know that we got a new value the 
                                ; | biggest value now
        JMP NEWVALUEISLESS

    NEWVALUEISBIGGER:

        MOV B, R4               ; Copy the new value that is bigger than the current biggest
        MOV R3, B               ; | value to R3 which is a register that we use to store 
                                ; | the biggest value from the array. since a direct move 
                                ; | between register is not possible so I use B as a 
                                ; | temporary register to transfer between them

    NEWVALUEISLESS:

        INC DPTR                ; Move the pointer to the next element since the first element 
                                ; | is already been taken care of

        DJNZ R7, SUBROUTINELOOP ; Check if there is still remaining element left in the array
                                ; | to compare with or not if yes then go back to the 
                                ; | subroutine loop


        POP DPL                 ; At this point, all of the process and functionallity of
        POP DPH                 ; | the subroutine is done. one last thing to do is to 
        POP B                   ; | load back the content of register before the program
        POP ACC                 ; | call the subroutine back to its register respectively.
        POP PSW                 ; | Note that, in order to save back the content of register
        POP IP                  ; | correctly, the program must read back in the reverse order
        POP IE                  ; | to the order when the program save these data.
        POP PCON                ; | 
        POP AR7                 ; |
        POP AR6                 ; |
        POP AR5                 ; |
        POP AR4                 ; |
        POP AR2                 ; |

        RET                     ; Return from this subroutine back to where this was called

    ; [TODO: You can also create other subroutines if needed.]



; End of the source file
END


      ; -----------------------------------------------------------
      ; Microcontroller Based Systems Homework
      ; Author name: Daoud Maged Hosni Bahnam
      ; Neptun code: I9XF28
      ; -------------------------------------------------------------------
      ; Task description: 
      ;   Square of a 16 bit signed integer passed through registers. 
      ;   The result should be a 32 bit signed integer.
      ;   Input: The number in 2 registers,  result address (pointer)
      ;   Output: Result starting at the given address
      ; -------------------------------------------------------------------
       
       
      ; Definitions
      ; -------------------------------------------------------------------
       
      ; Address symbols for creating pointers
       
      OUTPUT_ADR  EQU 0x40
       
      ; Test data for input parameters
      ; (Try also other values while testing your code.)
       
      ; Input 1: -300 (Hexadecimal: 0xFED4)
      INPUT_H     EQU 0xFE    ; High byte
      INPUT_L     EQU 0xD4    ; Low byte
       
      ; Interrupt jump table
      ORG 0x0000;
     SJMP  MAIN                  ; Reset vector
       
      ; Beginning of the user program
      ORG 0x0033
             
            ; -------------------------------------------------------------------
            ; MAIN program
            ; -------------------------------------------------------------------
            ; Purpose: Prepare the inputs and call the converter subroutines
            ; -------------------------------------------------------------------
             
            MAIN:
             
                ; Prepare input parameters for the subroutine
                ; Here I have exchanged R1 to output , because I need to point to the beginning address of the result with the register, and it is only possible with R0 and R1
             
      MOV R0, #INPUT_H        ; Input parameter 1 high byte
      MOV R2, #INPUT_L        ; Input parameter 1 low byte
             
     MOV R1, #OUTPUT_ADR     ; Input parameter 2 (address of output)
             
            ; Infinite loop: Call the subroutine repeatedly
            LOOP:
             
     CALL SQR_S16
             
      SJMP  LOOP
             
             
             
             
            ; ===================================================================           
            ;                           SUBROUTINE(S)
            ; ===================================================================           
             
             
            ; -------------------------------------------------------------------
            ; SQR_S16
            ; -------------------------------------------------------------------
            ; Purpose: Square of a 16-bit signed integer
            ; -------------------------------------------------------------------
            ; INPUT(S):
            ;   R0 - Input operand high byte
            ;   R2 - Input operand low byte
            ;   R1 - Address of 32-bit result (big endian: high byte to low address)
            ; OUTPUT(S): 
            ;   Result at the given address   
            ; MODIFIES:
             
            ; This subroutine modifies the value of register R4,R5, R6 and R7 , also the memory location 40H, 41H, 42H, and 43H where the result is stored
             
            ;   [TODO]
            ; -------------------------------------------------------------------
             
            SQR_S16:
             
            ; [TODO: Place your code here]
             
               ; implemented this task using the process of multiplication of two 16-bit numbers 
           
      MOV A, R1     
      ADD A, #3     ; First, we need to increase the value of our output address by 3 as we will get the last byte of the result first and we need to store in the last output address byte
      MOV R1, A  
      MOV A, R2     ; loading the low byte which in stored in R2 to accumulator
      MOV B, R2     ; also taking the same value in register B 
      MUL AB        ; Multiplication of A and B register, as we know higher order byte of the result will be stored into B and lower order byte to register A  
      MOV @R1,A     ; in register A we have the most lower order byte of the final result which will not be used anymore, so we store it into the current address pointed by resgister R1(43H)
      DEC R1        ; decreasing output address from 43H to 42H for the next result byte
      MOV R4, B     ; we shift the value of the B register into register R4 as we have to add it to the next partial product
                              ; next multiplication will take place between the low byte and high byte of the number
      MOV A, R2     ; so, we load the lower byte again in register A
      MOV B,R0      ; then we load the higher byte in register B
      MUL AB        ; multiply the lower byte and the higher byte.
      ADD A, R4     ; here we add content of R4
      MOV R5,A      ; Content of A is moved to register R5 for further addition later with another partial later
      MOV A,B       ; the addition process continues for the higher byte so we move the value of B to A
      ADDC A, #00H  ; the higher byte is added to the carry of lower byte if generated of partial products
      CLR C         ; clearing the carry for next partial product addtion
      MOV R6, A     ; the partial is stored away in R6 for future addition
      MOV A, R0     ; we move the contents of register R0 into the accumulator.
      MOV B, R2     ; loading R2 to register B
     MUL AB        ; we multiply the contents of register A with that in B
      ADD A, R5     ; now we have to add the content of R5
      MOV @R1, A    ; in register A we have the 2nd most lower order byte (the 3rd 8  bits) of the final result which will not be used anymore, so we store it into the current address pointed by resgister R1
      DEC R1        ; decreasing output address from 42H to 41H for storing the next result byte
      MOV A,B       ; the next addition is carried out by bringing the higher order byte to accumulator
      ADDC A,R6     ; the previous partial product along with higher order byte in A and if there is carry its added.
      MOV R3, #00H  ; will use R3 to use the keep the carry of this previous addition
      JC IF_CARRY   ; jumping to another subroutine to increament the first byte of the result address if any carry generated here
       
                
       ;[ If there was no carry in previous step then the code will be continuing here, otherwise it will return here from the IF_CARRY subroutine and continue the rest of the multiplication] 
      IF_NO_CARRY: 
       
      CLR C         ; clearing the carry for next partial product addtion
      MOV R7, A     ; the content of A is moved to R7 for further addition later
      MOV A, R0     ; the content of register R0 which is higher byte is moved into A 
      MOV B, R0	   ; the content of register R0 is moved to B
      MUL AB        ; Here we find the product of the two
      ADD A, R7     ; addition of partial products and the put in A
     MOV @R1, A    ;in register A we get the 2nd higherorder byte (the  2nd 8  bit) of the final result which will not be used anymore, so we store it into the current address pointed by resgister R1
      DEC R1        ;decreasing output address from for the next result byte
      MOV A,B       ;partial product higher byte brought to A
      ADDC A, R3  ; addition is carried btween partial products and carry if any 
      MOV @R1,A     ; the final result , the first 8 bits of the result in stored in the address pointed by register R1
                
                
      RET
       
        ; [This subroutine is only used if there is any carry generated to be added to the first byte of the result from previous partial addition]
        ; [it modifies the value of the first result address by increamenting 1 and then return to the rest of the multiplication process] 
       IF_CARRY:
           
      INC R3 ; as didn't use R3 for any other purpose , we will increament it to keep the carry
      JMP IF_NO_CARRY
          
            ; End of the source file
            END

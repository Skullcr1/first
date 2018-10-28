.model small
buffer_size EQU 255
.stack 100h

.data
    enter_message    DB "Enter symbols: $"
    input_buffer_reserved DB buffer_size
    input_data_length DB ?
    buffer  DB buffer_size dup (?)
    end_of_string  DB  13, 10, '$'
    ; buffer DB 'civca$'
    result_message    DB "Count of misplaced letters: $"
    misplaced_letters_count DB 0h, 24h
    ;end_of_string equ 0dh
.code

start:
    DEFINE_DATA:
        MOV AX, @data                   ; 
        MOV DS, AX                      ; 
 
    DATA_INPUT:
        MOV AH, 09h
        MOV DX, offset enter_message
        INT 21h
       
        MOV AH, 0Ah
        MOV DX, offset input_buffer_reserved
        INT 21h
        
        MOV	AH, 9
        MOV	DX, offset end_of_string
        INT	21h	
        
    LETTER_CASE:    
        xor CL, CL
        MOV CL, input_data_length
        LEA BX, buffer
        MOV DL, 41h
        MOV dh, 5Ah                
        
    CHECK_UPPER_CASE:
        CMP [BX], DL
        JB KEEP_CASE
        CMP [BX], dh
        JA KEEP_CASE
        ADD	byte ptr [BX], 20h
        
    KEEP_CASE:
        INC BX 
        DEC CL
        CMP CL, 0
        JNE CHECK_UPPER_CASE
                        
    PREPARE_ITERATION_BUFFERS:
        MOV SI, offset buffer
        MOV DI, offset buffer
        XOR AH, AH
        MOV AL, input_data_length ;point DI to the last item
        ADD DI, AX
        SUB DI, 1  
        CMP SI, DI ;check if only one letter was provided
        JE PRINT_MISPLACED_LETTERS
    
    CHECK_IF_EVEN:
        MOV CL, input_data_length 
        TEST CL, 1
        JZ ITERATE_LETTERS_EVEN
        
    ITERATE_LETTERS_ODD:
        MOV AX, [SI]
        MOV BX, [DI]
        
        INC SI ;take next letter
        DEC DI ;take previous letter from the end
        
        PUSH AX
        PUSH BX
        CALL ADD_MISPLACED_LETTERS
                       
        CMP SI, DI
        JNE ITERATE_LETTERS_ODD
        JMP PRINT_MISPLACED_LETTERS
        
    ITERATE_LETTERS_EVEN:
        MOV AX, [SI]
        MOV BX, [DI]

        INC SI ;take next letter
        DEC DI ;take previous letter from the end
        
        PUSH AX
        PUSH BX
        CALL ADD_MISPLACED_LETTERS
        
        MOV DX, DI
        ADD DX, 1
        
        CMP SI, DX
        JNE ITERATE_LETTERS_EVEN
        JMP PRINT_MISPLACED_LETTERS
    
    PRINT_MISPLACED_LETTERS:
          ; xor AX, AX
        MOV	AH, 9
        MOV	DX, offset result_message
        INT	21h	
    HEX_TO_DEC:    
        xor AX, AX
        MOV al, misplaced_letters_count
        AAM
        
        ADD AX, 3030h
        PUSH AX
        
        MOV DL,AH
        MOV AH, 02h
        INT 21h
        
        POP DX
        MOV AH, 02h
        INT 21h
       
    EXIT:
        MOV AH, 4ch             ; griztame i dos'a
        INT 21h                 ; dos'o INTeruptas
        
    ADD_MISPLACED_LETTERS PROC
        PUSH BP ; save stack
        MOV BP, SP
        XOR CL, CL
        
        MOV BX,[BP+4] ; get last letter
        MOV AX,[BP+6] ; get first letter
        
        CMP AL, BL
        JE END_ADD_MISPLACED_LETTERS 
        INC CL
        SHL CL,1
        
        ADD misplaced_letters_count, CL
        
        END_ADD_MISPLACED_LETTERS:
        
        MOV SP, BP ;restore stack
        POP BP
        RET ; POP parameters off stack and return
    ADD_MISPLACED_LETTERS ENDP
end start
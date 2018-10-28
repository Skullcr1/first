.model small
buffer_size EQU 255
.stack 100h

.data
    ent    db "Enter symbols: $"
    input_buffer_reserved DB buffer_size
    input_data_length db ?
    buffer  db buffer_size dup (?)
    end_of_string  db  13, 10, '$'
    ; buffer db 'civca$'
    result_message    db "Count of misplaced letters: $"
    misplaced_letters_count db 0h, 24h
    ;end_of_string equ 0dh
.code

start:
    DEFINE_DATA:
        MOV AX, @data                   ; 
        MOV DS, AX                      ; 
 
    DATA_INPUT:
        mov ah, 09h
        mov dx, offset ent 
        int 21h
       
        mov ah, 0Ah
        mov dx, offset input_buffer_reserved
        int 21h
        
        MOV	ah, 9
        MOV	dx, offset end_of_string
        INT	21h	
        
        xor cl, cl
        mov cl, input_data_length
        lea bx, buffer
        mov dl, 41h
        mov dh, 5Ah
        
        
        
    CHECK_UPPER_CASE:
        CMP [ds:bx], dl
        jb KEEP_CASE
        CMP [DS:BX], dh
        JA KEEP_CASE
        ADD	byte ptr [ds:bx], 20h
        
    KEEP_CASE:
        inc bx 
        dec cl
        cmp cl, 0
        jne CHECK_UPPER_CASE
        
        
        
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
          ; xor ax, ax
        MOV	ah, 9
        MOV	dx, offset result_message
        INT	21h	
        
        xor ax, ax
        mov al, misplaced_letters_count
        AAM
        add ax, 3030h
        push ax
        mov dl,ah
        mov ah, 02h
        int 21h
        pop dx
        mov ah, 02h
        int 21h
    
    
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
        SHL Cl,1
        
        ADD misplaced_letters_count, CL
        
        END_ADD_MISPLACED_LETTERS:
        
        MOV SP, BP ;restore stack
        POP BP
        RET ; pop parameters off stack and return
    ADD_MISPLACED_LETTERS ENDP
end start
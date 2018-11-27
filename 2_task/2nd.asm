.model small
.stack 100h

.data
  txt_file db "data.txt", 0
  Open_file1 db 128 dup (0) 
  read_buffer db 10 dup (?)
  text_length DB ?
  data_descr dw ?
  buffer_number dw 0
  error_message db "error$"
  help_msg db" error $"
  lcase db "Lcase letter:$"
  dcase db "dcase letter:$"
    ;   print_number db 10 dup (24h)
  ;*************************
  symbol_number dw 0h
  word_number dw 0h
  lcase_letter dw 0h
  dcase_letter dw 0h    

  ;we will put our result in variables


.code


start:
    mov ax, @data
    mov ds, ax

    mov bx, 82h
    mov si, offset Open_file1
    cmp byte ptr es:[80h], 0
    je help
    cmp es:[82h], '?/'
    jne check_parametrs
    cmp byte ptr es:[84h], 13
    je help
    jmp check_parametrs

help:
    mov ah, 9
	mov dx, offset help_msg
	int 21h
	jmp exit

check_parametrs:
	cmp byte ptr es:[bx], 13 
	je Open_file
    mov dl, byte ptr es:[bx]
	mov [si], dl
	inc bx
	inc si
	jmp check_parametrs


Open_file:
    mov ah, 3Dh
    mov al, 0
    lea dx, Open_file1
    int 21h
    jc reading_error
    
    mov data_descr, ax
    jmp reading_from_buffer
reading_error:
    mov ah, 09h
    mov dl, error_message
    int 21h
    jmp exit
reading_from_buffer:
    mov ah, 3Fh
    mov bx, data_descr
    mov cx, 10
    lea dx, read_buffer
    int 21h
    push bx
    jc reading_error
    mov buffer_number, ax
    
    cmp buffer_number, 0
    ja SCREWING_THROUGH_BUFFER
    pop bx
    jmp close_file

SCREWING_THROUGH_BUFFER:
        ; xor bx, bx
        ; mov bx, dx
        
        lea si, read_buffer   
        xor cx, cx
        mov cx, ax

      
        lol:
        mov bx, [si]
    
        checking1:
            cmp cx, 0h
            je reading_from_buffer 
            cmp bl, 0h
            je reading_from_buffer
        checking:  
            cmp bl, 20h
            je space
            cmp bl, 61h
            jae small_letter
            cmp bl, 41h
            jae big_letter
            cmp bl, 20h
            ja not_letter
       
        space:
            cmp bh, 20h
            je st_space
            
          word_count:
            inc word_number     
            mov bl,bh    
            inc si
            dec cx
            jmp lol
        

        st_space:
            
            dec cx
            mov bl,bh
            inc si
            jmp lol

        not_letter:
            
            dec cx
            inc symbol_number
            mov bl,bh
            inc si
            jmp lol

        big_letter: ;/* check */
            cmp bl, 5Ah
            ja not_letter
            inc dcase_letter
            dec cx
            inc symbol_number
            mov bl,bh
            inc si
            jmp lol

        small_letter: ;check
            cmp bl, 7Ah
            jae not_letter
            inc lcase_letter
            ; inc si
            dec cx
            inc symbol_number
            mov bl,bh
            inc si
            jmp lol






        close_file:
            xor cx, cx
            
            mov ah, 3Eh
            int 21h

    mov ah, 9   
	mov dx, offset Lcase
	int 21h

HEX_TO_DEC:
    xor dx, dx
    xor cx, cx
    xor bx, bx
    mov ax, lcase_letter
    mov cx, 10

    divide:
    div cx
    push dx
    xor dx, dx
    inc bx
    test ah, ah
    jz check_al
    check_al:
    test al, al
    jz print_number
    jmp divide
    print_number:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    dec bx
    jnz print_number
    jmp exit





    jmp exit





exit:
    mov ah, 4ch
    mov al, 0
    int 21h
end start
STUFF:  
    ; PROC Count_symbols
    ;     push ax
    ;     push bx
    ;     push cx
    ;     push dx


            
            
                ; ignore multiple spaces
        

        
    
    ;  MOV     CX,0FFFFh        ;the number to turn to Decimal
    XOR     AX,0
    xor    BX,0
    xor     DL,0
    INC_LOOP:
    INC     AL               ;AL is the first digit
    CMP     AL,0Ah           ;Has it reached 10 yet?
    JNE     CONTINUE         ;No, continue.
    MOV     AL,0             ;Yes, empty it
    INC     AH      
    push ax         ;AH is the second digit
    CMP     AH,0Ah           ;Has it reached 10 yet?
    JNE     CONTINUE         ;No, continue ...
    MOV     AH,0
    INC     BL               ;BL is the third digit
    CMP     BL,0Ah
    JNE     CONTINUE
    MOV     BL,0
    INC     BH               ;BH is the forth digit
    CMP     BH,0Ah
    MOV     BH,0
    push bx
    INC     DL               ;DL is the fifth digit
            
    CONTINUE:
    pop ax
    LOOP    INC_LOOP

    ; HEX_TO_DEC:
    ;                 XOR BX, BX
    ;                 XOR AX, AX
    ;                 MOV     CL, 10
    ;                 MOV AL, dcase_letter
                
    ;                 LOOP1:
    ;                 DIV CL
    ;                 inc BX
    ;                 PUSH AX
    ;                 XOR AH, AH

    ;                 TEST al, al
    ;                 jnz LOOP1

    ;                 LOOP2:
    ;                 POP DX
    ;                 MOV DL, DH
    ;                 ADD DL, '0'
    ;                 MOV AH, 02h
    ;                 INT 21h
    ;                 dec bx
    ;                 jnz LOOP2
        

        ; mov ah, 9   
        ; mov dx, offset dcase
        ; int 21h

        ;  HEX_TO_DEC:
        ;             XOR BX, BX
        ;             XOR AX, AX
        ;             MOV bl, 10
        ;             MOV ax, dcase_letter
        ;             LOOP1:
                

        ;             DIV bl
        ;             inc cx
        ;             PUSH AX
        ;             XOR AH, AH

        ;             TEST al, al
        ;             jnz LOOP1

        ;             LOOP2:
        ;             POP DX
        ;             MOV DL, DH
        ;             ADD DL, '0'
        ;             MOV AH, 02h
        ;             INT 21h
        ;             dec cx
        ;             jnz LOOP2
.model small
.stack 100h

.data
  txt_file db "data.txt", 0
  Open_file1 db 128 dup (0) 
  read_buffer db 10 dup (?)
  text_length DB ?
  data_descr dw ?
  buffer_number dw 0
  error_message db "Error occured. try again$"
  name_msg db "Korneliusz Tomasz Maksimowicz, PS 5 grupe$"
  lcase db "Lcase letter: $"
  dcase db "dcase letter: $"
  wcase db "word number: $"
  scase db "symbol number: $"
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
    cmp byte ptr es:[80h], 0h
    je help
    cmp es:[82h], '?/'
    jne check_parametrs
    cmp byte ptr es:[84h], 13
    je name1
    jmp check_parametrs
name1:
    mov ah, 9
	mov dx, offset name_msg
	int 21h
	jmp exit
help:
    mov ah, 9
	mov dx, offset error_message
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
    mov bx, 00h ;initial push
    push bx
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
    
    ;push bx
    jc reading_error
    mov buffer_number, ax 
    cmp buffer_number, 0
    ja SCREWING_THROUGH_BUFFER
    ; pop bx
    jmp close_file

SCREWING_THROUGH_BUFFER:
        xor bx, bx
        ; mov bx, dx
       mov bx, ax
        lea si, read_buffer   
      
        mov cx, ax

        pop bx
        mov ah, bl

        lol:
        
        
        

    ;rename
        
            cmp cx, 0h
            jne continue_checking
            
            push bx
            jmp reading_from_buffer 
        

continue_checking:
            mov bx, [si]
            cmp bl, 0h
            je reading_from_buffer
        checking:  
            cmp bl, 0Dh
            je subber
            cmp bl, 0Ah
            je subber
            cmp bl, 20h
            je subber
            cmp bl, 61h
            jae small_letter
            cmp bl, 41h
            jae big_letter
            cmp bl, 41h
            jb symbol_count
       check_previous_Value:
            cmp ah, 20h
            ja word_count

        ; space1:
        ;     cmp ax, cx
        ;     je space2
        ;     cmp bh, 20h
        ;     ja word_count
        ;     jmp subber
        ; spacex:      
        ;     cmp cx, 0Ah  
        ;     je subber
        ;     jmp space2
        ; space2:    
        ;     cmp bh, 20h
        ;     je subber


         subber:
            ;mov bl, bh
            inc si
            dec cx
            jmp lol

        ;  st_space:
        ;     mov bl, bh
        ;     inc si
        ;     dec cx
        ;     jmp lol

        word_count:
            
            inc word_number     
           ; mov bl,bh    
            inc si
            dec cx
            jmp lol
        
        ; not_letter:  
        ;     dec cx
        ;     inc symbol_number
        ;     ;mov bl,bh
        ;     inc si
        ;     jmp lol

        ; big_letter: ;/* check */
        ;     cmp bl, 5Ah
        ;     ja not_letter
        ;     inc dcase_letter
        ;     dec cx
        ;     inc symbol_number
        ;     mov bl,bh
        ;     inc si
        ;     jmp lol

        small_letter:
            cmp bl, 7Ah
            ja symbol_count
            inc lcase_letter
            inc symbol_number ; is small letter a symbol?
            cmp bh, 20h
            jbe word_count
            cmp cx, 01
            je check_if_last_word

            jmp subber
        
        big_letter:   
            cmp bl, 5Ah
            ja symbol_count
            inc dcase_letter
            inc symbol_number
            cmp bh, 20h
            jbe word_count
            cmp cx, 01
            je check_if_last_word
            
            jmp subber

        symbol_count:
            cmp bl, 7Fh
            jb symbol_add
            cmp bl, 61h
            jb symbol_add
            cmp bl, 20h
            ja symbol_add
            jmp subber
        symbol_add:
            inc symbol_number
            cmp bh, 20h
            jbe word_count
           
            cmp cx, 01h
            je check_if_last_word

            jmp subber

        check_if_last_word:
            cmp al, 10
            jne word_count
            jmp subber

close_file:
            xor cx, cx
            mov ah, 3Eh
            int 21h

    mov ah, 9   
	mov dx, offset wcase
	int 21h
    mov ax, word_number
    call HEX_TO_DEC

    mov ah, 9   
	mov dx, offset lcase
	int 21h
    mov ax, lcase_letter
    call HEX_TO_DEC

     mov ah, 9   
	mov dx, offset dcase
	int 21h
    mov ax, dcase_letter
    call HEX_TO_DEC

     mov ah, 9   
	mov dx, offset scase
	int 21h
    mov ax, symbol_number
    call HEX_TO_DEC
    



    





    jmp exit





exit:
    mov ah, 4ch
    mov al, 0
    int 21h

    Proc HEX_TO_DEC

    xor dx, dx
    xor cx, cx
    xor bx, bx
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

RET
endp HEX_TO_DEC

end start

Proc HEX_TO_DEC

    xor dx, dx
    xor cx, cx
    xor bx, bx
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

RET
endp HEX_TO_DEC

STUFF:  HEX_TO_DEC:
    xor dx, dx
    xor cx, cx
    xor bx, bx
    mov ax, word_number
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
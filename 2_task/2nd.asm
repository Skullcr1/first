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

  ;*************************
  symbol_number db 0h
  word_number db 0h
  lcase_letter db 0h
  dcase_letter db 0h    

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
    lea dx, txt_file
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
        
      
        lol:
        mov bx, [si]
    
        checking1:
            cmp cx, 0h
            je reading_from_buffer
            cmp bl, 0h
            inc word_number
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
            cmp cx, buffer_number
            je st_space
            cmp bl, 20h
          word_count:
            inc word_number         
            inc si
            dec cx
            jmp lol
        

        st_space:
            dec buffer_number
            ; inc si
            dec cx

            jmp lol

        not_letter:
            
            dec cx
            inc symbol_number
            inc si 
            jmp lol

        big_letter:
            cmp bl, 5Ah
            ja not_letter
            inc dcase_letter
            dec cx
            inc symbol_number
            mov bl,bh
            inc si
            jmp lol

        small_letter:
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
    mov cl, word_number
    mov ah, 3Eh
    int 21h

    mov ah, 9   
	mov dx, offset Lcase
	int 21h

      HEX_TO_DEC1:
                XOR BX, BX
                XOR AX, AX
                MOV     CL, 10
                MOV AL, lcase_letter
                LOOP12:
                

                DIV CL
                inc BX
                PUSH AX
                XOR AH, AH

                TEST al, al
                jnz LOOP12

                LOOP21:
                POP DX
                MOV DL, DH
                ADD DL, '0'
                MOV AH, 02h
                INT 21h
                dec bx
                jnz LOOP21

    mov ah, 9   
	mov dx, offset dcase
	int 21h

     HEX_TO_DEC:
                XOR BX, BX
                XOR AX, AX
                MOV     CL, 10
                MOV AL, dcase_letter
                LOOP1:
               

                DIV CL
                inc BX
                PUSH AX
                XOR AH, AH

                TEST al, al
                jnz LOOP1

                LOOP2:
                POP DX
                MOV DL, DH
                ADD DL, '0'
                MOV AH, 02h
                INT 21h
                dec bx
                jnz LOOP2



    jmp exit





exit:
    mov ah, 4ch
    mov al, 0
    int 21h
end start

; PROC Count_symbols
;     push ax
;     push bx
;     push cx
;     push dx


           
        
            ; ignore multiple spaces
       

       
    HEX_TO_DEC:
                XOR BX, BX
                XOR AX, AX
                MOV     CL, 10
                MOV AL, lcase_letter
                LOOP1:

                DIV CL
                inc BX
                PUSH AX
                XOR AH, AH

                TEST al, al
                jnz LOOP1

                LOOP2:
                POP DX
                MOV DL, DH
                ADD DL, '0'
                MOV AH, 02h
                INT 21h
                dec bx
                jnz LOOP2




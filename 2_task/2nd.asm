.model small
.stack 100h

.data
  txt_file db "data.txt", 0
  text_length DB ?
  read_buffer db 10 dup (?)
  data_descr dw ?
  buffer_number dw 0
  error_message db "error$"

  ;*************************
  symbol_number db ?
  word_number db ?
  lcase_letter db ?
  dcase_letter db ?    

  ;we will put our result in variables


.code


start:
mov ax, @data
mov ds, ax

Open_file:
    mov ah, 3Dh
    mov al, 0
    lea dx, txt_file
    int 21h
    jc reading_error
    mov data_descr, ax
    jmp count_numbers

reading_from_buffer:
    mov ah, 3Fh
    mov bx, data_descr
    mov cx, 10
    lea dx, read_buffer
    int 21h
    jc reading_error
    mov buffer_number, ax
    
    cmp buffer_number, 0
    ja SCREWING_THROUGH_BUFFER
    jmp close_file

SCREWING_THROUGH_BUFFER:
        lea bx, read_buffer
        mov si, bx
        mov cx, buffer_number
        checking1:
            cmp cx, 0
            je reading_from_buffer
        checking:  
            cmp [bx], 20h
            je space
            cmp [bx], 61h
            jae small_letter
            cmp [bx], 41h
            jae big_letter
            cmp [bx], 20h
            ja not_letter
       
        space:
            cmp cx, buffer_number
            je st_space
            cmp [bx + 1], 20h
            ja word_count

        word_count:
            inc word_number         
            inc bx
            dec cx
            jmp checking1

        st_space:
            dec buffer_number
            inc bx
            dec cx
            jmp checking1

        not_letter:
            inc bx 
            dec cx
            inc symbol_number
            jmp checking1

        big_letter:
            cmp [bx], 5Ah
            ja not_letter
            inc dcase_letter
            inc bx
            dec cx
            inc symbol_number
            jmp checking1

        small_letter:
            cmp [bx], 7Ah
            jae not_letter
            inc lcase_letter
            inc bx
            dec cx
            inc symbol_number
            jmp checking1



reading_error:
    mov ah, 09h
    mov dl, error_message
    int 21h
    jmp exit


Printing_letters:







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


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
  word_number db?
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

count_numbers:
    mov ah, 3Fh
    mov bx, data_descr
    mov cx, 10
    lea dx, read_buffer
    int 21h
    jc reading_error
    mov buffer_number, ax
    
    call Count_symbols





reading_error:
    mov ah, 09h
    mov dx, error_message
    int 21h
    jmp exit


exit:
    mov ah, 4ch
    mov al, 0
    int 21h
end start

PROC Count_symbols
    push ax
    push bx
    push cx
    push dx

        lea bx, read_buffer
        mov cx, buffer_number

        checking:
        
        cmp [bx], 61h
        jae small_letter
        cmp [bx], 41h
        jae big_letter
       



        not_letter:
        inc bx 
        dec cx
        jmp checking 

        big_letter:
        cmp [bx], 5A
        ja not_letter
        inc dcase_letter
        inc bx
        dec cx
        jmp checking

        small_letter:
        cmp [bx], 7A
        jae not_letter
        inc lcase_letter
        inc bx
        dec cx
        jmp checking




        

       

       
    
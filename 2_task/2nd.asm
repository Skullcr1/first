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

        cmp [bx], 41h
        jb not_letter
        cmp [bx], 5Bh
        ja big_letter
        cmp [bx], 61h
        jb not_letter
        cmp[bx], 7Bh
        jb small_letter
        
        

       

       
    
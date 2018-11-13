.model small
.stack 100h

.data
  txt_file db "data.txt", 0
  text_length DB ?
  read_buffer db 10 dup (?)
  data_descr dw ?
  buffer_data dw 0
  error_message db "error$"
.code


start:
mov ax, @data
mov ds, ax

Open_file:
    mov ah, 3Dh
    mov al, 00h
    mov dx, txt_file
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
jc error_message





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

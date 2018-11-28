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
  new_line db 13,10,24h 
    ;   print_number db 10 dup (24h)
  ;*************************
  symbol_number dw 0h
  word_number dw 0h
  lower_case dw 0h
  upper_case dw 0h    
  parameter_index dw 82h
  is_it_last_parameter dw 0h ;use bool
  ;we will put our result in variables


.code


start:
    mov ax, @data
    mov ds, ax
    mov bx, parameter_index
    mov si, offset Open_file1
    cmp byte ptr es:[80h], 0h
    je help
    cmp es:[82h], '?/'
    jne check_parametrs
    cmp byte ptr es:[84h], 0dh
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
	cmp byte ptr es:[bx], 0dh 
	je Open_last_file
    cmp byte ptr es:[bx], 20h 
	je Open_file
    mov dl, byte ptr es:[bx]
	mov [si], dl
	inc bx
	inc si
	jmp check_parametrs

Open_last_file:
    mov is_it_last_parameter, 01h
Open_file:
    inc bx
    mov parameter_index, bx
    mov ah, 3Dh
    mov al, 0h
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
    
    jc reading_error
    mov buffer_number, ax 
    cmp buffer_number, 0h
    jne count_how_many_checks
    cmp buffer_number, 0h
    ja ITERATE_BUFFER
    inc word_number   
    jmp close_file

count_how_many_checks:
; inc di
jmp ITERATE_BUFFER

ITERATE_BUFFER:
        xor bx, bx
        mov bx, ax
        lea si, read_buffer   
      
        mov cx, ax      ;amount of characters 
        pop bx          ;last value from previous buffer
        mov ah, bl      ;saving last value in ah
        cmp di, 1
        jne still_1_word
        cmp ah, 20h
        je still_1_word
        inc word_number
        check_if_iterate_finished:  
            cmp cx, 0h
            jne check_char_ranges
            ; dec di
            push bx     ;save last value to stack
            jmp reading_from_buffer 

start_near:
mov word_number,0h
mov lower_case,0h
mov upper_case, 0h  
mov symbol_number, 0h
jmp start        

still_1_word:
jmp check_char_ranges
check_char_ranges:
            mov bx, [si]
            cmp bl, 0h
            je reading_from_buffer
            cmp bl, 0Dh
            je increase_counter
            cmp bl, 0Ah
            je increase_counter
            cmp bl, 20h
            je increase_counter
            cmp bl, 61h
            jae small_letter
            cmp bl, 41h
            jae big_letter
            cmp bl, 41h
            jb symbol_count
       check_previous_Value:
            cmp ah, 20h
            ja word_count

         increase_counter: 
            inc si
            dec cx
            jmp check_if_iterate_finished

        word_count:
            inc word_number        
            inc si
            dec cx
            jmp check_if_iterate_finished

        small_letter:
            cmp bl, 7Ah
            ja symbol_count
            inc lower_case
            inc symbol_number ; is small letter a symbol?
            cmp cx, 01
            je check_if_last_word
            cmp bh, 20h
            jbe word_count
            cmp cx, 01
            je check_if_last_word
            jmp increase_counter
start_further:
jmp start_near       
        big_letter:   
            cmp bl, 5Ah
            ja symbol_count
            inc upper_case
            inc symbol_number
            cmp cx, 01
            je check_if_last_word
            cmp bh, 20h
            jbe word_count
            cmp cx, 01
            je check_if_last_word
            jmp increase_counter

        symbol_count:
            cmp bl, 7Fh
            jb symbol_add
            cmp bl, 61h
            jb symbol_add
            cmp bl, 20h
            ja symbol_add
            jmp increase_counter
        symbol_add:
            inc symbol_number
            cmp bh, 20h
            jbe word_count
           
            cmp cx, 01h
            je check_if_last_word

            jmp increase_counter

        check_if_last_word:
            cmp al, 10
            jne increase_counter
            jmp increase_counter
start_far:
jmp start_further
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
    mov ax, lower_case
    call HEX_TO_DEC

     mov ah, 9   
	mov dx, offset dcase
	int 21h
    mov ax, upper_case
    call HEX_TO_DEC

     mov ah, 9   
	mov dx, offset scase
	int 21h
    mov ax, symbol_number
    call HEX_TO_DEC
    mov ah,9
    mov dx, offset new_line
    int 21h

    cmp is_it_last_parameter, 01h
    jne start_far
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

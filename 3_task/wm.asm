.model small
.stack 100h
.data
	help1 db 'Pagalba: Iveskite egzistuojancius duomenu failu pavadinimus palyginimui pvz.: failo_pavadinimas.com failo_pavadinimas2.txt', 0Dh, 0Ah, '$' 
	file1 db 20 dup (0)
    file2 db 20 dup (0)
    handler1 dw ?
    handler2 dw ? 
	nera db 'failas nerastas.$'
	;logine2 db 0h
	nuskaityti_baitai dw ?
	
	buff db 255
			db 256 dup ("$")
	buff_pozicija dw 0

	senasIP dw ?
	senasCS dw ?   
	
	IPproc  dw  ?
	CSproc  dw  ?
	
	reg1 db ?
	reg2 db ?
	reg3 db ?
	reg4 db ?
	
	regAX dw ?
	regBX 	dw ?
	regCX	dw ?
	regDX 	dw ?
	regSP 	dw ?
	regBP 	dw ?
	regSI 	dw ?
	regDI 	dw ?
	regES	dw ?
	regDS	dw ?
	
	wBitas db ?
	dBitas db ?
	modas db ?
	regas db ?
	remas db ?
	pag db ?
	
	prefiksas db ?
	prefiksas_spausd db "DS:$"
	cs_spausd db "CS:$"
	
	div_idiv dw ?
	komandos_pav dw ?
	
	operando_offset dw 0
	
	registras1 db "$"
	registras2 db "$"
	
	registrasAX db "ax$"
	registrasBX db "bx$"
	registrasCX db "cx$"
	registrasDX db "dx$"
	registrasSP db "sp$"
	registrasBP db "bp$"
	registrasSI db "si$"
	registrasDI db "di$"
	registrasAL db "al$"
	registrasAH db "ah$"
	registrasBL db "bl$"
	registrasBH db "bh$"
	registrasCL db "cl$"
	registrasCH db "ch$"
	registrasDL db "dl$"
	registrasDH db "dh$"
	
	rm_000 db "[bx+si$"
	rm_001 db "[bx+di$"
	rm_010 db "[bp+si$"
	rm_011 db "[bp+di$"
	rm_100 db "[si$"
	rm_101 db "[di$"
	rm_110 db "[bp+$"
	rm_111 db "[bx$"
	
	pref db "ds:$"
	
	komanda_DIV db "DIV $"
	komanda_IDIV db "IDIV $"
	komanda_IRET db "IRET $"
    komanda_XCHG_AXAX db "XCHG ax, ax$"
    komanda_XCHG_BXAX db "XCHG ax, ax$"
    komanda_XCHG_DXAX db "XCHG dx, ax$"  
    komanda_XCHG_CXAX db "XCHG cx, ax$"
	komanda_INal db "IN al, $"
	komanda_INax db "IN ax, $"
	komanda_INaldx db "IN al, dx$"
	komanda_INaxdx db "IN ax, dx$"
	komanda_TEST db "TEST $"
	komanda_TEST2 db "TEST ax$"
	komanda_XCHG db "XCHG $"
	komanda_LES db "LES $"
	komanda_INT db "INT $"
	komanda_nera db "neatpazinta komanda$"
	
	tiesiog1 db "["
	tiesiog2 db "h]"
	pliusas db "+"
	kvad_skliaust db "]"
	space db " "
	skaitmuo db ?
	komandos_pav_ilgis dw ?
	
	word_ptr db "word ptr $"
	byte_ptr db "byte ptr $"
	
	enteris db 13,10,"$"
	kablelis_tarpas db ", $"
	
	komandos_pradzia dw 0
	komandos_ilgis db ?
	baitu_skaicius dw 0
	
	nera_adr db ?
	apleidziam db ?
	du_operandai db ?
	failo_pabaiga db ?
	broken db 0
	xchg2 db 0
	betarpiskas_operandas db ?
	pataisyta db 0

.code
	mov ax, @data
	mov ds, ax
	
;-----------------------------------------------------------------
;Nustatome parametrus
;-----------------------------------------------------------------
	mov si, 81h
	parametrai:
        inc si                  ;nuskaitom parametrus
        mov ah, es:[si]         
        cmp ah, 0             ;jei parametru nera issvieciam pagalba
        je  help
        inc si
        mov al, es:[si]
        cmp ax, 2F3Fh           ;/?
        je help
        jmp filename
        
help:
        mov dx, offset help1
        mov ah, 9
        int 21h
        jmp pabaiga
 
 filename: 
        mov di, offset file1  
        mov si, 82h     
filename1:
        mov al, es:[si]         ;1 failo pavadinimo nuskaitymas
        inc si
        cmp al, ' '
        je kitas
	cmp al, 13
	je help
        mov ds:[di], al
        inc di
        jmp filename1   
        
kitas:
        push di
        mov di, offset file2
        
        
filename2:
        mov al, es:[si]         ;2 failo pavadinimo nuskaitymas
        inc si
        cmp al, 13
        je  file2_sukurimas
        mov ds:[di], al
        inc di
        jmp filename2
        
file2_sukurimas:		
		mov cx, 0h
		mov dx, offset file2
		mov ah, 3ch
		int 21h
		
atidarom:
        push di
        mov ah, 3dh             ;failu atidarymas
        mov al, 0h
        mov dx, offset file1
        int 21h 
        cmp ax, 0002h
        je  nera_failo1 
        mov handler1, ax
        mov ah, 3dh
        mov al, 1h
        mov dx, offset file2
        int 21h

        cmp ax, 0002h 
        je nera_failo2
        mov handler2, ax
        jmp  disasm
       
nera_failo1:                     
        pop di                    
        pop di                     
        inc di
	mov ah, 24h                      
        mov ds:[di], ah             
        mov ah, 09h                   
        mov dx, offset file1           
        int 21h                         
        mov dx, offset nera              
        int 21h                           
        jmp uzdarom                        
		
nera_failo2:
        pop di                              
        inc di                               
        mov ah, 24h                      
        mov ds:[di], ah                       
        mov ah, 09h                             
        mov dx, offset file2                     
        int 21h                                   
        mov dx, offset nera                        
        int 21h                                     
        jmp uzdarom          
	
disasm:
	mov baitu_skaicius, 0h
	call skaitom_file
	call pertraukimas
	cmp failo_pabaiga, 0h
	je disasm
	
	uzdarom:
        mov bx, handler1
        mov ah, 3Eh
        int 21h
        
        mov bx, handler2
        int 21h
        
pabaiga:
	mov ah, 4Ch
	int 21h
	
    PROC skaitom_file
        mov si, 1h
        mov bx, handler1
        mov cx, 222
        lea dx, [buff+si]      ; failo turinio nuskaitymas i buff1
        mov ah, 3Fh
        int 21h
        
		mov nuskaityti_baitai, ax
        cmp ax, 0
        je skip
        mov failo_pabaiga, 0h		;logine2 bus 1 jei faile liko dar nenuskaitytu simboliu
        jmp toliau1
        skip:
        mov failo_pabaiga, 1h 
        toliau1:	      
        ret
    ENDP skaitom_file

;=====================================================
;Atpazinimo algoritmai
;=====================================================	
	
pertraukimas:

;nustatymas ar failo pabaiga gali neveikt
	
	mov broken, 0h
	; mov xchg2, 0h
	mov betarpiskas_operandas, 0h

	mov komandos_ilgis, 0
	call kitas_baitas
	call tikrinimas
	
	mov wBitas, al
	and wBitas, 1
	
	call kokia_komanda
	cmp apleidziam, 1h
	je neskaitom_adr
	call kitas_baitas ;gauname adresacijos baita
	call skaidyk_adr_baita
neskaitom_adr:
	
;-----------------------------------------------------------------	
;Spausdinam "CS:IP"
;-----------------------------------------------------------------
	push ax
	mov ah, 40h
	mov bx, handler2
	mov cx,  3
	mov dx, offset cs_spausd       ;CS:
	int 21h
	
	
	;
	mov ax, komandos_pradzia     ;IP
	call printAX
	
;-----------------------------------------------------------------
	
	call printSpace
	
	call spausdinti_masinini_koda
	call printSpace
	call printSpace
	call printSpace
	;SPAUSDINAMA KOMANDA
	
	mov ah, 40h
	mov bx, handler2
	mov cx,  komandos_pav_ilgis
	mov dx, komandos_pav
	int 21h
	pop ax
	cmp nera_adr, 1h
	jne yra
	cmp komandos_pav, offset komanda_IDIV
	je betarpiskas1
	cmp komandos_pav, offset komanda_nera
	je betarpiskas1
	cmp komandos_pav, offset komanda_INaxdx
	je betarpiskas1
	cmp komandos_pav, offset komanda_INaldx
	je betarpiskas1
	cmp komandos_pav, offset komanda_XCHG_AXAX
	je betarpiskas1
    cmp komandos_pav, offset komanda_XCHG_BXAX
	je betarpiskas1
    cmp komandos_pav, offset komanda_XCHG_CXAX
	je betarpiskas1
    cmp komandos_pav, offset komanda_XCHG_DXAX
	je betarpiskas1
    cmp komandos_pav, offset komanda_IRET
	je betarpiskas1
	cmp komandos_pav, offset komanda_TEST2
	je betarpiskas
	mov bx, baitu_skaicius
	mov al, buff[bx]
	call printAL
	jmp betarpiskas
   
	betarpiskas1:
    jmp betarpiskas
yra:
	push ax
	call spausdink_operanda
	cmp du_operandai, 1h
	jne betarpiskas
	mov ah, 40h
	mov bx, handler2
	mov cx,  2
	mov dx, offset kablelis_tarpas
	int 21h
	; cmp xchg2, 1h
	; jne apleisk
	mov ah, 40h
	mov bx, handler2
	mov cx, 2
	mov dx, offset registrasAX
	int 21h
	jmp betarpiskas
	 pertraukimas1:
    jmp pertraukimas
; apleisk:
; 	pop ax
; 	or dBitas, 11111110b
; 	not dBitas
; 	cmp broken, 1h
; 	jne skip2
; 	mov modas, 00b	
; skip2:
; 	call spausdink_operanda
betarpiskas:
	cmp betarpiskas_operandas, 1h
	jne sicia2
	mov ah, 40h
	mov bx, handler2
	mov cx,  2
	mov dx, offset kablelis_tarpas
	int 21h
	
	cmp wBitas, 1h
	je du_baitai
	call kitas_baitas
	call printAL
	jmp sicia2
	
du_baitai:
	call kitas_baitas
	mov ah, al
	call kitas_baitas
	call printAL
	xchg al, ah
	call printAL
;-----------------------------------------------------------------
;Spausdiname enteri
;-----------------------------------------------------------------
sicia2:
	mov ah, 40h
	mov bx, handler2
	mov cx,  2
	mov dx, offset enteris
	int 21h 
	
	mov dx, baitu_skaicius
	mov komandos_pradzia, dx
	
	mov  dx, nuskaityti_baitai
	cmp baitu_skaicius,  dx
	jl pertraukimas1
	
	
beigiam:
RET 

;------------------------------------------------------------------
;Pagalbines proceduros
;------------------------------------------------------------------
kitas_baitas:
	push bx
	;	mov bh, 0
		inc buff_pozicija
		mov bx, buff_pozicija
		mov al, buff[bx]
	pop bx
	inc komandos_ilgis
	inc baitu_skaicius
RET
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------
tikrinimas: ;tikrina pagal AL reiksme
	push bx
	
	;es,cs,ss,ds
		cmp al, 26h
		je es_prefiksas
		cmp al, 2Eh
		je cs_prefiksas
		cmp al, 36h
		je ss_prefiksas
		cmp al, 3Eh
		je ds_prefiksas
		jmp tikrinimas_pabaiga
		
		es_prefiksas:
			call kitas_baitas
			mov prefiksas_spausd[0], "e"
			jmp tikrinimas_pabaiga
		cs_prefiksas:
			call kitas_baitas
			mov prefiksas_spausd[0], "c"
			jmp tikrinimas_pabaiga
		ss_prefiksas:
			call kitas_baitas
			mov prefiksas_spausd[0], "s"
			jmp tikrinimas_pabaiga
		ds_prefiksas:
			call kitas_baitas
			mov prefiksas_spausd[0], "d"
			jmp tikrinimas_pabaiga

tikrinimas_pabaiga:
	pop bx
RET
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------	
skaidyk_adr_baita: ;pagal AL
	push ax
	push cx
		mov modas, al
		mov cl, 6 ;per kiek bitu stums
		shr modas, cl ;right shift
		
		mov regas, al
		mov cl, 3
		shr regas, 3
		and regas, 111b
		
		mov remas, al
		and remas, 111b
		
	pop cx
	pop ax
RET
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------
kokia_komanda:
	cmp al, 11001111b	;IRET
	je tai_IRET
	cmp al, 11001101b	;INT sekantis baitas tai numeris
	je tai_INT_relative
	cmp al, 11000100b	;LES reg m
	je tai_LES_relative
	cmp al, 10010000b ; xchg axax
	je tai_XCHG_AXAX_relative
	cmp al, 10010011b ; xchg bxax
	je tai_XCHG_BXAX_relative
	cmp al, 10010010b ; xchg dxax
	je tai_XCHG_DXAX_relative
	cmp al, 10010001b ; xchg cxax
	je tai_XCHG_CXAX_relative
	; cmp al, 10000110b ; xchg lower/high bit and lower/high bit
    ; je tai_XCHG_XhXl
	mov pag, al
	and pag, 11111110b	;w bito maskavimas
	cmp pag, 11100100b	;IN  AX/AL <---- PORTAS (NERA ADRESACIJOS BAITO)
	je tai_INp_relative
	cmp pag, 11101100b	;IN AX/AL -----> DX/DL (NERA ADRESACIJOS BAITO)
	je tai_INd_relative
	cmp pag, 10000100b	;TEST reg   r/m
	je tai_TEST_relative ;test with reg?
	cmp pag, 10101000b
	je tai_TEST2_relative ; works
	cmp pag, 10000110b	;XCHG reg r/m
	je tai_XCHG_relative
	cmp pag, 11110110b	;DIV arba DIV
	je tai_DIV_IDIV_TEST_relative
	
	; mov regas, al
	; and regas, 111b
	; and al, 11111000b		;reg maskavimas
	; cmp al, 10010000b
	; je tai_XCHG2_relative
	jmp komanda_neatpazinta
    tai_XCHG_AXAX_relative:
    jmp tai_XCHG_AXAX
    tai_XCHG_BXAX_relative:
    jmp tai_XCHG_BXAX
    tai_XCHG_DXAX_relative:
    jmp tai_XCHG_DXAX
    tai_XCHG_CXAX_relative:
    jmp tai_XCHG_CXAX
    tai_INT_relative:
    jmp tai_INT
	tai_LES_relative:
	jmp tai_LES
	tai_INd_relative:
	jmp tai_INd
	tai_INp_relative:
	jmp tai_INp
	tai_TEST_relative:
	jmp tai_TEST
	tai_TEST2_relative:
	jmp tai_TEST2
	tai_XCHG_relative:
	jmp tai_XCHG
	tai_DIV_IDIV_TEST_relative:
	jmp tai_DIV_IDIV_TEST 
	; tai_XCHG2_relative:
	; jmp tai_XCHG2
tai_IRET:
	mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_IRET
	mov komandos_pav_ilgis, 5
	jmp kokia_komanda_pab
tai_XCHG_AXAX:
    mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_XCHG_AXAX
	mov komandos_pav_ilgis, 11
	jmp kokia_komanda_pab
tai_XCHG_BXAX:
    mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_XCHG_BXAX
	mov komandos_pav_ilgis, 11
	jmp kokia_komanda_pab
tai_XCHG_DXAX:
    mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_XCHG_DXAX
	mov komandos_pav_ilgis, 11
	jmp kokia_komanda_pab
 tai_XCHG_CXAX:
    mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_XCHG_CXAX
	mov komandos_pav_ilgis, 11
	jmp kokia_komanda_pab   
tai_INT:
	mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_INT
	mov komandos_pav_ilgis, 4
	call kitas_baitas
	jmp kokia_komanda_pab
tai_LES:
	mov apleidziam, 0h
	mov nera_adr, 0h
	mov dBitas, 0h
	mov du_operandai, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_LES
	mov komandos_pav_ilgis, 4
	jmp kokia_komanda_pab
tai_INp:
	mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	cmp wBitas, 1h
	jne p
	mov komandos_pav, offset komanda_INax
	mov komandos_pav_ilgis, 7
	jmp p2

p:
	mov komandos_pav, offset komanda_INal
	mov komandos_pav_ilgis, 7
p2:
	call kitas_baitas
	jmp kokia_komanda_pab
tai_INd:
	mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0
	cmp wBitas, 1h
	jne p3
	mov komandos_pav, offset komanda_INaxdx
	mov komandos_pav_ilgis, 9
	jmp p4
p3:
	mov komandos_pav, offset komanda_INaldx
	mov komandos_pav_ilgis, 9
p4:
	jmp kokia_komanda_pab
tai_TEST:
	mov apleidziam, 1h
	mov nera_adr, 0h
	mov dBitas, 0h
	mov du_operandai, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_TEST
	mov komandos_pav_ilgis, 5
	call kitas_baitas
	call skaidyk_adr_baita
	cmp modas, 11b
	je kokia_komanda_pab_relative
	mov broken, 1h
	mov modas, 0011b
	add komandos_ilgis, 2h
	jmp kokia_komanda_pab
tai_TEST2:
	mov apleidziam, 1h
	mov nera_adr, 1h
	mov dBitas, 0h
	mov du_operandai, 0h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_TEST2
	mov komandos_pav_ilgis,  7h
	add komandos_ilgis, 2
	mov betarpiskas_operandas, 1h
	jmp kokia_komanda_pab
	kokia_komanda_pab_relative:
	jmp kokia_komanda_pab
tai_XCHG:
	mov apleidziam, 1h
	mov nera_adr, 0h
	mov dBitas, 1h
	mov du_operandai, 1h
	mov komandos_pav, 0
	mov komandos_pav, offset komanda_XCHG
	mov komandos_pav_ilgis, 5
	call kitas_baitas
	call skaidyk_adr_baita
	cmp modas, 11b
	je kokia_komanda_pab_relative_2
	mov modas, 0011b
	mov broken, 1h
	add komandos_ilgis, 2
	jmp kokia_komanda_pab
; tai_XCHG2:
; 	mov xchg2, 1h
; 	mov apleidziam, 1h
; 	mov nera_adr, 0h
; 	mov dBitas, 0h
; 	mov wBitas, 1h
; 	mov du_operandai, 1h
; 	mov komandos_pav, 0
; 	mov komandos_pav, offset komanda_XCHG
; 	mov komandos_pav_ilgis, 5
; 	mov modas, 11b
; 	;mov bl, regas
; 	;mov remas, bl
; 	jmp kokia_komanda_pab
	kokia_komanda_pab_relative_2:
	jmp kokia_komanda_pab
; tai_TEST_REG:
; 	mov apleidziam, 1h
; 	mov nera_adr, 0h
; 	mov komandos_pav, 0
; 	mov dBitas, 1h
; 	mov du_operandai, 0h
; 	call kitas_baitas ;gauname adresacijos baita
; 	call skaidyk_adr_baita
; 	call gauti_komandos_varda_TEST
; 	jmp kokia_komanda_pab
tai_DIV_IDIV_TEST:
	mov apleidziam, 1h
	mov nera_adr, 0h
	mov komandos_pav, 0
	mov dBitas, 1h
	mov du_operandai, 0h
	call kitas_baitas ;gauname adresacijos baita
	call skaidyk_adr_baita
	call gauti_komandos_varda
	jmp kokia_komanda_pab
komanda_neatpazinta:
	mov apleidziam, 1h
	mov nera_adr, 1h
	mov komandos_pav, 0h
	mov komandos_pav, offset komanda_nera
	mov komandos_pav_ilgis, 19
	jmp kokia_komanda_pab
	
kokia_komanda_pab:
RET
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------
gauti_komandos_varda:
	mov komandos_pav, 0
	cmp regas, 110b
	je tai_DIV
	cmp regas, 111b
	je tai_IDIV
	cmp regas, 000b
	je tai_TEST3

tai_DIV: 
	mov komandos_pav, offset komanda_DIV
	mov komandos_pav_ilgis, 4
	jmp gauti_komandos_varda_pab
tai_IDIV: 
	mov komandos_pav, offset komanda_IDIV
	mov komandos_pav_ilgis, 5
	jmp gauti_komandos_varda_pab	
tai_TEST3:
	mov komandos_pav, offset komanda_TEST
	mov komandos_pav_ilgis, 5
	mov betarpiskas_operandas, 1h
	add komandos_ilgis, 4
	cmp wBitas, 1h
	je gauti_komandos_varda_pab
	dec komandos_ilgis
	jmp gauti_komandos_varda_pab

	gauti_komandos_varda_pab:
RET

; gauti_komandos_varda_TEST:
; 	mov komandos_pav, 0
; 	cmp regas, 000b
; 	je tai_DIV
; 	cmp regas, 001b
; 	je tai_IDIV
; 	cmp regas, 010b
; 	je tai_TEST3

; tai_DIV: 
; 	mov komandos_pav, offset komanda_DIV
; 	mov komandos_pav_ilgis, 4
; 	jmp gauti_komandos_varda_pab
; tai_IDIV: 
; 	mov komandos_pav, offset komanda_IDIV
; 	mov komandos_pav_ilgis, 5
; 	jmp gauti_komandos_varda_pab	
; tai_TEST3:
; 	mov komandos_pav, offset komanda_TEST
; 	mov komandos_pav_ilgis, 5
; 	mov betarpiskas_operandas, 1h
; 	add komandos_ilgis, 4
; 	cmp wBitas, 1h
; 	je gauti_komandos_varda_pab
; 	dec komandos_ilgis
; 	jmp gauti_komandos_varda_pab

; 	gauti_komandos_varda_pab:
; RET
;-----------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------
spausdink_operanda:
	push ax
	push bx
	push cx
	push dx
	
	
	cmp modas, 11b
	je operandas_registras
	jmp operandas_atmintyje

;=======================================================================================================================

operandas_registras:
	cmp dBitas,  0h
	je tikrinam_rega_relative

	cmp remas, 000b
	je rm_11_000
	cmp remas, 001b
	je rm_11_001
	cmp remas, 010b
	je rm_11_010
	cmp remas, 011b
	je rm_11_011

	cmp remas, 100b
	je rm_11_100
	cmp remas, 101b
	je rm_11_101
	cmp remas, 110b
	je rm_11_110
	cmp remas, 111b
	je rm_11_111
	
;========================================================================================================================

rm_11_000:
	cmp wBitas, 0
	je rmw_11_000_0
	jmp rmw_11_000_1
	
rm_11_001:
	cmp wBitas, 0
	jne l7
	jmp rmw_11_001_0
l7:
	jmp rmw_11_001_1
	
rm_11_010:
	cmp wBitas, 0
	jne l1
	jmp rmw_11_010_0
l1:
	jmp rmw_11_010_1
	
rm_11_011:
	cmp wBitas, 0
	jne l2
	jmp rmw_11_011_0
l2:
	jmp rmw_11_011_1
	tikrinam_rega_relative:
	jmp tikrinam_rega
;---------------------------
rm_11_100:
	cmp wBitas, 0
	jne l3
	jmp rmw_11_100_0
l3:
	jmp rmw_11_100_1
	
rm_11_101:
	cmp wBitas, 0
	jne l4
	jmp rmw_11_101_0
l4:
	jmp rmw_11_101_1
	
rm_11_110:
	cmp wBitas, 0
	jne l5
	jmp rmw_11_110_0
l5:
	jmp rmw_11_110_1
	
rm_11_111:
	cmp wBitas, 0
	jne l6
	jmp rmw_11_111_0
l6:
	jmp rmw_11_111_1
;================================================================================
rmw_11_000_0:
	mov operando_offset, offset registrasAL
	jmp spausdink_operanda_pab
rmw_11_001_0:
	mov operando_offset, offset registrasCL
	jmp spausdink_operanda_pab
rmw_11_010_0:
	mov operando_offset, offset registrasDL
	jmp spausdink_operanda_pab
rmw_11_011_0:
	mov operando_offset, offset registrasBL
	jmp spausdink_operanda_pab
;-----------------------
rmw_11_100_0:
	mov operando_offset, offset registrasAH
	jmp spausdink_operanda_pab
rmw_11_101_0:
	mov operando_offset, offset registrasCH
	jmp spausdink_operanda_pab
rmw_11_110_0:
	mov operando_offset, offset registrasDH	
	jmp spausdink_operanda_pab
rmw_11_111_0:
	mov operando_offset, offset registrasBH
	jmp spausdink_operanda_pab
;--------------------------------------------
rmw_11_000_1:
	mov operando_offset, offset registrasAX
	jmp spausdink_operanda_pab
rmw_11_001_1:
	mov operando_offset, offset registrasCX
	jmp spausdink_operanda_pab
rmw_11_010_1:
	mov operando_offset, offset registrasDX
	jmp spausdink_operanda_pab
rmw_11_011_1:
	mov operando_offset, offset registrasBX
	jmp spausdink_operanda_pab
;-----------------------
rmw_11_100_1:
	mov operando_offset, offset registrasSP
	jmp spausdink_operanda_pab
rmw_11_101_1:
	mov operando_offset, offset registrasBP
	jmp spausdink_operanda_pab
rmw_11_110_1:
	mov operando_offset, offset registrasSI
	jmp spausdink_operanda_pab
rmw_11_111_1:
	mov operando_offset, offset registrasDI
	jmp spausdink_operanda_pab
;--------------------------
;jei dBitas 0 tikrinam rega vietoj r/m
;---------------------------
tikrinam_rega:
	cmp regas, 000b
	je rg_11_000
	cmp regas, 001b
	je rg_11_001
	cmp regas, 010b
	je rg_11_010
	cmp regas, 011b
	je rg_11_011

	cmp regas, 100b
	je rg_11_100
	cmp regas, 101b
	je rg_11_101
	cmp regas, 110b
	je rg_11_110
	cmp regas, 111b
	je rg_11_111
;========================================================================================================================
rg_11_000:
	cmp wBitas, 0
	je rgw_11_000_0
	jmp rgw_11_000_1
	
rg_11_001:
	cmp wBitas, 0
	jne q7
	jmp rgw_11_001_0
q7:
	jmp rgw_11_001_1
	
rg_11_010:
	cmp wBitas, 0
	jne q1
	jmp rmw_11_010_0
q1:
	jmp rgw_11_010_1
	
rg_11_011:
	cmp wBitas, 0
	jne q2
	jmp rgw_11_011_0
q2:
	jmp rgw_11_011_1
;---------------------------
rg_11_100:
	cmp wBitas, 0
	jne q3
	jmp rgw_11_100_0
q3:
	jmp rgw_11_100_1
	
rg_11_101:
	cmp wBitas, 0
	jne q4
	jmp rgw_11_101_0
q4:
	jmp rgw_11_101_1
	
rg_11_110:
	cmp wBitas, 0
	jne q5
	jmp rgw_11_110_0
q5:
	jmp rgw_11_110_1
	
rg_11_111:
	cmp wBitas, 0
	jne q6
	jmp rgw_11_111_0
q6:
	jmp rgw_11_111_1
;================================================================================
	rgw_11_000_0:
	mov operando_offset, offset registrasAL
	jmp spausdink_operanda_pab
rgw_11_001_0:
	mov operando_offset, offset registrasCL
	jmp spausdink_operanda_pab
rgw_11_010_0:
	mov operando_offset, offset registrasDL
	jmp spausdink_operanda_pab
rgw_11_011_0:
	mov operando_offset, offset registrasBL
	jmp spausdink_operanda_pab
;-----------------------
rgw_11_100_0:
	mov operando_offset, offset registrasAH
	jmp spausdink_operanda_pab
rgw_11_101_0:
	mov operando_offset, offset registrasCH
	jmp spausdink_operanda_pab
rgw_11_110_0:
	mov operando_offset, offset registrasDH	
	jmp spausdink_operanda_pab
rgw_11_111_0:
	mov operando_offset, offset registrasBH
	jmp spausdink_operanda_pab
;--------------------------------------------
rgw_11_000_1:
	mov operando_offset, offset registrasAX
	jmp spausdink_operanda_pab
rgw_11_001_1:
	mov operando_offset, offset registrasCX
	jmp spausdink_operanda_pab
rgw_11_010_1:
	mov operando_offset, offset registrasDX
	jmp spausdink_operanda_pab
rgw_11_011_1:
	mov operando_offset, offset registrasBX
	jmp spausdink_operanda_pab
;-----------------------
rgw_11_100_1:
	mov operando_offset, offset registrasSP
	jmp spausdink_operanda_pab
rgw_11_101_1:
	mov operando_offset, offset registrasBP
	jmp spausdink_operanda_pab
rgw_11_110_1:
	mov operando_offset, offset registrasSI
	jmp spausdink_operanda_pab
rgw_11_111_1:
	mov operando_offset, offset registrasDI
	jmp spausdink_operanda_pab

;-----------------------------------------------------------------------------------------------------------------------
spausdink_operanda_pab: ;registro spausdinimas
	mov ah, 40h
	mov bx, handler2
	mov cx,  2
	mov dx, operando_offset
	int 21h
	
	pop dx
	pop cx
	pop bx
	pop ax
RET
;-----------------------------------------------------------------------------------------------------------------------
operandas_atmintyje:
	jmp operando_atmintyje_spausdinimas
;-----------------------------------------------------------------------------------------------------------------------
operando_atmintyje_spausdinimas:
	cmp wBitas, 0
	je spausdinti_byte_ptr
	jmp spausdinti_word_ptr
	
spausdinti_byte_ptr:
	mov ah, 40h
	mov bx, handler2
	mov cx,  9
	mov dx, offset byte_ptr
	int 21h
	jmp testi
spausdinti_word_ptr:
	mov ah, 40h
	mov bx, handler2
	mov cx,  9
	mov dx, offset word_ptr
	int 21h
	jmp testi
;-----------------------------------------------------------------------------------------------------------------------
testi:
;-----------------------------------------------------------------------------------------------------------------------
;Isspausdinamas prefiksas
;-----------------------------------------------------------------------------------------------------------------------
	mov ah, 40h
	mov bx, handler2
	mov cx,  3
	mov dx, offset prefiksas_spausd
	int 21h
;-----------------------------------------------------------------------------------------------------------------------
;Tikrinama ar tiesioginis adresas (jei ne - jumpina)
;-----------------------------------------------------------------------------------------------------------------------	
	cmp modas, 00 ;Del tiesioginio adreso
	jne ne_tiesiog
	cmp dBitas,  0h
	je cia 
	cmp remas, 110b
	jne ne_tiesiog
	jmp tiesiog
cia:
	cmp regas, 110b
	jne ne_tiesiog_reg
	jmp tiesiog
;-----------------------------------------------------------------------------------------------------------------------
tiesiog:
	mov ah, 40h
	mov bx, handler2
	mov cx,  1
	mov dx, offset tiesiog1
	int 21h
		call kitas_baitas
		mov dl, al
		call kitas_baitas
		mov dh, al
		mov ax, dx
		call printAX
	mov ah, 40h
	mov bx, handler2
	mov cx,  2
	mov dx, offset tiesiog2
	int 21h
	jmp  spausd_reiksmes
;-----------------------------------------------------------------------------------------------------------------------
ne_tiesiog:
	cmp dBitas, 0h
	je ne_tiesiog_reg

	cmp remas, 000b
	je rw_000
	
	cmp remas, 001b
	je rw_001
	
	cmp remas, 010b
	je rw_010
	
	cmp remas, 011b
	je rw_011
	
	cmp remas, 100b
	je rw_100
	
	cmp remas, 101b
	je rw_101
	
	cmp remas, 110b
	je rw_110
	
	cmp remas, 111b
	je rw_111
;-------------------------------------------------
ne_tiesiog_reg:
	cmp regas, 000b
	je rw_000
	
	cmp regas, 001b
	je rw_001
	
	cmp regas, 010b
	je rw_010
	
	cmp regas, 011b
	je rw_011
	
	cmp regas, 100b
	je rw_100
	
	cmp regas, 101b
	je rw_101
	
	cmp regas, 110b
	je rw_110
	
	cmp regas, 111b
	je rw_111
	
rw_000: 
	mov operando_offset, offset rm_000
	jmp toliau

rw_001: 
	mov operando_offset, offset rm_001
	jmp toliau

rw_010: 
	mov operando_offset, offset rm_010
	jmp toliau

rw_011: 
	mov operando_offset, offset rm_011
	jmp toliau
	
rw_100: 
	mov operando_offset, offset rm_100
	jmp toliau
	
rw_101: 
	mov operando_offset, offset rm_101
	jmp toliau	
	
rw_110: 
	mov operando_offset, offset rm_110
	jmp toliau
	
rw_111: 
	mov operando_offset, offset rm_111
	jmp toliau
	
toliau:
	mov ah, 40h
	mov bx, handler2
	mov cx,  6
	mov dx, operando_offset
	int 21h

	cmp modas, 00b
	je toliau2
	cmp modas, 01b
	je poslinkis_1baito
	cmp modas, 10b
	je poslinkis_2baitu
	
poslinkis_1baito:
	mov ah, 40h
	mov bx, handler2
	mov cx,  1
	mov dx, offset pliusas
	int 21h
	call kitas_baitas
	call printAL
	jmp toliau2
	
poslinkis_2baitu:
	mov ah, 40h
	mov bx, handler2
	mov cx,  1
	mov dx, offset pliusas
	int 21h
	call kitas_baitas
	mov dl, al
	call kitas_baitas
	mov dh, al
	mov ax, dx
	call printAX
	jmp toliau2

toliau2:
	mov ah, 40h
	mov bx, handler2
	mov cx,  1
	mov dl, kvad_skliaust
	int 21h
	
spausd_reiksmes:
	;mov ah, 2
	;mov dl, ";"
	;int 21h
	
	pop dx
	pop cx
	pop bx
	pop ax
RET
;-----------------------------------------------------------------------------------------------------------------------
spausdinti_masinini_koda:
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov si, komandos_pradzia
	mov ch, 0
	mov cl, komandos_ilgis
	
ciklas:
	mov al, buff[si]
	inc si
	call printAL
	loop ciklas
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
RET
;------------------------------------------------------------------------------------------------------
;Spausdinti AX reiksme
;------------------------------------------------------------------------------------------------------
printAX:
	push ax
	mov al, ah
	call printAL
	pop ax
	call printAL
RET
;------------------------------------------------------------------------------------------------------
;Spausdinti tarpa
;------------------------------------------------------------------------------------------------------
printSpace:
	push ax
	push dx
		mov ah, 40h
		mov bx, handler2
		mov cx,  1
		mov dx, offset space
		int 21h
	pop dx
	pop ax
RET
;------------------------------------------------------------------------------------------------------
;>>>Spausdinti AL reiksme
;------------------------------------------------------------------------------------------------------
printAL:
	push ax
	push cx
		push ax
		mov cl, 4
		shr al, cl
		call printHexSkaitmuo
		pop ax
		call printHexSkaitmuo
	pop cx
	pop ax
RET

;>>>Spausdina hex skaitmeni pagal AL jaunesniji pusbaiti (4 jaunesnieji bitai - > AL=72, tai 0010)
printHexSkaitmuo:
	push ax
	push dx
	
	and al, 0Fh ;nunulinam vyresniji pusbaiti AND al, 00001111b
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F:
	mov  skaitmuo, al
	add skaitmuo, 37h
	mov dx, offset skaitmuo
	mov ah, 40h
	mov bx, handler2
	mov cx,  1; spausdiname simboli (A-F) is DL'o
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: ;0-9
	mov skaitmuo, al
	add skaitmuo, 30h
	mov dx, offset skaitmuo
	mov ah, 40h
	mov bx, handler2
	mov cx,  1 ;spausdiname simboli (0-9) is DL'o
	int 21h
	jmp printHexSkaitmuo_grizti
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
RET

END

BSeg SEGMENT

ORG 100h
ASSUME ds:BSeg, cs:BSeg, ss:BSeg

start:
	div bx
	div ax
	div al
	idiv bx	  
	idiv ax
	idiv al
	div handle1
	idiv sk
	idiv si
	in ax, 5h
	in ax, 58h
	in ax, dx
	in al, dx
	
    test ax, ax
    test bx, ax
    test bl, al
	test bx, cx
	test ax, 45ABh
	test handle1, 3501h

	xchg al, ah
	xchg bh, cl
	xchg cl, bl

	xchg ax, dx
	xchg bx, dx
    
	int 21h
	int 1h
	int 5h
	iret  


m dw 1234h
  dw 5678h
sk db ?
sk2 dw 9312
handle1 dw  ?


BSeg ENDS

END start
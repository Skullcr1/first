
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
	test handle1, ax ;fails
	test ax, 45ABh
	test handle1, 3501h
	test sk, 12h


	xchg ax, ax    
	xchg bx, ax    
	xchg dx, ax
	xchg cx, ax
	xchg ah, al
	xchg ah, dl
	xchg ch, al
	les bx, sk2
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
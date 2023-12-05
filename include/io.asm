;[bx] = text
;cx = len
print:
	pusha
	mov ah, 0x0e
.loop:
	mov al, [bx]
	int 0x10
	inc bx
	dec cx
	jnz .loop
	popa
    ret

;eax = int to print
prInt:
	pusha
	xor cx, cx
	mov esi, 10
.loop:
	xor edx, edx
	div esi
	push edx
	inc cx
	cmp eax, 0
	jne .loop
.print:
	pop eax
	or al, 0x30
	mov ah, 0x0e
	int 0x10
	dec cx
	jnz .print
	popa
	ret
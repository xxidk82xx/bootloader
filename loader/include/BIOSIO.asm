; bx = pointer to string
printString:
	pusha
	mov ah, 0x0e
.loop:
	mov al, [bx]
	int 0x10
	inc bx
	cmp [bx], byte 0x00
	jne .loop
	popa
	ret

;bx = pointer to string
newLine: db 0xA, 0xD
printLine:
	call printString
	mov bx, newLine
	mov cx, 2
	call print


;bx = pointer to text
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

;eax = number to print
prHex:
	pusha
	xor cx, cx
	mov esi, 16
.loop:
	xor edx, edx
	div esi
	push edx
	inc cx
	cmp eax, 0
	jne .loop
.print:
	pop eax
	cmp eax, 10
	jl .B10
	add al, 0x27
.B10:
	add al, 0x30
	mov ah, 0x0e
	int 0x10
	dec cx
	jnz .print
	mov al, 'h'
	int 0x10
	popa
	ret

;eax = string 1 position
;ebx = string 2 position
;cx  =  len
;->
;cf set if equal
cmpStr:
	push ebx
	push dx
	clc
.loop:
	mov dl, [eax]
	cmp dl, [ebx]
	jne .noteq
	inc eax
	inc ebx
	dec cx	
	jnz .loop
.eq:
	stc
	pop dx 
	pop ebx
	ret
.noteq:
	pop dx
	pop ebx
	clc
	ret
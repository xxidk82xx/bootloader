JMPBOOT:    jmp boot
nop
name:		db 'Bossman '
secSz:		dw 0x0200
clusSz:		db 0x04
rsvdSecCnt:	dw 0x0004
numFats:	db 0x02
rootEntCnt:	dw 0x0200
totalSec16:	dw 0x0800
media:		db 0xf8
FATSz16:	dw 0x0020
secPerTrk:	dw 0x0020
numHeads:	dw 0x0002
hiddenSec:	dd 0x00000000
totalSec32:	dd 0x00000000
;fat12 specific
driveNum:	db 0x80
NTReserved:	db 0x00
bootSig:	db 0x29
volID:		dd 0x2905a69d
volLab:		db 'NO NAME    '
FSType:		db 'FAT16   '
boot:
[org 0x7c00]  
mov [driveNum], dl
xor eax, eax                          
mov es, ax
mov ds, ax
mov bp, 0x8000
mov sp, bp

mov al, 1
mov cl, [rsvdSecCnt]
mov bx, 0x1000
call readDisk


mov bp, 0x1000
mov cx, 11
call print

jmp $

fuck:
	call debp
	hlt
	jmp $



prInt:
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
	ret

debp:
pusha
	mov al, 'A'
	mov ah, 0x0e
	int 0x10
popa
	ret

print:
	mov ah, 0x0e
.loop:
	mov al, [bp]
	int 0x10
	inc bp 
	dec cx
	jnz .loop
    ret



;al sectors to read
;cl start sector + 1
readDisk:
	inc cl
.loop:
	mov ah, 0x0a
	xor ch, ch
	xor dh, dh
	mov dl, 0x80
	int 0x13
	jnc .succ

	push ax
	mov ah, 0x0e
	mov al, 'E'
	int 0x10

	pop ax
	mov al, ah
	and eax, 0xff
	call prInt

	xor ah, ah
	mov dl, [driveNum]
	int 0x13
	jmp .loop
.succ:
	ret

rootDir dw 0

times 510-($-$$) db 0
dw 0xaa55
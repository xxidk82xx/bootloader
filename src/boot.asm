JMPBOOT:    jmp boot
nop
name:		db 'Bossman'
secSz:		dw 0x0200
clusSz:		db 0x04
rsvdSecCnt:	dw 0x0020
numFats:	db 0x02
rootEntCnt:	dw 0x0000
totalSec16:	dw 0x0000
media:		db 0xf8
FATSz16:	dw 0x0000
secPerTrk:	dw 0x0000
numHeads:	dw 0x0000
hiddenSec:	dd 0x00000000
totalSec32:	dd 0x00200000
;fat32 specific
FATSz32:	dd 0x00001000
extFlags:	dw 0x0000
fsVer:		dw 0x0000
rootClus:	dd 0x00000000
fsInfo:		dw 0x0000
BKBootSec:	dw 0x0006
rsvd:		times 12 db 0x00
driveNum:	db 0x80
NTReserved:	db 0x00
bootSig:	db 0x29
volID:		dd 0x00000000
volLab:		db 'NO NAME    '
FSType:		db 'FAT32   '
KERNEL_LOCATION equ 0x600
boot:
[org 0x7c00]  
mov [BOOT_DISK], dl
xor eax, eax                          
mov es, ax
mov ds, ax
mov bp, 0x8000
mov sp, bp

mov bx, KERNEL_LOCATION
mov al, 1
call readDisk
pusha
mov bp, KERNEL_LOCATION + 2
mov cx, [KERNEL_LOCATION]
call print
popa

jmp $

readDisk:
	mov ah, 0x02
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0
	mov dl, [driveNum]
	int 0x13
	jc .code
.secRead:
	pusha
    mov bp, readT
    mov cx, [readTL]
	call print
    popa
	and eax, 0xff
	call prInt
	ret
.code:
	pusha
    mov bp, errortext
    mov cx, [errortextL]
	call print
    popa
	mov ah, al
	and eax, 0xff
	call prInt
	ret


readT db "read sectors, count = "
readTL dw $-readT

errortext db ' disk read code = '
errortextL dw $-errortext 

BOOT_DISK db 0

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
	cmp cx, 0
	jg .print
	ret

debp:
	mov al, 'A'
	mov ah, 0x0e
	int 0x10
	ret

print:
	mov ah, 0x0e
.loop:
	mov al, [bp]
	int 0x10
	inc bp 
	dec cx
	cmp cx, 0
	jg .loop
    ret

times 510-($-$$) db 0
dw 0xaa55
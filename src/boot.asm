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

mov ax, [numFats]
mul word [FATSz16]
mov [rootDir], ax
add ax, 4
mov bx, 0x1000
call readDisk

call getDataSec
mov ax, [dataSec]
call prInt

call readBoot

jmp $

fuck:
	call debp
	hlt
	jmp $

dataSec: dw 0
getDataSec:
	mov ax, [rootEntCnt]
	mov bx, 32
	mul bx
	;add ax, [secSz]
	;dec ax
	div word [secSz]
	add ax, [rootDir]
	add ax, [rsvdSecCnt]
	mov [dataSec], ax
	ret


bootName: db 'BOOT       '
readBoot:
	mov ax, bootName
	mov bx, 0x1020
.loop:
	mov cl, [eax]
	cmp cl, [bx]
	jne .notBoot
	inc ax
	inc bx
	cmp ax, bootName + 11
	jl .loop
.printName:
	mov bx, 0x1020
	mov cx, 11
	call print
.isDir:
	mov bx, [0x102b]
	xor eax, eax
	mov ax, bx
	cmp ax, 0x10
	jne .notBoot
.findBin:
	mov ax, [0x103a]
	sub ax, 2
	xor bx, bx
	mov bl , [clusSz]
	mul bx
	add ax, [dataSec]
	call prInt
	ret

.notBoot:
	mov ah, 0x0e
	mov al, 'b'
	int 0x10
	jmp $


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

debp:
pusha
	mov al, ':'
	mov ah, 0x0e
	int 0x10
popa
	ret

;bx = text
;cx = len
print:
	push ax
	mov ah, 0x0e
.loop:
	mov al, [bx]
	int 0x10
	inc bx
	dec cx
	jnz .loop
	pop ax
    ret

SPT: dW 63
HPC: dW 16
SPTXHPC: dw 1008

;ax sector
;to
;ax cyl
;bx head
;cx sector
toCHS:
	push dx
	xor dx, dx
	div WORD [SPT] ;dx = sectors ax = cyl * hpc
	inc dx
	push dx
	xor dx, dx
	div word [HPC] ;ax = cyl dx = head
	mov bx, dx
	pop cx
	pop dx
	ret

;ax start sector
;es:bx position to read to
readDisk:
	push bx
	call toCHS
	mov ch, al
	mov dh, bl
	mov al, cl
	pop bx
.loop:
	mov ah, 0x02
	mov dl, 0x80
	push ax
	int 0x13
	pop ax
	jnc .succ

	mov ah, 0x0e
	mov al, 'E'
	int 0x10

	xor ah, ah
	mov dl, [driveNum]
	int 0x13
	jmp .loop
.succ:
	ret

rootDir dw 0

times 510-($-$$) db 0
dw 0xaa55
JMPBOOT:    jmp boot
nop
FSname:		db 'Bossman '
secSz:		dw 0x0200
clusSz:		db 0x04
rsvdSecCnt:	dw 0x0004
numFats:	db 0x02
rootEntCnt:	dw 0x0200
totalSec16:	dw 0x0800
media:		db 0xf8
FATSz16:	dw 0x0020
secPerTrk:	dw 0x003f
numHeads:	dw 0x00ff
hiddenSec:	dd 0x00080000
totalSec32:	dd 0x00000000
;fat12 specific
driveNum:	db 0x80
NTReserved:	db 0x00
bootSig:	db 0x29
volID:		dd 0x2905a69d
volLab:		db 'NO NAME    '
FSType:		db 'FAT16   '

FAT_LOCATION equ 0x800
KERNEL_LOCATION equ 0x1000

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
mov bx, KERNEL_LOCATION
mov cx, 1
call readDisk

mov ax, 4
mov bx, FAT_LOCATION
mov cx, 1
call readDisk

mov ax, [rootEntCnt]
mov bx, 32
mul bx
div word [secSz]
add ax, [rootDir]
add ax, [rsvdSecCnt]
mov [dataSec], ax

call readBoot
jmp $

dataSec: dw 0

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

;eax = target name
;ebx = offset
;edx = distance to search
;->
;ebx = entryOffset
;cf set if nonexistant
findDirEnt:
	clc
	push cx
.search:
	mov cx, 11
	call cmpStr
	jc .found
	add ebx, 0x20
	dec edx
	jnz .search
.notFound:
	stc
	pop cx
	ret
.found:
	pop cx
	ret

bootDName: db 'BOOT       '
bootFName: db 'BOOT    BIN'
readBoot:
	mov eax, bootDName
	mov ebx, KERNEL_LOCATION
	mov edx, 0x0200
	call findDirEnt
	mov cx, 11
	call print
.findBin:
	mov eax, ebx
	call readFile
	mov eax, bootFName
	mov ebx, KERNEL_LOCATION
	add edx, [clusSz]
	call findDirEnt
	mov cx, 11
	call print
	mov eax, ebx
	call readFile
	mov bx, KERNEL_LOCATION
	mov cx, 0x11
	call print
	ret

;ax = active cluster
;FAT_LOCATION = FAT location in memory (i know its a constant and i dont care)
;bx = save location
readFileFAT:
.loop:
	mov ax, [eax]
	cmp ax, 0xffff
	je .eof
	call readClus
	push bx
	mov ebx, 2
	mul ebx
	pop bx
	add eax, FAT_LOCATION
	jmp .loop
.eof:
	ret

;eax = pointer to cluster
readClus:
	push ax
	call clusToOffs
	mov cx, [clusSz]
	call readDisk
	pop ax
	ret
	
;eax = entry location
;->
;0x1000 cluster location
readFile:
	pusha
	add eax, 26
.clusLoop:
	mov bx, KERNEL_LOCATION
	call readFileFAT
	popa
	ret


;ax = cluster
;->
;eax = sector
clusToOffs:
	push bx
	sub ax, 2
	xor bx, bx
	mov bl ,[clusSz]
	mul bx
	add ax, [dataSec]
	pop bx
	ret

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

SPT: dW 63
HPC: dW 16

;ax sector
;to
;dh = head number
;ch = cylinder number
;cl = sectors to read
toCHS:
	xor dx, dx
	div WORD [SPT] ;dx = sectors ax = cyl * hpc
	inc dx
	mov cl, dl
	xor dx, dx
	div word [HPC] ;ax = cyl dx = head
	mov ch, al
	mov dh, dl
	ret

;ax start sector
;es:bx position to read to
;cx = sectors to read
readDisk:
	push cx
	call toCHS
	pop ax
.loop:
	mov ah, 0x02
	mov dl, 0x80
	int 0x13
	jnc .succ

	;call debp

	xor ah, ah
	mov dl, [driveNum]
	int 0x13
	jmp .loop
.succ:
	ret

rootDir dw 0

times 510-($-$$) db 0
dw 0xaa55
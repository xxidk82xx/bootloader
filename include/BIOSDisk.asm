fatLocation: dd 0x0000
fsInfo:
FSname:		db 'Bossman '
secSz:		dw 0x0200
clusSz:		db 0x04
rsvdSecCnt:	dw 0x0004
numFats:	db 0x02
rootEntCnt:	dw 0x0200
totalSec16:	dw 0x7cf8
media:		db 0xf8
FATSz16:	dw 0x0020
secPerTrk:	dw 0x003e
numHeads:	dw 0x007c
hiddenSec:	dd 0x00080000
totalSec32:	dd 0x00000000
;fat12 specific
driveNum:	db 0x80
NTReserved:	db 0x00
bootSig:	db 0x29
volID:		dd 0x2905a69d
volLab:		db 'NO NAME    '
FSType:		db 'FAT16   '
dataSec: dw 0
SPT: dW 63
HPC: dW 16
infoEnd:

;eax = entry location
;ebx = storage location
;->
;[ebx] = file
readFile:
	pusha
	add eax, 26
	call readFATClus
	popa
	ret

;eax = active cluster
;fatLocation = FAT location in memory
;ebx = save location
readFATClus:
.loop:
	mov ax, [eax]
	cmp ax, 0xffff
	je .eof
	call readClus
	push ebx
	mov ebx, 2
	mul ebx
	pop ebx
	add eax, [fatLocation]
	jmp .loop
.eof:
	ret

;es:bx = location to store FAT
readFAT:
	pusha
	mov cx, [FATSz16]
	mov ax, [rsvdSecCnt]
	call readDisk
	popa

;eax = pointer to cluster
;->
;eax = cluster read
readClus:
	call clusToOffs
	mov cx, [clusSz]
	call readDisk
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

	mov ah, 0x0e
	mov al, 'E'
	int 0x10

	xor ah, ah
	mov dl, [driveNum]
	int 0x13
	jmp .loop
.succ:
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

;ax sector
;to
;dh = head number
;ch = cylinder number
;cl = sectors to read
toCHS:
	push ax
	xor dx, dx
	div WORD [SPT] ;dx = sectors ax = cyl * hpc
	inc dx
	mov cl, dl
	xor dx, dx
	div word [HPC] ;ax = cyl dx = head
	mov ch, al
	mov dh, dl
	pop ax
	ret

readBoot:
	pusha
	mov cx, fsInfo - infoEnd
	mov eax, fsInfo
	mov ebx, 0x7c00
.loop:
	mov dx, [ebx]
	mov [eax], dx
	inc ax
	inc bx
	dec cx
	jnz .end
.end:
	popa
	ret
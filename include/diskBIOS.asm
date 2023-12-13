fatLocation dd 0x0000

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

;eax = boot record
;es:bx = location to store FAT
readFAT:
	pusha
	add ax, 14
	push ax
	add ax, 8
	mov cx, [eax]
	pop ax
	mov ax, [eax]
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
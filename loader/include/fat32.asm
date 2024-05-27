HPC: dw 16

;ax sector
;es:di drive fsinfo
;to
;dh = head number
;ch = cylinder number
;cl = sectors to read
toCHS:
	push ax
	xor dx, dx
    add di, 24
	div WORD [di] ;dx = sectors ax = cyl * hpc
	inc dx
	mov cl, dl
	xor dx, dx
	div word [HPC] ;ax = cyl dx = head
	mov ch, al
	mov dh, dl
	pop ax
	ret

;ax = cluster
;es:di fsinfo
;->
;eax = sector
clusToOffs:
	push bx, di
	sub ax, 2
	xor bx, bx
    add di, 13
	mov bl ,[di]
	mul bx
	pop bx, di
	ret
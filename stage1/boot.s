.global _start
.section fsinfo
JMPBOOT:    jmp boot
nop
FSname:		.byte "Bossman "
secSz:		.word 0x0200
clusSz:		.byte 0x04
rsvdSecCnt:	.word 0x0004
numFats:	.byte 0x02
rootEntCnt:	.word 0x0200
totalSec16:	.word 0x7cf8
media:		.byte 0xf8
FATSz16:	.word 0x0020
secPerTrk:	.word 0x003e
numHeads:	.word 0x007c
hiddenSec:	.long 0x00080000
totalSec32:	.long 0x00000000
//fat12 specific
driveNum:	.byte 0x80
NTReserved:	.byte 0x00
bootSig:	.byte 0x29
volID:		.long 0x2905a69d
volLab:		.byte "NO NAME    "
FSType:		.byte "FAT16   "
dataSec: .word 0
SPT: .word 63
HPC: .word 16

#define FAT_LOCATION 0x800
#define KERNEL_LOCATION 0x1000
.data
boot: 
movb (driveNum), %dl
movl $0x07c0, %eax                          
movw %dx, %sp
movw %ax, %ds
movw $0x8000, %bp
movw %bp, %sp

movw (numfats), %ax
imul (FATSz16), %ax
movw (rootDir), %ax
add $4, %ax
movw $KERNEL_LOCATION, %bx
movw $1, %cx
call readDisk

movw $4, %ax
movw $FAT_LOCATION, %bx
movw $1, %cx
call readDisk

imul $32, (rootEntCnt), %ax
idivw (secSz)
add (rootDir), %ax
add (rsvdSecCnt), %ax
movw %ax, (dataSec)

call readBoot
ljmp $0x07c0, $KERNEL_LOCATION
jmp .



//eax = string 1 position
//ebx = string 2 position
//cx  =  len
//->
//cf set if equal
cmpStr:
	push %ebx
	push %dx
	clc
.loop:
	movb (%eax), %dl
	cmp (%ebx), %dl
	jne .noteq
	incl %eax
	incl %ebx
	decw %cx	
	jnz .loop
.eq:
	stc
	pop %dx 
	pop %ebx
	ret
.noteq:
	pop %dx
	pop %ebx
	clc
	ret

//eax = target name
//ebx = offset
//edx = distance to search
//->
//ebx = entryOffset
//cf set if nonexistant
findDirEnt:
	clc
	push %cx
.search:
	movw $11, %cx
	call cmpStr
	jc .found
	add 0x20, %ebx
	dec %edx
	call debp
	jnz .search
.notFound:
	stc
	pop %cx
	ret
.found:
	pop %cx
	ret

bootDName: .byte "BOOT       "
bootFName: .byte "BOOT    BIN"
readBoot:
	movl $bootDName, %eax
	movl $KERNEL_LOCATION, %ebx
	movl $0x0200, %edx
	call findDirEnt
	movw $11, %cx
	call print
_findBin:
	movl %ebx, %eax
	call readFile
	movl $bootFName, %eax
	movl $KERNEL_LOCATION, %ebx
	add (clusSz), %edx
	call findDirEnt
	movw $11, %cx
	call print
	movl %ebx, %eax
	call readFile
	ret

//ax = active cluster
//FAT_LOCATION = FAT location in memory (i know its a constant and i dont care)
//bx = save location
readFileFAT:
_loop:
	mov (eax), %ax
	cmp $0xffff, %ax
	je _eof
	call readClus
	push %bx
	imul $2, %eax
	pop %bx
	add $FAT_LOCATION, %eax
	jmp _loop
_eof:
	ret

//eax = pointer to cluster
readClus:
	push %ax
	call clusToOffs
	movw (clusSz), %cx
	call readDisk
	pop %ax
	ret
	
//eax = entry location
//->
//0x1000 cluster location
readFile:
	pusha
	add $26, %eax
_clusLoop:
	movw $KERNEL_LOCATION, %bx
	call readFileFAT
	popa
	ret


//ax = cluster
//->
//eax = sector
clusToOffs:
	push %bx
	sub $2, %ax
	xor %bx, %bx
	movb (clusSz), %bl
	imul %ax, %bx
	add (dataSec), %ax
	pop %bx
	ret

prInt:
	pusha
	xor %cx, %cx
	mov $10, %esi
__loop:
	xor %edx, %edx
	idiv %esi
	push %edx
	inc %cx
	cmp $0, %eax
	jne __loop
_print:
	pop %eax
	or $0x30, %al
	movb $0x0e, %ah
	int $0x10
	dec %cx
	jnz _print
	popa
	ret

debp:
pusha
	movb ":", %al
	movb $0x0e, %ah
	int $0x10
popa
	ret

//bx = text
//cx = len
print:
	pusha
	movb $0x0e, %ah
___loop:
	movb (%bx), %al
	int $0x10
	inc %bx
	dec %cx
	jnz ___loop
	popa
    ret



//ax sector
//to
//dh = head number
//ch = cylinder number
//cl = sectors to read
toCHS:
	xor %dx, %dx
	idivw (SPT) //dx = sectors ax = cyl * hpc
	inc %dx
	mov %dl, %cl
	xor %dx, %dx
	idivw (HPC) //ax = cyl dx = head
	mov %al, %ch
	mov %dl, %dh
	ret

//ax start sector
//es:bx position to read to
//cx = sectors to read
readDisk:
	push %cx
	call toCHS
	pop %ax
____loop:
	movb $0x02, %ah
	movb $0x80, %dl
	int $0x13
	jnc .succ

	//call debp

	xor %ah, %ah
	movb (driveNum), %dl
	int $0x13
	jmp ____loop
.succ:
	ret

rootDir: .word 0


.org 510
.word 0xaa55

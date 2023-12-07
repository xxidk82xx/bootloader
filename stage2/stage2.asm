[org 0x1000]
mov ah, 0x0e
mov al, 'F'
int 0x10
jmp entry
%include "include/io.asm"

entry:
mov ah, 0x0e
mov al, 'G'
int 0x10
mov cx, 10
mov bx, te
call print
mov eax, 0x1a9f
call prHex
jmp $

te: db 'testTextAB'
jmp $
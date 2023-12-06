[org 0x1000]
mov ah, 0x0e
mov al, 'Q'
int 0x10
jmp entry
%include "include/io.asm"

entry:
mov ah, 0x0e
mov al, 'Q'
int 0x10
mov cx, 8
mov bx, te
call print
mov ax, 5000
call prInt
jmp $

te: db 'testText'
jmp $
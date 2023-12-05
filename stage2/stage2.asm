[org 0x7c00]
mov ah, 0x0e
mov al, 'Q'
int 0x10
jmp entry
%include "include/io.asm"

entry:
mov ah, 0x0e
mov al, 'E'
int 0x10
mov cx, 8
mov bx, te
call print
call prInt
jmp $

te: db 'testText'
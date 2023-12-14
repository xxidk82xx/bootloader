[org 0x1000]
jmp entry
%include "include/BIOSIO.asm"
%include "include/BIOSDisk.asm"

entry:
mov cx, 11
mov bx, te
call print
mov eax, 0x1a9f
call prHex

mov ax, 0x7c00
mov bx, 0x3000
call readFAT
mov eax, [0x7c00]
call prHex

jmp $

te: db 'stage 2'
jmp $
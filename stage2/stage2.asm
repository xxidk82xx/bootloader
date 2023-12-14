[org 0x1000]
jmp entry
%include "include/BIOSIO.asm"
%include "include/BIOSDisk.asm"

entry:
mov bx, bootText
call printLine

mov bx, readBootText
call readBoot
call printLine

jmp $

bootText: db "   loaded stage two successfully", 0
readBootText: db "copied fsinfo", 0
jmp $
[org 0x1000]
jmp entry
%include "include/BIOSIO.asm"
%include "include/BIOSDisk.asm"

entry:
mov bx, bootText
call printLine

call readBoot
mov bx, readBootText
call printLine
call readFAT

jmp $

bootText: db "   loaded stage two successfully", 0
readBootText: db "copied fsinfo", 0
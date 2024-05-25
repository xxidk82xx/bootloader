//.org 0x1000
jmp entry
.include "include/BIOSIO.asm"
.include "include/BIOSDisk.asm"

entry:
mov bootText, %bx
call printLine

call readBoot
mov bx, readBootText
call printLine
call readFAT

jmp $

bootText: .byte "   loaded stage two successfully", 0
readBootText: .byte "copied fsinfo", 0

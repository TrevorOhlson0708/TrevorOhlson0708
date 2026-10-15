.386
.model flat, stdcall
.stack 4096
includelib kernel32.lib

GetStdHandle  PROTO, :DWORD
ReadConsoleA  PROTO, :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :DWORD
ExitProcess   PROTO, :DWORD

.data
prompt1   BYTE "Enter the first integer: "
prompt2   BYTE "Enter the second integer: "
resultMsg BYTE "The sum is: "
inHandle  DWORD ?
outHandle DWORD ?
num1      SDWORD ?
buffer    BYTE 32 DUP(?)
count     DWORD ?

.code
main PROC
    INVOKE GetStdHandle, -10
    mov  inHandle, eax
    INVOKE GetStdHandle, -11
    mov  outHandle, eax

    INVOKE WriteConsoleA, outHandle, ADDR prompt1, SIZEOF prompt1, ADDR count, 0
    call ReadNumber
    mov  num1, eax

    INVOKE WriteConsoleA, outHandle, ADDR prompt2, SIZEOF prompt2, ADDR count, 0
    call ReadNumber
    add  eax, num1
    mov  num1, eax

    INVOKE WriteConsoleA, outHandle, ADDR resultMsg, SIZEOF resultMsg, ADDR count, 0
    mov  eax, num1
    call WriteNumber

    INVOKE ExitProcess, 0
main ENDP

ReadNumber PROC
    INVOKE ReadConsoleA, inHandle, ADDR buffer, SIZEOF buffer, ADDR count, 0
    mov  esi, OFFSET buffer
    mov  eax, 0
    cmp  buffer, '-'
    jne  NextDigit
    inc  esi
NextDigit:
    movzx edx, BYTE PTR [esi]
    sub  edx, '0'
    cmp  edx, 9
    ja   Done
    imul eax, 10
    add  eax, edx
    inc  esi
    jmp  NextDigit
Done:
    cmp  buffer, '-'
    jne  Positive
    neg  eax
Positive:
    ret
ReadNumber ENDP

WriteNumber PROC
    mov  edi, OFFSET buffer + SIZEOF buffer
    mov  ebx, eax
    mov  ecx, 10
    cmp  eax, 0
    jge  NextChar
    neg  eax
NextChar:
    mov  edx, 0
    div  ecx
    add  dl, '0'
    dec  edi
    mov  [edi], dl
    cmp  eax, 0
    jne  NextChar
    cmp  ebx, 0
    jge  Print
    dec  edi
    mov  BYTE PTR [edi], '-'
Print:
    mov  ecx, OFFSET buffer + SIZEOF buffer
    sub  ecx, edi
    INVOKE WriteConsoleA, outHandle, edi, ecx, ADDR count, 0
    ret
WriteNumber ENDP

END main

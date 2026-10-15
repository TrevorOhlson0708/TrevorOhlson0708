.386
.model flat, stdcall
.stack 4096

includelib kernel32.lib

GetStdHandle  PROTO, nStdHandle:DWORD
ReadConsoleA  PROTO, hConsoleInput:DWORD, lpBuffer:PTR BYTE,
                     nNumberOfCharsToRead:DWORD, lpNumberOfCharsRead:PTR DWORD,
                     lpReserved:DWORD
WriteConsoleA PROTO, hConsoleOutput:DWORD, lpBuffer:PTR BYTE,
                     nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:PTR DWORD,
                     lpReserved:DWORD
ExitProcess   PROTO, dwExitCode:DWORD

STD_INPUT_HANDLE  EQU -10
STD_OUTPUT_HANDLE EQU -11

.data
prompt1      BYTE "Enter the first integer: "
prompt2      BYTE "Enter the second integer: "
resultMsg    BYTE "The sum is: "
newLine      BYTE 0Dh, 0Ah

inHandle     DWORD ?
outHandle    DWORD ?
inBuffer     BYTE 32 DUP(0)
bytesRead    DWORD ?
bytesWritten DWORD ?
outBuffer    BYTE 12 DUP(0)

num1         SDWORD ?
num2         SDWORD ?
sum          SDWORD ?

.code
main PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov inHandle, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outHandle, eax

    INVOKE WriteConsoleA, outHandle, ADDR prompt1, SIZEOF prompt1, ADDR bytesWritten, 0
    call ReadNumber
    mov num1, eax

    INVOKE WriteConsoleA, outHandle, ADDR prompt2, SIZEOF prompt2, ADDR bytesWritten, 0
    call ReadNumber
    mov num2, eax

    mov eax, num1
    add eax, num2
    mov sum, eax

    INVOKE WriteConsoleA, outHandle, ADDR resultMsg, SIZEOF resultMsg, ADDR bytesWritten, 0
    mov eax, sum
    call WriteNumber
    INVOKE WriteConsoleA, outHandle, ADDR newLine, SIZEOF newLine, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

ReadNumber PROC
    INVOKE ReadConsoleA, inHandle, ADDR inBuffer, SIZEOF inBuffer, ADDR bytesRead, 0

    mov esi, OFFSET inBuffer
    mov ecx, bytesRead
    mov eax, 0
    mov ebx, 0

    cmp BYTE PTR [esi], '-'
    jne NextDigit
    mov ebx, 1
    inc esi
    dec ecx

NextDigit:
    cmp ecx, 0
    je DoneDigits
    movzx edx, BYTE PTR [esi]
    cmp edx, '0'
    jb DoneDigits
    cmp edx, '9'
    ja DoneDigits
    sub edx, '0'
    imul eax, 10
    add eax, edx
    inc esi
    dec ecx
    jmp NextDigit

DoneDigits:
    cmp ebx, 1
    jne ReadDone
    neg eax
ReadDone:
    ret
ReadNumber ENDP

WriteNumber PROC
    mov edi, OFFSET outBuffer + SIZEOF outBuffer
    mov ecx, 0
    mov ebx, 0
    mov esi, 10

    cmp eax, 0
    jge NextChar
    mov ebx, 1
    neg eax

NextChar:
    mov edx, 0
    div esi
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    cmp eax, 0
    jne NextChar

    cmp ebx, 1
    jne PrintIt
    dec edi
    mov BYTE PTR [edi], '-'
    inc ecx

PrintIt:
    INVOKE WriteConsoleA, outHandle, edi, ecx, ADDR bytesWritten, 0
    ret
WriteNumber ENDP

END main

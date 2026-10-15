; AddTwoIntegers.asm
; Prompts the user for two integers, adds them, and displays the sum.
; Uses the Windows API (GetStdHandle, ReadConsoleA, WriteConsoleA) directly.

.386
.model flat, stdcall
.stack 4096

includelib kernel32.lib

; ---------- Windows API prototypes ----------
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
newLine      BYTE 0Dh, 0Ah              ; carriage return + line feed

inHandle     DWORD ?                    ; handle for keyboard input
outHandle    DWORD ?                    ; handle for screen output
inBuffer     BYTE 32 DUP(0)             ; holds the characters the user types
bytesRead    DWORD ?
bytesWritten DWORD ?
outBuffer    BYTE 12 DUP(0)             ; holds the sum as text ("-2147483648" fits)

num1         SDWORD ?
num2         SDWORD ?
sum          SDWORD ?

.code
main PROC
    ; Get the console input and output handles
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov  inHandle, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov  outHandle, eax

    ; Ask for and read the first integer
    INVOKE WriteConsoleA, outHandle, ADDR prompt1, SIZEOF prompt1, ADDR bytesWritten, 0
    call ReadNumber                     ; EAX = number typed
    mov  num1, eax

    ; Ask for and read the second integer
    INVOKE WriteConsoleA, outHandle, ADDR prompt2, SIZEOF prompt2, ADDR bytesWritten, 0
    call ReadNumber
    mov  num2, eax

    ; sum = num1 + num2
    mov  eax, num1
    add  eax, num2
    mov  sum, eax

    ; Display the result
    INVOKE WriteConsoleA, outHandle, ADDR resultMsg, SIZEOF resultMsg, ADDR bytesWritten, 0
    mov  eax, sum
    call WriteNumber
    INVOKE WriteConsoleA, outHandle, ADDR newLine, SIZEOF newLine, ADDR bytesWritten, 0

    INVOKE ExitProcess, 0
main ENDP

;--------------------------------------------------------------
; ReadNumber
; Reads a line from the keyboard and converts the text to an
; integer (a leading '-' makes it negative).
; Returns: EAX = the integer
;--------------------------------------------------------------
ReadNumber PROC
    INVOKE ReadConsoleA, inHandle, ADDR inBuffer, SIZEOF inBuffer, ADDR bytesRead, 0

    mov  esi, OFFSET inBuffer           ; ESI points to the first character
    mov  ecx, bytesRead                 ; ECX = number of characters typed
    mov  eax, 0                         ; EAX = running total
    mov  ebx, 0                         ; EBX = 1 if the number is negative

    cmp  BYTE PTR [esi], '-'            ; is the first character a minus sign?
    jne  NextDigit
    mov  ebx, 1
    inc  esi                            ; skip the '-'
    dec  ecx

NextDigit:
    cmp  ecx, 0                         ; out of characters?
    je   DoneDigits
    movzx edx, BYTE PTR [esi]           ; EDX = current character
    cmp  edx, '0'                       ; stop at anything that is not 0-9
    jb   DoneDigits                     ; (this catches the Enter key: CR/LF)
    cmp  edx, '9'
    ja   DoneDigits
    sub  edx, '0'                       ; ASCII character -> digit value
    imul eax, 10                        ; total = total * 10 + digit
    add  eax, edx
    inc  esi                            ; move to next character
    dec  ecx
    jmp  NextDigit

DoneDigits:
    cmp  ebx, 1                         ; was there a minus sign?
    jne  ReadDone
    neg  eax                            ; make the total negative
ReadDone:
    ret
ReadNumber ENDP

;--------------------------------------------------------------
; WriteNumber
; Converts the integer in EAX to text and writes it to the screen.
; Receives: EAX = the integer to display
;--------------------------------------------------------------
WriteNumber PROC
    mov  edi, OFFSET outBuffer + SIZEOF outBuffer   ; EDI points just past the end
    mov  ecx, 0                         ; ECX = number of characters built
    mov  ebx, 0                         ; EBX = 1 if the number is negative
    mov  esi, 10                        ; divisor

    cmp  eax, 0
    jge  NextChar
    mov  ebx, 1
    neg  eax                            ; work with the positive value

NextChar:                               ; peel off digits right to left
    mov  edx, 0                         ; clear EDX before DIV
    div  esi                            ; EAX = EAX / 10, EDX = remainder
    add  dl, '0'                        ; digit value -> ASCII character
    dec  edi
    mov  [edi], dl
    inc  ecx
    cmp  eax, 0                         ; any digits left?
    jne  NextChar

    cmp  ebx, 1                         ; add a '-' in front if negative
    jne  PrintIt
    dec  edi
    mov  BYTE PTR [edi], '-'
    inc  ecx

PrintIt:
    INVOKE WriteConsoleA, outHandle, edi, ecx, ADDR bytesWritten, 0
    ret
WriteNumber ENDP

END main

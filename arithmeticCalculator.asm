SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    menu db "Arithmetic Calculator", 0xa
    lenmenu equ $ - menu

    optionAdd db "1 - Addition", 0xa
    lenadd equ $ - optionAdd

    optionSub db "2 - Subtraction", 0xa
    lensub equ $ - optionSub

    optionMul db "3 - Multiplication", 0xa
    lenmul equ $ - optionMul

    optionDiv db "4 - Division", 0xa
    lendiv equ $ - optionDiv

    chooseOp db "Choose Operation: ", 0xa
    lenop equ $ - chooseOp

    operand1Msg db "Input Operand 1: ", 0xa
    lenop1 equ $ - operand1Msg

    operand2Msg db "Input Operand 2: ", 0xa
    lenop2 equ $ - operand2Msg

    resultMsg db "Result: ", 0xa
    lenresult equ $ - resultMsg

    divZeroError db "Error: Division by zero!", 0xa
    lendivzer equ $ - divZeroError

    newline db 0xa

section .bss
    operand1 resd 1 
    operand2 resd 1 
    result resd 1  
    operation resb 1
    buffer1 resb 12
    buffer2 resb 12
    outputBuffer resb 12

section .text
    global _start

_start:
    ;menu
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, menu
    mov edx, lenmenu
    int 0x80

    ;options
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, optionAdd
    mov edx, lenadd
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, optionSub
    mov edx, lensub
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, optionMul
    mov edx, lenmul
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, optionDiv
    mov edx, lendiv
    int 0x80

    ;ask operation
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, chooseOp
    mov edx, lenop
    int 0x80

    ;read operation choice
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, operation
    mov edx, 1
    int 0x80

    mov eax, 3
    mov ebx, 0
    sub esp, 1          
    mov ecx, esp        
    mov edx, 1
    int 0x80
    add esp, 1

    ;operand 1
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, operand1Msg
    mov edx, lenop1
    int 0x80

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, buffer1
    mov edx, 12
    int 0x80
    mov ecx, buffer1
    call ascii_to_int
    mov [operand1], eax

    ;operand 2
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, operand2Msg
    mov edx, lenop2
    int 0x80

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, buffer2
    mov edx, 12
    int 0x80
    mov ecx, buffer2
    call ascii_to_int
    mov [operand2], eax

    ;load operands into registers
    mov eax, [operand1]
    mov ebx, [operand2]

    ;compare operation
    cmp byte [operation], '1'
    je addition
    cmp byte [operation], '2'
    je subtraction
    cmp byte [operation], '3'
    je multiplication
    cmp byte [operation], '4'
    je division

    jmp end_program

addition:
    add eax, ebx
    mov [result], eax
    jmp display_result

subtraction:
    sub eax, ebx
    mov [result], eax
    jmp display_result

multiplication:
    imul eax, ebx
    mov [result], eax
    jmp display_result

division:
    cmp ebx, 0
    je div_by_zero
    xor edx, edx
    div ebx
    mov [result], eax
    jmp display_result

div_by_zero:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, divZeroError
    mov edx, lendivzer
    int 0x80
    jmp end_program

display_result:
    ;print results
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, resultMsg
    mov edx, lenresult
    int 0x80

    ;convert to ASCII
    mov eax, [result]
    call int_to_ascii

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, outputBuffer
    mov edx, 12
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newline
    mov edx, 1
    int 0x80

end_program:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

ascii_to_int:
    xor eax, eax
    xor ebx, ebx
    mov ebx, 10
.convert_loop:
    movzx edx, byte [ecx]
    cmp dl, 0xA
    je .done
    sub dl, '0'
    imul eax, ebx
    add eax, edx
    inc ecx
    jmp .convert_loop
.done:
    ret

int_to_ascii:
    mov ecx, outputBuffer + 11
    mov byte [ecx], 0
    mov ebx, 10
.convert_loop2:
    xor edx, edx
    div ebx
    add dl, '0'
    dec ecx
    mov [ecx], dl
    test eax, eax
    jnz .convert_loop2
    mov ecx, buffer1
    ret
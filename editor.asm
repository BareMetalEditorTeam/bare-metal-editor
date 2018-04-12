    org     0x1000
    bits    32

    jmp         editor

%include "utils.inc"

MAX_NUM_TABS    equ 10
BUFFER_SIZE     equ 1024 ; in bytes
TOTAL_BUFFERS   equ MAX_NUM_TABS*BUFFER_SIZE

editor:
    ; setup a buffer for each tab
    sub         esp, TOTAL_BUFFERS
    sub         esp, 20
    ; stack variables offsets
BUFFERS         equ  0
current_tab     equ  TOTAL_BUFFERS
cursor_array    equ  TOTAL_BUFFERS + 4

    mov         edi, 0xb8000
    xor         edx, edx    ; used for state
    ; dx = 0    previous scan code is a character
    ; dx = 1    previous scan code is shift
    ; dx = 2    previous scan code is ctrl
    mov         word [edi], 0x0f41
; Wait for keyboard input
check:
    in          al, 0x64
    test        al, 1   ; is data available at data port?
    jz          check
    ; Get the scan code of the key
    xor         eax, eax
    in          al, 0x60
; check if its a make code or a break code
    test        al, 0x80
    jnz         break_code
    ; status codes
    mov         ebx, 1
    mov         ecx, 2
; Make Codes
;; Left Shift
    cmp         al, 0x2A
    cmove       edx, ebx
;; Right Shift
    cmp         al, 0x36
    cmove       edx, ebx
;; Ctrl
    cmp         al, 0x1D
    cmove       edx, ecx
;; Backspace
    cmp         al, 0x0E
    jne         del
    push        edx
    xor         al, al
    call        delete
    pop         edx
del:
    cmp         al, 0x53
    jne         arrows
    push        edx
    mov         al, 1
    call        delete
    pop         edx
arrows:
;; Arrows
;;; Up Arrow
    cmp         al, 0x48
    je          nav
;;; Left Arrow
    cmp         al, 0x4B
    je          nav
;;; Right Arrow
    cmp         al, 0x4D
    je          nav
;; Down Arrow
    cmp         al, 0x50
    jne         character
nav:
    push        edx
    call        navigate
    pop         edx
;; Characters
; Wait for the break code
character:
    jmp          moveCursor
; Break Codes
break_code:
    cmp         al, 0x82
    jl          check
    cmp         al, 0x8E    ;BKSP
    je          check
; TODO implement the TAB character
    cmp         al, 0x8F    ;TAB
    je          check
; TODO implement the ENTER character
    cmp         al, 0x9C    ;ENTER
    je          check
    cmp         al, 0x9D    ;CTRL
    je          reset
    cmp         al, 0xAA    ;LEFT SHIFT
    je          reset
    cmp         al, 0xB6
    je          reset
    jg          check
; It is a break code of a character
    or          edx, edx
    jnz         special
    push        edx
    xor         cl, cl
    call        scanCodeToASCII
    call        print
    pop         edx
    jmp         moveCursor
special:
    cmp         edx, 1
    jne         shortcut
    push        edx
    mov         cl, 1
    call        scanCodeToASCII
    call        print
    pop         edx
    jmp         moveCursor
shortcut:
    push        edx
    call        shortcut_action
    pop         edx
    jmp         moveCursor
reset:
    xor         edx, edx
moveCursor:
    push        edx
    call        calcCursorPosition
    pop         edx
    jmp         check

print:
    ; al contains the ASCII code
    ; edi already set to the correct position
    ;
    ; After the subroutine returns edi must point
    ; to a valid VGA color text mode address (0xb8000 - 0xbffff)
    mov         ah, 0x0f
    mov         [edi], ax
    add         edi, 2
    ret

calcCursorPosition:
    ; calculate position offset
    mov         ebx, edi
    sub         ebx, 0xB8000
    shr         ebx, 1

    ; write the low byte
    mov         al, 0x0f
    mov         dx, 0x03d4
    out         dx, al

    mov         dx, 0x03d5
    mov         al, bl
    out         dx, al

    ; write the high byte
    mov         al, 0x0e
    mov         dx, 0x03d4
    out         dx, al

    mov         al, bh
    mov         dx, 0x03d5
    out         dx, al
    ret

delete:
    ; edi is set to the current position of the cursor, DON'T CHANGE IT
    ; al = 0: delete previous character
    ; al = 1: delete next character
    ; must check for boundries (0xB8000 < edi < 0xBFFFF)
    ; change edi apropriatly
    or          al, al
    jnz         .del
    cmp         edi, 0xB8000
    je          .done
    sub         edi, 2
    mov         byte [edi], ' '
    mov         byte [edi+1], 0x00
    jmp         .done
    .del:
    cmp         edi, 0xBFFFF
    je          .done
    mov         byte [edi+2], ' '
    mov         byte [edi+3], 0x00
    .done:
    ret

navigate:
    ; al contains scan code of the arrow key
    ; edi set to the current position of the cursor, DON'T CHANGE IT
    ; must check for boundries (0xB8000 < edi < 0xBFFFF)
    ret

shortcut_action:
    ; al contains the scan code of the key pressed along with ctrl
    ; edi is already set tot the current position of the cursor, DON'T CHANGE IT
    ret

    times   (0x400000 - ($ - $$ - 0x200)) db 0
    ; vim: set ft=nasm:
    ; vim: set commentstring=;%s:

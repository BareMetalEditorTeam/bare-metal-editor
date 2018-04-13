    org     0x1000
    bits    32

    jmp         editor

%include "utils.inc"

MAX_NUM_TABS    equ 10
BUFFER_SIZE     equ 1024 ; in bytes
TOTAL_BUFFERS   equ MAX_NUM_TABS*BUFFER_SIZE

; colors
TEXT_COLOR      equ WHITE_ON_BLACK
HINT_COLOR      equ GREY_ON_BLACK

; strings
welcome:        db  "This is a new tab, you can start typing right away!",0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  A Simple text editor that runs on x86 hardware  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

editor:
    mov         ebp, esp

    ; setup a buffer for each tab
    sub         esp, TOTAL_BUFFERS  ; buffers
    sub         esp, MAX_NUM_TABS*2 ; gap start
    sub         esp, MAX_NUM_TABS*2 ; gap end
    sub         esp, 2              ; current tab index
    sub         esp, MAX_NUM_TABS   ; cursor x coordinate for all tabs
    sub         esp, MAX_NUM_TABS   ; cursor y coordinate for all tabs
    and         esp, 0xfffffff0     ; ensure the stack is aligned to 16-byte boundries

    ; stack variables offsets
buffers         equ TOTAL_BUFFERS
gap_start       equ buffers + MAX_NUM_TABS*2
gap_end         equ gap_start + MAX_NUM_TABS*2
current_tab     equ gap_end + 2
cursor_x_array  equ current_tab + MAX_NUM_TABS
cursor_y_array  equ cursor_x_array + MAX_NUM_TABS


    ;;;;;;;;;;;;;;;;;;;;;;
    ;  Initialize State  ;
    ;;;;;;;;;;;;;;;;;;;;;;
    
    mov         edi, VIDMEM     ; VGA color text mode memory address

    ; Program State
    ; edx = 0        previous scan code is a character
CHARACTER_STATE equ 0
    ; edx = 1        previous scan code is shift
SHIFT_STATE     equ 1
    ; edx = 2        previous scan code is ctrl
CTRL_STATE      equ 2
    ; edx = 0xffff   no key was pressed before
FRESH_STATE     equ 0xffff
    ; initial state
    mov         edx, FRESH_STATE

    ; Initialize variables
    cld
    ; gap start array
    lea         edi, [ebp-gap_start]
    xor         eax, eax
    mov         ecx, MAX_NUM_TABS
    rep         stosw
    ; gap end array
    lea         edi, [ebp-gap_end]
    mov         eax, BUFFER_SIZE
    mov         ecx, MAX_NUM_TABS
    rep         stosw
    ; current tab
    mov         word [ebp-current_tab], 0
    ; cursor x array
    lea         edi, [ebp-cursor_x_array]
    xor         eax, eax
    mov         ecx, MAX_NUM_TABS
    rep         stosb
    ; cursor y array
    lea         edi, [ebp-cursor_y_array]
    xor         eax, eax
    mov         ecx, MAX_NUM_TABS
    rep         stosb

    ; print welcome message
    pusha
    mov         esi, welcome
    mov         ah, HINT_COLOR
    mov         bh, 10
    mov         bl, 15
    call        puts
    popa

; Wait for keyboard input
.check:
    in          al, 0x64
    test        al, 1   ; is data available at data port?
    jz          .check
    ; a key was pressed
    cmp         edx, FRESH_STATE
    jne         .interpretKey
    ; clear the screen on the first key press
    pusha
    call        clrscr
    popa
    xor         edx, edx
.interpretKey:
    ; Get the scan code of the key
    xor         eax, eax
    in          al, 0x60
; check if its a make code or a break code
    test        al, 0x80
    jnz         .break_code
    ; status codes
    mov         ebx, SHIFT_STATE
    mov         ecx, CTRL_STATE
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
    jne         .del

    ; Delete from buffer
    pusha

    ; buffer params
    lea         edi, [ebp-buffers]
    movzx       eax, word [ebp-current_tab]
    mov         ecx, BUFFER_SIZE
    mul         ecx
    add         edi, eax

    mov         ecx, BUFFER_SIZE

    ; gap parameters
    movzx       eax, word [ebp-current_tab]
    movzx       ebx, word [ebp-gap_start+eax*2]
    movzx       edx, word [ebp-gap_end+eax*2]

    xor         eax, eax

    call        bufdel

    movzx       eax, word [ebp-current_tab]
    mov         [ebp-gap_start+eax*2], ebx
    mov         [ebp-gap_end+eax*2], edx
    popa
    jmp         .refreshScreen
.del:
    cmp         al, 0x53
    jne         .arrows

    ; Delete from buffer
    pusha

    ; buffer params
    lea         edi, [ebp-buffers]
    movzx       eax, word [ebp-current_tab]
    mov         ecx, BUFFER_SIZE
    mul         ecx
    add         edi, eax

    mov         ecx, BUFFER_SIZE

    ; gap parameters
    movzx       eax, word [ebp-current_tab]
    movzx       ebx, word [ebp-gap_start+eax*2]
    movzx       edx, word [ebp-gap_end+eax*2]

    mov         eax, 1

    call        bufdel

    movzx       eax, word [ebp-current_tab]
    mov         [ebp-gap_start+eax*2], ebx
    mov         [ebp-gap_end+eax*2], edx
    popa
    jmp         .refreshScreen
.arrows:
;; Arrows
;;; Up Arrow
    cmp         al, 0x48
    je          .nav
;;; Left Arrow
    cmp         al, 0x4B
    je          .nav
;;; Right Arrow
    cmp         al, 0x4D
    je          .nav
;; Down Arrow
    cmp         al, 0x50
    jne         .character
.nav:
    push        edx
    call        navigate
    pop         edx
    jmp         .refreshScreen
;; Characters
; Wait for the break code
.character:
    jmp          .finish_loop
; Break Codes
.break_code:
    cmp         al, 0x82
    jl          .finish_loop
    cmp         al, 0x8E    ;BKSP
    je          .finish_loop
    cmp         al, 0x9D    ;CTRL
    je          .reset
    cmp         al, 0xAA    ;LEFT SHIFT
    je          .reset
    cmp         al, 0xB6
    je          .reset
    jg          .finish_loop
; It is a break code of a character
    or          edx, edx
    jnz         .special

    pusha
    xor         cl, cl
    call        scanCodeToASCII

    push        eax

    ; buffer params
    lea         edi, [ebp-buffers]
    movzx       eax, word [ebp-current_tab]
    mov         ecx, BUFFER_SIZE
    mul         ecx
    add         edi, eax

    ; gap parameters
    movzx       eax, word [ebp-current_tab]
    movzx       ebx, word [ebp-gap_start+eax*2]
    movzx       edx, word [ebp-gap_end+eax*2]

    pop         eax

    call        bufins

    movzx       eax, word [ebp-current_tab]
    mov         [ebp-gap_start+eax*2], ebx
    mov         [ebp-gap_end+eax*2], edx
    popa

    jmp         .refreshScreen
.special:
    cmp         edx, 1
    jne         .shortcut

    pusha
    mov         cl, 1
    call        scanCodeToASCII

    push        eax

    ; buffer params
    lea         edi, [ebp-buffers]
    movzx       eax, word [ebp-current_tab]
    mov         ecx, BUFFER_SIZE
    mul         ecx
    add         edi, eax

    ; gap parameters
    movzx       eax, word [ebp-current_tab]
    movzx       ebx, word [ebp-gap_start+eax*2]
    movzx       edx, word [ebp-gap_end+eax*2]

    pop         eax

    call        bufins

    movzx       eax, word [ebp-current_tab]
    mov         [ebp-gap_start+eax*2], ebx
    mov         [ebp-gap_end+eax*2], edx
    popa

    jmp         .refreshScreen
.shortcut:
    pusha
    call        shortcut_action
    popa

    jmp         .refreshScreen

.reset:
    xor         edx, edx
.refreshScreen:
    pusha

    call        clrscr

    ; buffer params
    lea         esi, [ebp-buffers]
    movzx       eax, word [ebp-current_tab]
    mov         ecx, BUFFER_SIZE
    mul         ecx
    add         esi, eax

    mov         ecx, BUFFER_SIZE

    ; gap parameters
    movzx       eax, word [ebp-current_tab]
    movzx       ebx, word [ebp-gap_start+eax*2]
    movzx       edx, word [ebp-gap_end+eax*2]

    call        bufprint

    popa
.finish_loop:
    jmp         .check

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

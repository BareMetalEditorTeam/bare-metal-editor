    org         0x7c00
    bits        16
    
    cli
    xor         ax, ax
    mov         es, ax
    mov         ds, ax
    mov         edi, 0xB8000
    xor         dx, dx      ; used for state
    ; dx = 0    previous scan code is a character
    ; dx = 1    previous scan code is shift
    ; dx = 2    previous scan code is ctrl
    
    
; Wait for keyboard input
check:
    in          al, 0x64
    test        al, 1
    jz          check
; check if its a make code or a break code
    in          al, 0x60
    test        al, 0x80
    jnz         break_code
    ; status codes
    mov         bx, 1
    mov         cx, 2
; Make Codes
;; Left Shift
    cmp         al, 0x2A
    cmove       dx, bx
;; Right Shift
    cmp         al, 0x36
    cmove       dx, bx
;; Ctrl
    cmp         al, 0x1D
    cmove       dx, cx
;; Backspace
    cmp         al, 0x0E
    jne         del
    push        dx
    xor         al, al
    call        delete
    pop         dx
del:
    cmp         al, 0x53
    jne         arrows
    push        dx
    mov         al, 1
    call        delete
    pop         dx
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
    push        dx
    call        navigate
    pop         dx
;; Characters
; Wait for the break code
character:
    jmp          check
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
    cmp         al, 0x6A    ;LEFT SHIFT
    je          reset
    cmp         al, 0xB6
    je          reset
    jg          check
; It is a break code of a character
    xor         cl, cl
    or          dx, dx
    jnz         special
    call        print
    jmp         check
special:
    cmp         dx, 1
    jne         shortcut
    not         cl
    call        print
    jmp         check
shortcut:
    call        shortcut_action
    jmp         check
reset:
    xor         dx, dx
    jmp         check

print:
    ; al contains the scan code
    ; edi already set to the correct position, DON'T CHANGE IT
    ; cl = 0: print lowercase, or default symbol
    ; cl = 0xFF: print uppercase, or alternate symbol
    ; must increment edi
    ret

delete:
    ; edi is set to the current position of the cursor, DON'T CHANGE IT
    ; al = 0: delete previous character
    ; al = 1: delete next character
    ; must check for boundries (0xB8000 < edi < 0xBFFFF)
    ; change edi apropriatly
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
    
    times       (0x200 - 2 - ($ - $$)) db 0
    db          0x55
    db          0xAA

; Virtualbox disk configuration
    times       (0x400000 - 0x200) db 0
    db          0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
    db          0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    db          0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
    db          0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
    db          0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
    db          0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
    db          0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
    times       (0x200 - 84) db 0

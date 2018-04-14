bits 16
org 0x7C00

cli

mov ah , 0x02
mov al ,8
mov dl , 0x80
mov ch , 0
mov dh , 0
mov cl , 2
mov bx, starting
int 0x13
jmp starting


times (510 - ($ - $$)) db 0
db 0x55, 0xAA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
starting:

    
    cli
    xor         ax, ax
    mov         es, ax
    mov         ds, ax
    mov         edi, 0xB8000
    xor         dx, dx      ; used for state
    ; dx = 0    previous scan code is a character
    ; dx = 1    previous scan code is shift
    ; dx = 2    previous scan code is ctrl
    push        ecx
    push        edi
    mov         ecx,2000
    sub         edi,2
    putNULL:
    add         edi,2
    mov         byte[edi],0x0
    loop putNULL   
    pop         edi
    pop         ecx 
    
              

check:
    pushad
    mov     ecx,edi
    sub     ecx,0xB8000
    mov     dh,0 ;row
    mov     dl,0 ;column
loop1:
    cmp     ecx,160
    jl      end1
    sub     ecx,160
    inc     dh
    jmp     loop1
end1:
loop2:
    cmp     ecx,2
    jl      end2
    sub     ecx,2
    inc     dl
    jmp     loop2
end2:
    mov bh, 0
    mov ah, 2
    int 10h 
    popad

    in          al, 0x64
    test        al, 1
    jz          check
; check if its a make code or a break code
    in          al, 0x60
    test        al, 0x80
    jnz         break_code ;;;; how
    ; status codes
    push        esi
    mov         si, 1
; Make Codes
;; Left Shift
    cmp         al, 0x2A
    cmove       dx, si
    cmp         al, 0x2A
    je        check
;; Right Shift 
    cmp         al, 0x36
    cmove       dx, si
    cmp         al, 0x36
    je         check
;; Ctrl
    inc         si
    cmp         al, 0x1D
    cmove       dx, si
    pop         esi
    cmp         al, 0x1D
    ;dec         si
    je         check
;; Backspace
    cmp         al, 0x0E
    jne         del
    push        dx
    xor         al, al
    call        delete
    pop         dx
    jmp         check
del:
    cmp         al, 0x53
    jne         arrows
    push        dx
    mov         al, 1
    call        delete
    pop         dx
    jmp         check
arrows:
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
    je          nav
    jmp         character
nav:
    push        dx
    call        navigate
    pop         dx
    jmp         check
character:
    xor         cl, cl
    or          dx, dx
    jnz         special
    call        print
    jmp         check
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
    cmp         al, 0xAA    ;LEFT SHIFT   ''''  error
    je          reset
    cmp         al, 0xB6    ;RIGHT SHIFT
    je          reset
    jg          check
    jmp         check
; It is a break code of a character  
special:
    cmp         dx, 1
    jne         shortcut
    mov byte[edi],'2'
    add esi,2
    not         cl
    call        print
    jmp         check
shortcut:
    call        shortcut_action
    jmp         check
reset:
    xor         dx, dx
    jmp         check
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;print;;;;;;;;;
print:
    cmp     cl,0
    je      lower
    ;upper
    mov     ebp,uppercaseScanCodeTable
    jmp a
    lower:
    mov     ebp,lowercaseScanCodeTable
    a:
    
    push    edx
    push    ecx
    push    esi
    push    ebx
    
    call    row_num ;;change edx .... row number in edx
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    cmp     edi,esi
    jg freeWrite
;before
    mov     ecx,LastColumn
    mov     ebx,[ecx+4*edx]
    cmp     esi,ebx
    jne      case1
;case2:    
    ;find length of last string in ecx
    xor     ecx,ecx
    loop_length:
    sub     ebx,2
    inc     ecx
    cmp     byte[ebx],0x0
    jne     loop_length
    
    ;put edi on the start of the last string 
    push    edi
    add     ebx,2
    mov     edi,ebx
    sub     ebx,2
    
    ;add length of the gab to ecx
    push    ecx
    loop_length_gap:
    sub     ebx,2
    inc     ecx
    cmp     byte[ebx],0x0
    je      loop_length_gap
    
    dec     ecx
    ;sub esi corresponding to ecx
    sub_esi:
    sub esi,2
    loop sub_esi
    mov     ebx,EndOfRow
    mov     [ebx+4*edx],esi
    pop     ecx

    inc     edx
    l:
    push    edi
    push    esi
    push    ecx
    push    edx
    call    case2
    pop     edx
    pop     ecx
    pop     esi
    pop     edi
    loop l
    pop     edi
    
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
  ret
   
case2:
    
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    mov     ecx,LastColumn
    mov     ebx,[ecx+4*edx]
    cmp     esi,ebx
    jne     case2_1
    
    ;find length of last string in ecx
    xor     ecx,ecx
    loop_length_2:
    sub     ebx,2
    inc     ecx
    cmp     byte[ebx],0x0
    jne     loop_length_2
    
    ;put edi on the start of the last string
    push    edi 
    add     ebx,2
    mov     edi,ebx
    sub     ebx,2
    
    ;add length of the gab to ecx
    push    ecx
    loop_length_gap_2:
    sub     ebx,2
    inc     ecx
    cmp     byte[ebx],0x0
    je loop_length_gap_2
    
    dec     ecx
    ;sub esi corresponding to ecx
    sub_esi_2:
    sub     esi,2
    loop sub_esi_2
    mov     ebx,EndOfRow
    mov     [ebx+4*edx],esi
    pop     ecx
    
    ;shift last string to the next line
    inc     edx
    ;sub     edi,2
    l_2:
    push    ecx
    push    edx
    call    case2
    pop     edx
    pop     ecx
    loop l_2
    pop     edi

    ret
    case2_1:
    mov     ecx,EndOfRow
    add     esi,2 
    call    RShift
    ;mov     bx,ScanCodeTable
    ;xlat
    mov     byte[edi],0x0
    add     edi,2
    mov     [ecx+4*edx],esi
    
ret

 case1:
    mov     ecx,EndOfRow
    add     esi,2 
    call    RShift
    mov     ebx,ebp
    xlat
    mov     [edi],al
    add     edi,2
    mov     [ecx+4*edx],esi
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
ret

freeWrite:                                         
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    mov         ebx,ebp
    xlat
    mov         [edi],al
    ;inc edi
    ;mov byte[edi],0x17
    add         edi,2
    cmp         edi,757664
    jl InRange1
    sub         edi,2
    InRange1: 
    sub     edi,2  
    
    push    edx;;;;;;;;;;;;;;;;;;
    push    ecx;;;;;;;;;;;;;;;
    push    ebx;;;;;;;;;;;;;;;;
    
    call    row_num ;;change edx .... row number in edx
    mov     ebx,EndOfRow
    mov     [ebx+4*edx],edi
    pop     ebx;.........................
    pop     ecx;.................
    pop     edx;.....................
    add     edi,2
    
ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
row_num:
    push    ecx
    xor     edx,edx
    mov     ecx,edi
    sub     ecx,0xB8000
    mov     dl,0 ;row
loop3:
    cmp     ecx,160
    jl      end3
    sub     ecx,160
    inc     dl
    jmp     loop3
end3:
    pop     ecx
ret


    ;;;;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    ;jmp check
    ; cl = 0: print lowercase, or default symbol
    ; cl = 0xFF: print uppercase, or alternate symbol
    ; must increment edi
    
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;^^^^^^^print 
RShift:
    ;the functon shift charecters from edi up to esi (shift right)
    ;first charecter epeated
    push    ecx
    push    esi
    loopRShift:
    sub     esi,2
    cmp     esi,edi
    jl      ignore
    mov     cl,[esi]
    add     esi,2
    mov     [esi],cl
    sub     esi,2
    jmp loopRShift
    ignore:
    add     esi,2
    pop     esi
    pop     ecx
ret
LShift:
    ;the functon shift charecters from esi up to edi (shift left)
    ;last charecter epeated
    push    edi
    push    ecx
    _loop:
    add     edi,2
    cmp     edi,esi
    jg      _ignore
    mov     cl,[edi]
    sub     edi,2
    mov     [edi],cl
    add     edi,2
    jmp _loop
    _ignore:
    pop     ecx
    pop     edi
ret
;;;;;;;;;;;;;;;;;;;;;;;;cmpleted
delete:
    ;steps:
    ;sub edi 2 (ignore with delete key)
    ;shift from esi to edi
    ;push zero in [esi]
    ;sub esi 2
    ; al = 0: delete previous character(backspace)
    ; al = 1: delete next character
    cmp     al,0
    je backspace
;delete:
    push    esi
    push    ebx
    push    ecx
    push    edx
    call    row_num;change edx .... row number in edx
    mov     ebx,EndOfRow
    mov     esi,[ebx+4*edx]
    add     esi,2
    cmp     edi,esi
    je _Dend
    jg _Dend
    mov     esi,[ebx+4*edx]
    cmp     edi,esi
    jg      _Dend
    call    LShift
    mov     byte[esi],0
    DendOfDel:
    mov     ebx,EndOfRow
    sub     byte[ebx+4*edx],2   
    _Dend:
    pop     edx
    pop     ecx
    pop     ebx
    pop     esi
    ret
backspace:
    push    esi
    push    ebx
    push    ecx
    push    edx
    cmp     edi,0xb8000
    je      _end
    call    row_num;change edx .... row number in edx
    mov     ebx,EndOfRow
    mov     esi,[ebx+4*edx]
    sub     edi,2
    cmp     edi,esi
    jg      _end      
    call    LShift
    mov     byte[esi],0
    endOfDel:
    mov     ebx,EndOfRow
    sub     byte[ebx+4*edx],2    ;;;;;;;;;;;;;
    _end:
    pop     edx
    pop     ecx
    pop     ebx
    pop     esi
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;completed
navigate:
    ;up
    cmp     al,0x48
    jne     left
    sub     edi,160
    cmp     edi,0xB8000
    jge InRange4
    add     edi,160
    InRange4:
    jmp     check
    ;left
    left:
    cmp     al,0x4B
    jne     right
    sub     edi,2
     cmp     edi,0xB8000
    jge InRange2
    add     edi,2
    InRange2:
    jmp     check
    ;right
    right:
    cmp     al,0x4D
    jne     down
    add     edi,2
    cmp     edi,757664
    jl InRange3
    sub     edi,2
    InRange3:
    jmp     check
    down:
    add     edi,160
    cmp     edi,757664
    jl InRange
    sub     edi,160
    InRange:
    jmp     check
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shortcut_action:
mov byte[edi],'3'
add edi,2
    ; al contains the scan code of the key pressed along with ctrl
    ; edi is already set tot the current position of the cursor, DON'T CHANGE IT
    ret 
    
    LastColumn: dd 0xB809E,0xB813E,0xB81DE,0xB827E,0xB831E,0xB83BE,0xB845E,0xB84FE,0xB859E,0xB863E
                dd 0xB86DE,0xB877E,0xB881E,0xB88BE,0xB895E,0xB89FE,0xB8A9E,0xB8B3E,0xB8BDE,0xB87CE
                dd 0xB8D1E,0xB8DBE,0xB8E5E,0xB8EFE,0xB8F9E
    EndOfRow:   dd 0xB7FFE,0xB809E,0xB813E,0xB81DE,0xB827E,0xB831E,0xB83BE,0xB845E,0xB84FE,0xB859E
                dd 0xB863E,0xB86DE,0xB877E,0xB881E,0xB88BE,0xB895E,0xB89FE,0xB8A9E,0xB8B3E,0xB8BDE
                dd 0xB87CE,0xB8D1E,0xB8DBE,0xB8E5E,0xB8EFE
    times(22) dd 0
    ;ScanCodeTable: db "//1234567890-=//QWERTYUIOP[]//ASDFGHJKL;//'/ZXCVBNM,.//// /"
    uppercaseScanCodeTable: db "//!@#$%^&*()_=/",0x00,"QWERTYUIOP[]",0x0a,"/ASDFGHJKL;",0x22,"`/|ZXCVBNM<>?///",0x00,"/"
    lowercaseScanCodeTable: db "//1234567890-+/",0x00,"qwertyuiop{}",0x0a,"/asdfghjkl:",0x27,"~/\zxcvbnm,.////",0x00,"/"
   

; Virtualbox disk configuration
    times       (0x400000 - 512) db 0
    db          0x63, 0x6F, 0x6E, 0x65, 0x63, 0x74, 0x69, 0x78, 0x00, 0x00, 0x00, 0x02
    db          0x00, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    db          0x20, 0x72, 0x5D, 0x33, 0x76, 0x62, 0x6F, 0x78, 0x00, 0x05, 0x00, 0x00
    db          0x57, 0x69, 0x32, 0x6B, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00
    db          0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x78, 0x04, 0x11
    db          0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xE6, 0xB9, 0x49, 0x44, 0x4E, 0x1C
    db          0x50, 0xC9, 0xBD, 0x45, 0x83, 0xC5, 0xCE, 0xC1, 0xB7, 0x2A, 0xE0, 0xF2
    times       (0x200 - 84) db 0

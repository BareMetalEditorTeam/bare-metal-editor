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
    ; dx = 3    alt
    
    push        ebp
    mov         ebp,tabA
    sub         esp,6000
    mov         dword[ebp],esp      ;tabe0
    sub         esp,6000
    mov         dword[ebp+4],esp    ;tab1
    sub         esp,6000
    mov         dword[ebp+8],esp    ;tabe2
    sub         esp,6000
    mov         dword[ebp+12],esp   ;tabe3 ;; for short cuts
    sub         esp,6000
    mov         dword[ebp+16],esp   ;tabe4
    sub         esp,6000
    mov         dword[ebp+20],esp   ;tabe5
    sub         esp,6000
    mov         dword[ebp+24],esp   ;tabe6
    sub         esp,6000
    mov         dword[ebp+28],esp   ;tabe7
    sub         esp,6000
    mov         dword[ebp+32],esp   ;tabe8
    sub         esp,6000
    mov         dword[ebp+36],esp   ;tabe9
    sub         esp,6000
    mov         dword[ebp+40],esp  ; tab10
    
    pop         ebp

 ;clear screen
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
    
;;color:
    pushad
    mov ecx,2000
    mov edi,0xB8000
    sub edi,1
    color:
    add edi,2
    mov byte[edi],0xF0 ;white  screen
    loop color
    popad
    
     ;;;copy screen to tab0
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y
    
    popad
  
     ;;;copy screen to tab1
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+4]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y11:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y11
    
    popad
    
    
     ;;;copy screen to tab2
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+8]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y2:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y2
    
    popad
;    
     ;;;copy screen to tab3
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+12]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y3:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y3
    
    popad
    
    ;;;copy screen to tab4
    ;pushad
;    
;    mov     ebp,tabA
;    ;mov     edx,dword[tabM]
;    mov     edi,dword[ebp+16]
;    mov     esi,0xB8000
;    mov     ecx,4000
;    mov     edx,0 
;    y4:
;    mov     al,byte[esi+edx]
;    mov     byte[edi+edx],al
;    inc     edx
;    loop y4
;    
;    popad
    
     ;;;copy screen to tab5
    
    
     ;;;copy screen to tab6
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+24]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y6:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y6
    
    popad
    
     ;;;copy screen to tab7
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+28]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y7:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y7
    
    popad
    
     ;;;copy screen to tab8
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+32]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y8:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y8
    
    popad
    
     ;;;copy screen to tab9
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+36]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y9:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y9
    
    popad
    
    ;;;copy screen to the the empty tab
    pushad
    
    mov     ebp,tabA
    ;mov     edx,dword[tabM]
    mov     edi,dword[ebp+36]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    y10:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop y10
    
    popad
    
    
  
check:

;;;copy screen to the current tab
    pushad
    
    mov     ebp,tabA
    mov     edx,dword[tabM]
    mov     edi,dword[ebp+4*edx]
    mov     esi,0xB8000
    mov     ecx,4000
    mov     edx,0 
    a1:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop a1
    
    popad

;;cursor
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
    jnz         break_code ;;;;
    ; status codes
    push        esi
    mov         si, 1
; Make Codes
;; Left Shift
    cmp         al, 0x2A
    cmove       dx, si
    cmp         dx,1
    jne sss
    mov byte[edi],'9'
    add edi,2
    sss:
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
    ;pop         esi
    cmp         al, 0x1D
    je         check
      
;;right alt 
    inc         si
    cmp         al,0x38
    cmove       dx,si
    ;pop         esi
    cmp         al,0x38
    je  check
     
;;left alt
    cmp         al,0x38
    cmove       dx,si
    pop         esi
    cmp         al,0x38
    je  check 
    
;;tab   
    cmp         al,0x0F
    jne m
    cmp         dx,3
    je tab   ;;change tab
    push        eax
    push        edx
    push        esi
    push        ecx
    
    xor         edx,edx
    mov         eax,edi
    mov         esi,2
    div         esi
    mov         esi,4
    div         esi
    mov         ecx,edx
    cmp         ecx,0
    je          fulTab
    LL:
    call PrintOneTab
    loop LL
    jmp         s1
    fulTab:
    mov         ecx,4
    LL1:
    call PrintOneTab
    loop LL1
    s1:

    pop     ecx
    pop     esi
    pop     edx
    pop     eax
    jmp check
    m:
;;capslk
    cmp         al,0x3A
    je check
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
    cmp         dx,3
    jne     kl
    mov byte[edi],'9'
    kl:
    call        navigate
    pop         dx
    jmp         check
character:
    xor         cl, cl
    or          dx, dx
    jnz         special
;;ENTER    
    cmp         al,0x1C    
    jne u
    call        EnterFun
    jmp         check
    u:
    call        print
    jmp         check
break_code:
    cmp         al, 0x82
    jl          check
    ;;capslk   
    cmp         al,0xBA
    jne n
    cmp         dword[cpk],0
    je          one
    mov         dword[cpk],0
    ;mov         byte[edi],'0'
    ;add         edi,2
    jmp q1
    one:
    mov         dword[cpk],1
    ;mov         byte[edi],'1'
    ;add         edi,2
    q1:
    push    ecx
    push    esi
    push    edx
    call    row_num  ; index in edx
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    cmp     edi,esi
    jne ne
    mov     byte[edi],'1'
    jmp en1
    ne:
    mov     byte[edi],'0'
    en1:
    pop     edx
    pop     esi
    pop     ecx
    jmp check
    n:
    cmp         al, 0x8E    ;BKSP
    je          check
; TODO implement the TAB character
    cmp         al, 0x8F    ;TAB
    je          check
; TODO implement the ENTER character
    cmp         al, 0x9C    ;ENTER
    je          check
    y1:
    cmp         al, 0x9D    ;CTRL
    je          reset
    cmp         al, 0xAA    ;LEFT SHIFT   ''''  error
    je          reset
    cmp         al, 0xB6    ;RIGHT SHIFT
    je          reset
    cmp         al, 0xB8    ;LEFT alt
    je          reset
    jg          check
    jmp         check
; It is a break code of a character  
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
tab:

    ;save edi
    push    edx
    push    ecx
    mov     ecx,tabM
    mov     edx,dword[ecx]
    inc     edx
    mov     dword[ecx+4*edx],edi
    pop     ecx
    pop     edx
    


    ;change tab index
    cmp dword[tabM],0
    jne tab1
    mov dword[tabM],1
    jmp done
    tab1:
    cmp dword[tabM],1
    jne tab2
    mov dword[tabM],2
    jmp done
    tab2:
    cmp dword[tabM],2
    jne done
    mov dword[tabM],0
    done:
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
    cmp     dword[tabM],0
    jne notzero
    zero:
    ;;color
    pushad
    mov ecx,2000
    mov edi,0xB8000
    sub edi,1
    color1:
    add edi,2
    mov byte[edi],0x3F
    loop color1
    popad
    
    
    push    edi
    push    ecx
    mov     edi,0xB8000
    ;clear screen
    mov         ecx,2000
    sub         edi,2
    putNULL2:
    add         edi,2
    mov         byte[edi],0x0
    loop putNULL2 
    mov     edi,754464
    ;;massege
    mov     byte[edi],'W'
    add     edi,2
    mov     byte[edi],'E'
    add     edi,2
    mov     byte[edi],'L'
    add     edi,2
    mov     byte[edi],'C'
    add     edi,2
    mov     byte[edi],'O'
    add     edi,2
    mov     byte[edi],'M'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'T'
    add     edi,2
    mov     byte[edi],'O'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'T'
    add     edi,2
    mov     byte[edi],'A'
    add     edi,2
    mov     byte[edi],'B'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'1'
    add     edi,2
    pop ecx
    pop edi
    
;move the massege
    call    MOVEMASSEGE    
    jmp q
    notzero:
    cmp     dword[tabM],1
    jne     notone
    ;;color
    pushad
    mov ecx,2000
    mov edi,0xB8000
    sub edi,1
    color2:
    add edi,2
    mov byte[edi],0x3F
    loop color2
    popad
    
  
    push    edi
    push    ecx
    mov     edi,0xB8000
    ;clear screen
    mov         ecx,2000
    sub         edi,2
    putNULL3:
    add         edi,2
    mov         byte[edi],0x0
    loop putNULL3 
    ;massege
    mov     edi,754464
    mov     byte[edi],'W'
    add     edi,2
    mov     byte[edi],'E'
    add     edi,2
    mov     byte[edi],'L'
    add     edi,2
    mov     byte[edi],'C'
    add     edi,2
    mov     byte[edi],'O'
    add     edi,2
    mov     byte[edi],'M'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'T'
    add     edi,2
    mov     byte[edi],'O'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'T'
    add     edi,2
    mov     byte[edi],'A'
    add     edi,2
    mov     byte[edi],'B'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'2'
    add     edi,2 
    pop ecx
    pop edi
    
     ;move the massege
    call    MOVEMASSEGE
    jmp q
    notone:
    ;;color
    pushad
    mov ecx,2000
    mov edi,0xB8000
    sub edi,1
    .color2:
    add edi,2
    mov byte[edi],0x3F
    loop .color2
    popad
    
  
    push    edi
    push    ecx
    mov     edi,0xB8000
    ;clear screen
    mov         ecx,2000
    sub         edi,2
    .putNULL3:
    add         edi,2
    mov         byte[edi],0x0
    loop .putNULL3 
    ;massege
    mov     edi,754464
    mov     byte[edi],'W'
    add     edi,2
    mov     byte[edi],'E'
    add     edi,2
    mov     byte[edi],'L'
    add     edi,2
    mov     byte[edi],'C'
    add     edi,2
    mov     byte[edi],'O'
    add     edi,2
    mov     byte[edi],'M'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'T'
    add     edi,2
    mov     byte[edi],'O'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'T'
    add     edi,2
    mov     byte[edi],'A'
    add     edi,2
    mov     byte[edi],'B'
    add     edi,2
    mov     byte[edi],''
    add     edi,2
    mov     byte[edi],'3'
    add     edi,2 
    pop ecx
    pop edi
    
     ;move the massege
    call    MOVEMASSEGE
    q:
    
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    ;change edi
    ;push    esi
    push    ecx
    push    edx
    
    ;mov     esi,edi
    mov     ecx,tabM
    mov     edx,dword[ecx]
    inc     edx
    mov     edi,dword[ecx+4*edx]
    
    pop     edx
    pop     ecx
    ;pop     esi
    
    ;move new tab to screen
    pushad
    
    mov     edx,dword[tabM]
    mov     edi,0xB8000
    mov     ebp,tabA
    mov     esi,dword[ebp+4*edx]
    mov     ecx,4000
    
    mov     edx,0 
    a0:
    mov     al,byte[esi+edx]
    mov     byte[edi+edx],al
    inc     edx
    loop a0
    
    ;;fix EndOfRow matrix error
    push    ecx
    push    edx
    mov     ecx,25
    mov     edx,0
    fix2:
    call    CorrectIndex
    add     edx,1 
    loop    fix2
    pop     edx
    pop     ecx  


    
    popad
   
    jmp check
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EnterFun:
    push    ecx
    push    esi
    push    edx
    ;;shift all rows one step down
    call    row_num   ;index in edx
    cmp     edx,24
    je      end
    push    edi
    mov     ecx,LastColumn
    mov     edi,[ecx+4*edx]
    add     edi,2     ;start of the next line
    mov     esi,757662
    mov     ecx,80
    shiftD:
    ;push    esi
    call    RShift
    mov     byte[edi],0x0
    add     edi,2
    ;pop     esi
    loop    shiftD
    pop     edi
;;shift current row stating from edi
    ;find length of shift
    mov     ecx,LastColumn
    mov     esi,[ecx+4*edx]
    sub     esi,160
    mov     ecx,edi
    sub     ecx,esi
    mov     esi,160
    sub     esi,ecx
    add     esi,2 
    mov     ecx,esi ;;length (with bytes)
    
    inc     edx
    push    ecx
    mov     ecx,LastColumn
    mov     esi,[ecx+4*edx] ;last endex for the shift
    pop     ecx
    dec     edx
    ;shift
    shiftR:
    call    RShift
    mov     byte[edi],0x0
    add     edi,2
    sub     ecx,2
    cmp     ecx,0
    jne     shiftR
    
;;fix EndOfRow matrix error
    mov     ecx,25
    mov     edx,0
    fix:
    call    CorrectIndex
    add     edx,1 
    loop    fix
    end:
    
    pop     edx
    pop     esi
    pop     ecx
   
ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;print;;;;;;;;;
print:
    cmp     dword[cpk],1
    je      upp
    cmp     cl,0
    je      lower
    upp:
    mov     ebp,uppercaseScanCodeTable
    jmp a
    lower:
    mov     ebp,lowercaseScanCodeTable
    a:
    
    ;check to before or after
    push    edx
    push    ecx
    push    esi
    push    ebx
    
    call    row_num ;;change edx .... row number in edx
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    cmp     edi,esi
    jg freeWrite
 ;;before  
  ;check the line (full or not full)
    mov     ecx,LastColumn
    mov     ebx,[ecx+4*edx]
    cmp     esi,ebx
    je FULL
;;NOTFULL:  
    mov     ecx,EndOfRow
    add     esi,2 
    call    RShift
    mov     ebx,ebp
    xlat
    mov     [edi],al
    add     edi,2
    mov     [ecx+4*edx],esi
    jmp en
;;FULL
    FULL:
    ;check boundaries
    cmp     esi,757662
    je      notInRange1
    
    call FULL_CASE
    add     esi,2
    call RShift
    mov     ebx,ebp
    xlat
    mov     [edi],al
    add     edi,2
    ;; pay attention after shifting a full line, endofRow mat can 
    ;;have an error due spaces on the last of the ROW 
    ;;set the correct index
    call    CorrectIndex
       
    en:
    notInRange1:
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    ret
 ;;after
   freeWrite:                                         
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    mov         ebx,ebp
    xlat
    mov         [edi],al
    add         edi,2
    cmp         al,0x0   ;space
    je In1
    
    ;cahnge endOfRow mat
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
    
    In1:
    ;check screen boundaries
    cmp         edi,757664
    jl InRange1
    sub         edi,2
    InRange1: 
    
ret 
    FULL_CASE:
    push    edx
    push    ecx
    push    esi
    push    ebx
    push    edi
    ;put edi=strat of the line
    add     esi,2
    mov     edi,esi
    ;inc line index in edx
    add     edx,1
    ;check the new line (FULL or NOTFULL)
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    mov     ecx,LastColumn
    mov     ebx,[ecx+4*edx]
    cmp     esi,ebx
    jne c
    ;;FULL CASE
    ;check boundaries
    cmp     esi,757662
    je      notInRange2
    
    call    FULL_CASE
    add     esi,2
    call    RShift
    mov     ecx,EndOfRow
    ;; pay attention after shifting a full line, endofRow mat can 
    ;;have an error due spaces on the last of the ROW 
    ;;set the correct index
    call    CorrectIndex
    
    notInRange2:
    pop     edi
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    ret
    ;;NOTFULL CASE
    c:
    ;shift the line right
    add     esi,2
    call    RShift
    mov     ecx,EndOfRow
    mov     [ecx+4*edx],esi
    
    pop     edi
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    ret
    
PrintOneTab:
    
    ;check to before or after
    push    edx
    push    ecx
    push    esi
    push    ebx
    
    call    row_num ;;change edx .... row number in edx
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    cmp     edi,esi
    jg .freeWrite
 ;;before  
  ;check the line (full or not full)
    mov     ecx,LastColumn
    mov     ebx,[ecx+4*edx]
    cmp     esi,ebx
    je .FULL
;;NOTFULL:  
    mov     ecx,EndOfRow
    add     esi,2 
    call    RShift
    mov     ebx,ebp
    ;xlat
    mov     byte[edi],0x0
    add     edi,2
    mov     [ecx+4*edx],esi
    jmp .en
;;FULL
    .FULL:
    ;check boundaries
    cmp     esi,757662
    je      .notInRange1
    
    call .FULL_CASE
    add     esi,2
    call RShift
    mov     byte[edi],0x0
    add     edi,2
    ;; pay attention after shifting a full line, endofRow mat can 
    ;;have an error due spaces on the last of the ROW 
    ;;set the correct index
     call    CorrectIndex
       
    .en:
    .notInRange1:
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    ret
 ;;after
   .freeWrite:                                         
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    mov         byte[edi],0x0
    add         edi,2
    cmp         al,0x0   ;space
    je .In
    
    ;cahnge endOfRow mat
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
    
    .In:
    ;check screen boundaries
    cmp         edi,757664
    jl .InRange1
    sub         edi,2
    .InRange1: 
    
ret 
    .FULL_CASE:
    push    edx
    push    ecx
    push    esi
    push    ebx
    push    edi
    ;put edi=strat of the line
    add     esi,2
    mov     edi,esi
    ;inc line index in edx
    add     edx,1
    ;check the new line (FULL or NOTFULL)
    mov     ecx,EndOfRow
    mov     esi,[ecx+4*edx]
    mov     ecx,LastColumn
    mov     ebx,[ecx+4*edx]
    cmp     esi,ebx
    jne .c
    ;;FULL CASE
    ;check boundaries
    cmp     esi,757662
    je      .notInRange2
    
    call    .FULL_CASE
    add     esi,2
    call    RShift
    mov     ecx,EndOfRow
    ;; pay attention after shifting a full line, endofRow mat can 
    ;;have an error due spaces on the last of the ROW 
    ;;set the correct index
     call    CorrectIndex
    
    .notInRange2:
    pop     edi
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    ret
    ;;NOTFULL CASE
    .c:
    ;shift the line right
    add     esi,2
    call    RShift
    mov     ecx,EndOfRow
    mov     [ecx+4*edx],esi
    
    pop     edi
    pop     ebx
    pop     esi
    pop     ecx
    pop     edx
    ret
CorrectIndex:
;;correct last adress of row with index edx
    push    edi
    push    ecx
    push    esi
    mov     ecx,LastColumn
    mov     edi,[ecx+4*edx]
    sub     edi,160      ;start of the Row
    mov     esi,edi
    mov     ecx,80
    l:
    add     edi,2
    cmp     byte[edi],0x0
    je c1
    mov     esi,edi
    c1:
    loop l
    mov     ecx,EndOfRow
    mov     [ecx+4*edx],esi
    pop     esi
    pop     ecx
    pop     edi
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
    
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
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
    ;shiftl from esi to edi
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
cmp edx,2
jne xxx
;mov byte[edi],'2'
xxx:
;up
    cmp     al,0x48
    jne     left
    sub     edi,160
    cmp     edx,2;;;;;;;;;;;;;;;;;;
    jne     Sup
    push    ecx
    push    edi
    mov     ecx,80
    sub     edi,1
    US:
    add     edi,2
    mov     byte[edi],0x90
    loop US
    
    pop     edi
    pop     ecx
    ;code here
    ;mov byte[edi],'2'
    Sup:;;;;;;;;;;;;;;;;;;;;;;;;;
    cmp     edi,0xB8000
    jge     InRange4
    add     edi,160
    InRange4:
    jmp     check
    
;left
    left:
    cmp     al,0x4B
    jne     right
    sub     edi,2
    cmp     edx,2;;;;;;;;;;;;;;;;;;;;;;;;;
    jne     Sleft
    push    edi
    add     edi,3
    mov     byte[edi],0x90
    pop     edi
    ;code here
    ;mov byte[edi],'2'
    Sleft:;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    cmp     edi,0xB8000
    jge     InRange2
    add     edi,2
    InRange2:
    jmp     check
    
;right
    right:
    cmp     al,0x4D
    jne     down
    add     edi,2
    cmp     edx,2;;;;;;;;;;;;;;;;;;;;;;
    jne     Sr
    push    edi
    sub     edi,1
    mov     byte[edi],0x90
    pop     edi
    ;code here
    ;mov byte[edi],'2'
    Sr:;;;;;;;;;;;;;;;;;;;;;;;
    cmp     edi,757664
    jl      InRange3
    sub     edi,2
    InRange3:
    jmp     check
    
;down   
    down:
    add     edi,160
    cmp     edx,2;;;;;;;;;;;;;;;;;;;;;;;;
    jne     Sdown
    push    ecx
    push    edi
    mov     ecx,80
    add     edi,1
    D:
    sub     edi,2
    mov     byte[edi],0x90
    loop D
    pop     edi
    pop     ecx
    ;code here
    ;mov byte[edi],'2'
    Sdown:;;;;;;;;;;;;;;;;;;;;;;;;;;
    cmp     edi,757664
    jl      InRange
    sub     edi,160
    InRange:
    jmp     check
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shortcut_action:
    mov     ebx,lowercaseScanCodeTable
    xlat
    cmp     al,'c'
    je      copy
    cmp     al,'x'
    je      cut
    cmp     al,'v'
    je      paste
    cmp     al,'a'
    je      copyALL
    ; al contains the scan code of the key pressed along with ctrl
    ; edi is already set tot the current position of the cursor, DON'T CHANGE IT
    ret 
    
copy:
   ; mov     byte[edi],'c'
   ; add     edi,2
    
    ;clear tab2
    push        ecx
    push        edi
    push        ebp
    
    mov         ebp,tabA
    mov         edi,dword[ebp+8];tab index
    mov         ecx,2000
    sub         edi,2
    zputNULL:
    add         edi,2
    mov         byte[edi],0x0
    loop zputNULL 
    
    pop         ebp
    pop         edi
    pop         ecx     
    
    ;copy from the screen to tab 2
    pushad
    
    mov     ebp,tabA
    mov     edi,dword[ebp+8];tab index
    mov     esi,0xB8000
    mov     ecx,2000
    mov     ebp,0 ;;counter for copy length
    kkk:
    inc     esi
    mov     al,byte[esi]
    cmp     al,0x90
    je     docopy
    dec     esi
    jmp     dontcopy
    docopy:
    dec     esi
    mov     al,byte[esi]
    mov     [edi],al
    add     edi,2
    inc     ebp
    dontcopy:
    add     esi,2
    loop kkk
    
    mov     esi,copyS
    mov     dword[esi+4],ebp
    cmp     ebp,0
    je      NOCOPY
    mov     dword[copyS],1
    NOCOPY:
    
    popad

ret
cut:
;cmp dword[copyS],0
;je zz
;    mov     byte[edi],'x'
;    add     edi,2
;    zz:
ret
paste:
    ;mov     byte[edi],'p'
    ;add     edi,2
    
    ;;shift corrosponding to copy length
    push    esi
    push    ecx
    push    edi
    mov     esi,copyS
    mov     ecx,dword[esi+4] ;copy length
    shh:
    call    PrintOneTab
    loop shh
    pop     edi
    pop     ecx
    pop     esi
    
    ;;paste
    pushad
    mov     esi,copyS
    mov     ecx,dword[esi+4] ;copy length
    
    mov     ebp,tabA
    mov     esi,dword[ebp+8] ;tab index
    
    .paste:
    mov     al,byte[esi]
    mov     byte[edi],al
    add     edi,2
    add     esi,2
    loop .paste
    
    popad
    
    
ret
copyALL:
    ;mov     byte[edi],'a'
    ;add     edi,2
    
    pushad
    mov     ebp,25
    loopsh:
    call    row_num
    mov     ecx,LastColumn
     mov     esi,dword[ecx+4*edx]
     sub     esi,160                 ;starting address-2
    mov     ecx,EndOfRow
    mov     edi,dword[ecx+4*edx]    ;ending address
    MakeShad:
    add     esi,2
    cmp     esi,edi
    jg      DONTSHAD
    add     esi,1
    mov     byte[esi],0x90
    sub     esi,1
    jmp     MakeShad
    DONTSHAD:
   
    dec     ebp
   cmp     ebp,0   
    jne loopsh
    
    popad
ret
MOVEMASSEGE:
    push edi
push esi
push ecx
mov     edi,754464
add     edi,30
mov     esi,edi
mov     edi,754464
mov     ecx,65
lpp:
push esi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
call RShift
mov     byte[edi],0x0
add     edi,2
;;
 ;delay
    push    ecx
    mov     ecx,10000000
    delay3:
    nop
    nop
    nop
    nop
    dec ecx
    cmp ecx,0
    jne delay3
    pop     ecx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    pop esi
    add esi,2
    loop lpp
    pop ecx
    pop esi
    pop edi
 
ret
    tabA:       dd 0,0,0,0,0,0,0,0,0,0,0;[addresses of the 10 tabs , address for the empty tab]
    tabM:       dd 0,0xB8000,0xB8000,0xB8000 ;[tab_Index, edi1, edi2,edi3]   
    LastColumn: dd 0xB809E,0xB813E,0xB81DE,0xB827E,0xB831E,0xB83BE,0xB845E,0xB84FE,0xB859E,0xB863E
                dd 0xB86DE,0xB877E,0xB881E,0xB88BE,0xB895E,0xB89FE,0xB8A9E,0xB8B3E,0xB8BDE,0xB8C7E
                dd 0xB8D1E,0xB8DBE,0xB8E5E,0xB8EFE,0xB8F9E
       EndOfRow:dd 0xB7FFE,0xB809E,0xB813E,0xB81DE,0xB827E,0xB831E,0xB83BE,0xB845E,0xB84FE,0xB859E
                dd 0xB863E,0xB86DE,0xB877E,0xB881E,0xB88BE,0xB895E,0xB89FE,0xB8A9E,0xB8B3E,0xB8BDE
                dd 0xB8C7E,0xB8D1E,0xB8DBE,0xB8E5E,0xB8EFE
            cpk:dd 0
    uppercaseScanCodeTable: db "//!@#$%^&*()_=/",0x00,"QWERTYUIOP[]",0x0a,"/ASDFGHJKL;",0x22,"`/|ZXCVBNM<>?///",0x00,"/"
    lowercaseScanCodeTable: db "//1234567890-+/",0x00,"qwertyuiop{}",0x0a,"/asdfghjkl:",0x27,"~/\zxcvbnm,.////",0x00,"/"
           shad:dd 0        ;[shad state ]
           copyS:dd 0,0      ;[copy state , copy length]

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
 

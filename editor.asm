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
    
%ifndef __UTILS_INC_ICLUDED
%define __UTILS_INC_ICLUDED

%define VIDMEM  0xb8000
%define COLS    80
%define LINES   25

%define WHITE_ON_BLACK 0x0f
%define GREY_ON_BLACK 0x07

bits 32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Convert a character scan code to ASCII code  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scanCodeToASCII:
;Parameters
;  al = scan code of a character
;  cl = 1 for alternate code, 0 for default
;Output
;  al = ASCII code
    jmp         .start
.uppercaseScanCodeTable: db "//!@#$%^&*()-=/",0x09,"QWERTYUIOP[]",0x0a,"/ASDFGHJKL;",0x22,"`/|ZXCVBNM<>?/// /"
.lowercaseScanCodeTable: db "//1234567890_+/",0x09,"qwertyuiop{}",0x0a,"/asdfghjkl:",0x27,"~/\zxcvbnm,.//// /"
.start:
    and         al, 0x7f
    or          cl, cl
    jz          .lowercase
    mov         ebx, .uppercaseScanCodeTable
    jmp         .getcharacter
.lowercase:
    mov         ebx, .lowercaseScanCodeTable
.getcharacter:
    xlatb
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Print a character to the screen and change the cursor position  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

putch:
;Parameters
;  al = character ASCII code
;  ah = character attribute
;  bh = y coordinate
;  bl = x coordinate
;Output
;  bh = final y coordinate
;  bl = final x coordinate

    push    ebx ; save coordinates
    push    eax ; save data

    ; calculate memory offset
    xor     eax, eax
    mov     ecx, COLS
    mov     al, bh
    mul     ecx
    movzx   ecx, bl
    add     eax, ecx
    mov     ebx, eax

    pop     eax ; restore data

    ; if the character is a line feed
    ; go to the next line
    cmp     al, 0x0a
    je      .linefeed
    ; if the character is a tab
    ; advance 4 positions
    cmp     al, 0x09
    je      .tab

    ; output character
    mov     edi, VIDMEM
    mov     [edi+ebx*2], ax

    ; go to next position
    pop     ebx ; restore coordinates
    inc     bl
    cmp     bl, COLS
    je      .newline
    jmp     .done

.linefeed:
    pop     ebx ; restore coordinates
.newline:
    xor     bl, bl
    inc     bh
    jmp     .done

.tab:
    cld
    mov     al, ' '
    mov     edi, VIDMEM
    shl     ebx, 1
    add     edi, ebx
    mov     ecx, 4
    rep     stosw

    pop     ebx ; restore coordinates
    add     bl, 4
    cmp     bl, COLS
    
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Print a string to the screen  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

puts:
;Parameters
;  esi = null-terminated string
;  ah = character attribute for the string
;  bh = start y coordinate
;  bl = start x coordinate
;Output
;  bh = final y coordinate
;  bl = final x coordinate

.loop:
    lodsb
    or      al, al
    je      .done

    push    esi
    push    eax
    call    putch
    pop     eax
    pop     esi

    jmp     .loop
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Print the contents of a buffer to the screen  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufprint:
;Parameters
;  esi = buffer start
;  ecx = buffer length
;  ebx = gap start offset
;  edx = gap end offset
;Output
;  bh = final y coordinate
;  bl = final x coordinate
;  eax = page end offset
    
    ; create a stack frame
    push    ebp
    mov     ebp, esp
    sub     esp, 4

    ; local variables stack offsets
.y          equ 1
.x          equ 2
.tempX      equ 3
.tempY      equ 4

    push    ecx ; save buffer length

    mov     ah, WHITE_ON_BLACK
    mov     ecx, ebx

    mov     byte [ebp-.x], 0
    mov     byte [ebp-.y], 0

.pregap_loop:
    or      ecx, ecx
    jle     .postgap

    lodsb

    pusha

    ; print the character and save x,y coordinates
    mov     bh, [ebp-.y]
    mov     bl, [ebp-.x]
    call    putch
    mov     [ebp-.y], bh
    mov     [ebp-.x], bl

    popa

    ; if the screen is full, stop printing
    cmp     byte [ebp-.y], LINES
    jl      .pregap_continue
    cmp     byte [ebp-.x], COLS
    je      .done
.pregap_continue:
    dec     ecx
    jmp     .pregap_loop

.postgap:
    ; move the pointer after the gap
    sub     esi, ebx
    add     esi, edx

    mov     cl, [ebp-.y]
    mov     [ebp-.tempY], cl
    mov     cl, [ebp-.x]
    mov     [ebp-.tempX], cl

    pop     ecx
    push    ecx
    sub     ecx, edx

.postgap_loop:
    or      ecx, ecx
    jle     .done

    lodsb

    pusha

    mov     bh, [ebp-.tempY]
    mov     bl, [ebp-.tempX]
    call    putch
    mov     [ebp-.tempY], bh
    mov     [ebp-.tempX], bl

    popa

    ; if the screen is full, stop printing
    cmp     byte [ebp-.tempY], LINES
    jl      .postgap_continue
    cmp     byte [ebp-.tempX], COLS
    je      .done
.postgap_continue:
    dec     ecx
    jmp     .postgap_loop

.done:
    pop     eax
    sub     eax, edx
    sub     eax, ecx

    mov     bh, [ebp-.y]
    mov     bl, [ebp-.x]

    push    ebx
    call    moveCur
    pop     ebx

    mov     esp, ebp
    pop     ebp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Move the on-screen cursor  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

moveCur:
;Parameters
;  bh = y coordinate
;  bl = x coordinate
    ; Calculate memory offset
    xor         eax, eax
    mov         ecx, COLS
    mov         al, bh
    mul         ecx
    add         al, bl
    mov         ebx, eax

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

;;;;;;;;;;;;;;;;;;;;;;
;  Clear the screen  ;
;;;;;;;;;;;;;;;;;;;;;;

clrscr:

   cld
   mov      edi, VIDMEM
   mov      ecx, 2000 ; 25 * 80
   mov      ah, 0x07 ; default attribute
   mov      al, ' '
   rep      stosw

   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Insert a character into a buffer  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufins:
;Parameters
;  al = character ASCII code
;  edi = buffer address
;  ebx = gap start offset
;  edx = gap end offset
;Output
;  ebx = final gap start offset
;  edx = final gap end offset

    cmp     ebx, edx
    je      .done

    mov     [edi+ebx], al
    inc     ebx

.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Delete a character before or after the cursor from a buffer  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufdel:
;Parameters
;  al = 1 if the deletion is after the cursor, 0 if before it
;  edi = buffer address
;  ecx = buffer size
;  ebx = gap start offset
;  edx = gap end offset
;Output
;  ebx = final gap start offset
;  edx = final gap end offset

    or      al, al
    jnz     .after

; before
    or     ebx, ebx
    jz      .done
    dec     ebx

.after:
    cmp     edx, ecx
    je      .done
    inc     edx

.done:
    ret


%endif
; vim: set ft=nasm:
; vim: set commentstring=;%s:

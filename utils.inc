%ifndef __UTILS_INC_ICLUDED
%define __UTILS_INC_ICLUDED

%define VIDMEM  0xb8000
%define COLS    80
%define LINES   24

%define WHITE_ON_BLACK 0x0f
%define BLACK_ON_WHITE 0xf0
%define GREY_ON_BLACK 0x07

bits 32

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Convert a character scan code to ASCII code  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

scanCodeToASCII:
;Parameters
;  al = scan code of a character
;  cl = 1 if shift pressed, 0 otherwise
;  ch = 1 if caps lock is on, 0 otherwise
;Output
;  al = ASCII code
    jmp     .start
.uppercaseScanCodeTable:
    db "//!@#$%^&*()_=/",0x09,"QWERTYUIOP[]",0x0a,"/ASDFGHJKL:",0x22,"`/|ZXCVBNM<>?/// /"
.lowercaseScanCodeTable:
    db "//1234567890-+/",0x09,"qwertyuiop{}",0x0a,"/asdfghjkl;",0x27,"~/\zxcvbnm,.//// /"
.start:
    and     al, 0x7f
    or      cl, cl
    jz      .lowercase
    mov     ebx, .uppercaseScanCodeTable
    jmp         .getcharacter
.lowercase:
    mov     ebx, .lowercaseScanCodeTable
.getcharacter:
    xlatb
    ; if caps lock is not pressed, done
    or      ch, ch
    jz      .done
    ; if caps lock is pressed and shift is not
    ; change to uppercase letters
    or      cl, cl
    jnz     .small
    cmp     al, 'a'
    jl      .done
    cmp     al, 'z'
    jg      .done
    sub     al, 0x20
    jmp     .done
.small:
    ; if both caps lock and shift are pressed
    ; change to lowercase letters
    cmp     al, 'A'
    jl      .done
    cmp     al, 'Z'
    jg      .done
    add     al, 0x20
.done:
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

    cmp     bh, LINES-1
    jl      .print
    cmp     bl, COLS
    jge     .done

.print:
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
    cmp     bh, LINES-1
    je      .done
    xor     bl, bl
    inc     bh
    jmp     .done

.tab:
    pop     ebx ; restore coordinates
    mov     al, ' '
    mov     ecx, 4
.print_tab:
    push    ecx
    push    eax
    call    putch
    pop     eax
    pop     ecx
    loop    .print_tab

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
;  edi = selection start offset
;  eax = selection end offset
;Output
;  bh = final y coordinate
;  bl = final x coordinate

    ; create a stack frame
    enter   12, 0

    ; local variables stack offsets
.y          equ 1
.x          equ 1 + .y
.tempX      equ 1 + .x
.tempY      equ 1 + .tempX
.sel_start  equ 4 + .tempY
.sel_end    equ 4 + .sel_start

    push    ecx ; save buffer length
    ; save selection offset
    mov     [ebp-.sel_start], edi
    mov     [ebp-.sel_end], eax

    xor     ecx, ecx

    mov     byte [ebp-.x], 0
    mov     byte [ebp-.y], 0

.pregap_loop:
    cmp     ecx, ebx
    je      .postgap

    cmp     ecx, [ebp-.sel_start]
    jl      .pregap_normal_text
    cmp     ecx, [ebp-.sel_end]
    jge     .pregap_normal_text
    mov     ah, BLACK_ON_WHITE
    jmp     .pregap_print

.pregap_normal_text:
    mov     ah, WHITE_ON_BLACK

.pregap_print:
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
    inc     ecx
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

.postgap_loop:
    cmp     edx, ecx
    jge     .done

    cmp     edx, [ebp-.sel_start]
    jl      .postgap_normal_text
    cmp     edx, [ebp-.sel_end]
    jge     .postgap_normal_text
    mov     ah, BLACK_ON_WHITE
    jmp     .postgap_print

.postgap_normal_text:
    mov     ah, WHITE_ON_BLACK

.postgap_print:

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
    inc     edx
    jmp     .postgap_loop

.done:
    mov     bh, [ebp-.y]
    mov     bl, [ebp-.x]

    push    ebx
    call    moveCur
    pop     ebx

    leave
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Move the on-screen cursor  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

moveCur:
;Parameters
;  bh = y coordinate
;  bl = x coordinate
    ; Calculate memory offset
    xor     eax, eax
    mov     ecx, COLS
    mov     al, bh
    mul     ecx
    add     al, bl
    adc     ah, 0
    mov     ebx, eax

    ; write the low byte
    mov     al, 0x0f
    mov     dx, 0x03d4
    out     dx, al

    mov     dx, 0x03d5
    mov     al, bl
    out     dx, al

    ; write the high byte
    mov     al, 0x0e
    mov     dx, 0x03d4
    out     dx, al

    mov     al, bh
    mov     dx, 0x03d5
    out     dx, al
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

    mov     ecx, edx
    dec     ecx
    cmp     ebx, ecx
    je      .done

    mov     [edi+ebx], al
    inc     ebx

.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Insert a string before the cursor  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufinss:
;Parameters
;  esi = the string
;  ecx = the length of the string
;  edi = buffer address
;  edx = gap start offset
;  ebx = gap end offset
;Output
;  ebx = final gap start offset
;  edx = final gap end offset
.loop:
    lodsb
    push    esi
    push    ecx
    push    edi
    call    bufins
    pop     edi
    pop     ecx
    pop     esi
    loop    .loop
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  copy a string from a gap buffer to a regular buffer  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufcpy:
; the string should be right before the cursor,
; right after the cursor or the whole buffer
;Parameters
;  esi = gap buffer address
;  edi = destination buffer address
;  ebx = gap start offset
;  edx = gap end offset
;  eax = string start offset
;  ecx = string end offset
;  first 4 bytes on the stack = buffer length
;Output
;  ecx = number of characters copied

    cld

    or      eax, eax
    jnz     .before
    cmp     ecx, [esp+4]
    jne     .before

    xor     eax, eax

    push    esi
    mov     ecx, ebx
    add     eax, ecx
    rep     movsb
    pop     esi

    mov     ecx, [esp+4]
    sub     ecx, edx
    add     esi, edx
    add     eax, ecx
    rep     movsb

    mov     ecx, eax
    jmp     .done

.before:
    cmp     eax, ebx
    jg      .after

    mov     ecx, ebx
    push    ecx
    rep     movsb
    pop     ecx

    jmp     .done
.after:
    add     esi, edx
    sub     ecx, edx
    push    ecx
    rep     movsb
    pop     ecx
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
    jmp     .done

.after:
    cmp     edx, ecx
    je      .done
    inc     edx

.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Delete a section from the buffer  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bufdels:
; The section has to be right before the cursor,
; right after the cursor or the whole buffer
;Parameters
;  edi = buffer address
;  ecx = buffer size
;  ebx = gap start offset
;  edx = gap end offset
;  esi = section start offset
;  eax = section end offset
;Output
;  ebx = final gap start offset
;  edx = final gap end offset
    or      esi, esi
    jnz     .before
    cmp     eax, ecx
    jne     .before
    xor     ebx, ebx
    mov     edx, ecx
    jmp     .done

.before:
    cmp     esi, ebx
    jge     .after
    mov     ebx, esi
    jmp     .done
.after:
    mov     edx, eax
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Move the gap so that it starts at a specific offset  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

movegap:
;Parameters
;  edi = buffer address
;  eax = new gap start offset
;  ebx = gap start offset
;  edx = gap end offset
;Output
;  ebx = final gap start offset
;  edx = final gap end offset

    cmp     eax, ebx
    jg      .right

; move to the left
    ; number of bytes to move
    mov     ecx, ebx
    sub     ecx, eax

    mov     esi, edi
    add     esi, eax

    add     edi, edx
    sub     edi, ecx

    push    ecx
    cld
    rep     movsb
    pop     ecx

    mov     ebx, eax
    sub     edx, ecx

    jmp     .done

.right:
    ; number of bytes to move
    mov     ecx, eax
    sub     ecx, edx

    mov     esi, edi
    add     esi, edx

    add     edi, ebx

    push    ecx
    cld
    rep     movsb
    pop     ecx

    add     ebx, ecx
    add     edx, ecx

.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Count the number of characters from the beginning of the current line  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lineoffset:
;Parameters
;  edi = buffer address
;  ebx = gap start offset
;Output
;  ecx = line offset
    xor     ecx, ecx

    ; find a previous linefeed character
.loop:
    or      ebx, ebx
    jz      .done

    dec     ebx
    inc     ecx

    mov     al, [edi+ebx]
    cmp     al, 0x0a
    jne     .loop

.done:
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Find the offset of the start of the previous line  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

previousline:
;Parameters
;  edi = buffer address
;  ebx = gap start offset
;Output
;  al = 1 if there is a previous line, 0 otherwise
;  ecx = previous line offset

    push    edi
    push    ebx
    call    lineoffset
    pop     ebx
    pop     edi


    ; the offset of the current line
    ; = offset from buffer beginning - offset from the line beginning
    sub     ebx, ecx
    jz      .notfound
    mov     ecx, ebx

    ; find a previous linefeed character
.loop:
    or      ecx, ecx
    jz      .found
    dec     ecx

    mov     al, [edi+ecx]
    cmp     al, 0x0a
    jne     .loop

.found:
    mov     eax, 1
    inc     ecx
    jmp     .done
.notfound:
    xor     eax, eax
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Find the offset of the start of the next line  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nextline:
;Parameters
;  edi = buffer address
;  ecx = buffer length
;  edx = gap end offset
;Output
;  al = 1 if there is a next line, 0 otherwise
;  ecx = next line offset
    add     edi, edx

    ; find the number of characters after the gap
    sub     ecx, edx
    jz      .notfound
    mov     ebx, ecx

    xor     ecx, ecx
.loop:
    cmp     ecx, ebx
    je      .done

    mov     al, [edi+ecx]
    inc     ecx

    cmp     al, 0x0a
    jne     .loop

.found:
    mov     eax, 1
    add     ecx, edx
    jmp     .done
.notfound:
    xor     eax, eax
.done:
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Finds the length of a line in a buffer  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

linelen:
;Parameters
;  edi = buffer address
;  ecx = buffer size
;  eax = line start offset
;  ebx = gap start offset
;  edx = gap end offset
;Output
;  ecx = line length
    enter   8, 0
    ; offset
.len:       equ 4
.n:         equ .len + 4

    mov     [ebp-.n], ecx ; save length
    mov     dword [ebp-.len], 0

    ; does the line start before the gap?
    cmp     eax, ebx
    jg      .postgap_loop


    push    eax ; save the line start offset

    ; move to the start of the line
    add     edi, eax
    ; get the number of characters before the gap
    sub     ebx, eax
.pregap_loop:
    cmp     [ebp-.len], ebx
    jz      .pregap_done

    mov     ecx, [ebp-.len]
    mov     al, [edi+ecx]
    cmp     al, 0x0a
    je      .done_pre

    inc     dword [ebp-.len]
    jmp     .pregap_loop
.pregap_done:
    ; return to the beginning of the buffer
    pop     eax
    sub     edi, eax

.postgap_loop:
    cmp     edx, [ebp-.n]
    je      .done

    mov     al, [edi+edx]
    cmp     al, 0x0a
    je      .done

    inc     edx
    inc     dword [ebp-.len]
    jmp     .postgap_loop

.done_pre:
    pop     eax
.done:
    mov     ecx, [ebp-.len]
    leave
    ret

%endif
; vim: set ft=nasm:
; vim: set commentstring=;%s:

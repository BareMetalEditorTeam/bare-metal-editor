    bits 16
    org  0x7c00


    cli
    xor     ax, ax
    mov     es, ax
    mov     ds, ax
    mov     fs, ax
    mov     gs, ax
    mov     sp, 0xFFFF


load_gdt:
    ; GDT setup
    lgdt    [GDT_descriptor]


    ; enable A20
    ; send get status command
    call    wait_kb_input
    mov     al, 0xd0
    out     0x64, al

    ; get status
    call    wait_kb_output
    in      al, 0x60
    push    eax

    ; send set status command
    call    wait_kb_input
    mov     al, 0xd1
    out     0x64, al

    ; send data byte, with enable a20 set
    call    wait_kb_input
    pop     eax
    or      al, 0x02
    out     0x60, al

    ; Load program from disk
    mov     si, DPACK
    mov     ah, 0x42
    mov     dl, 0x80
    int     0x13

    mov     ax, [blk_count]
    cmp     ax, 1
    jl      short error

    ; enable protected mode
    mov     eax, cr0
    or      eax, 1
    mov     cr0, eax

    jmp     0x08:protected

error:
    mov     ah, 0x13
    mov     al, 0x01
    mov     bx, 0x0007
    mov     cx, error_msg_len
    mov     dx, 0x0100
    mov     bp, error_msg
    int     0x10
    hlt

wait_kb_input:
    in      al, 0x64
    test    al, 2
    jnz     wait_kb_input
    ret

wait_kb_output:
    in      al, 0x64
    test    al, 1
    jz      wait_kb_output
    ret

; pmode is active!
    bits    32
protected:
    ; setup segment registers
    mov     ax, 0x10
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax
    mov     esp, 0x90000

    ; run program
    jmp     0x08:0x1000

; Editor destination address
address:
    dw      0x1000
    dw      0x0000

; Hard Disk Pack for LBA access
DPACK:
    db      0x10
    db      0x00
blk_count:
    dw      1
buffer_address:
    dw      0x1000
    dw      0x0000
lba_address:
    dq      1


; Global Descriptor Table
GDT:
.null:
    dq      0
.code:
    dw      0xffff
    dw      0x0000
    db      0x00
    db      0x9a
    db      0b11001111
    db      0x00
.data:
    dw      0xffff
    dw      0x0000
    db      0x00
    db      0x92
    db      0b11001111
    db      0x00

GDT_descriptor:
    dw      ($ - GDT) - 1
    dq      GDT

error_msg: db "There was a problem loading the program from disk!", 0x0a, 0x00
error_msg_len equ $-error_msg

    times   (0x200 - 2 - ($ - $$)) db 0
    dw      0xAA55

; vim: set ft=nasm:
; vim: set commentstring=;%s:

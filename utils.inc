%ifndef __UTILS_INC_ICLUDED
%define __UTILS_INC_ICLUDED

bits 32

scanCodeToASCII:
;Parameters
;  al = scan code of a character
;  cl = 1 for alternate code, 0 for default
;Output
;  al = ASCII code
    jmp         .start
.uppercaseScanCodeTable: db "//!@#$%^&*()-=//QWERTYUIOP[]//ASDFGHJKL;",34,"`/|ZXCVBNM<>?/// /"
.lowercaseScanCodeTable: db "//1234567890_+//qwertyuiop{}//asdfghjkl:",39,"~/\zxcvbnm,.//// /"
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
%endif
; vim: set ft=nasm:
; vim: set commentstring=;%s:

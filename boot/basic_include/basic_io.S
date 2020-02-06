
; Print a string
; Expects ds:si to be a null terminated string
print :
    push ax
    mov ah, 0Eh
._print :
    lodsb
    or al, al
    jz ext
    int 10H
    jmp ._print 
ext :
    pop ax
    ret

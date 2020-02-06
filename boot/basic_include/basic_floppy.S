Floppy_reset:
    mov ah, 0h
    mov dl, 0h
    int 13h
    jc Floppy_reset 
    ret

; @breif Read sector(s) into memory
; Read from a floppy into memory from es:bx
; @param al Sectors to read
; @param ch Cylinder Number
; @param cl Sector Number
; @param dh Head Number
; @return ah Status code
; @return al Number of sectors read
; @return cf set if failed, else cleared
Floppy_read:
    mov ah, 2h
    mov dl, 0h
    int 13h
    ret




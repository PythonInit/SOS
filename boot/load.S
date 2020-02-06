bits 16

start:  jmp loader

times 0Bh-$+start db 0

;http://www.dewassoc.com/kbase/hard_drives/boot_sector.htm#re
; OEM parameter blocks
bpbBytesPerSector:     dw 512
bpbSectorsPerCluster:  db 1
bpbReservedSectors:    dw 1
bpbNumberOfFATs:       db 2
bpbRootEntries:        dw 224
bpbTotalSectors:       dw 2880
bpbMedia:              db 0xF0
bpbSectorsPerFAT:      dw 9
bpbSectorsPerTrack:    dw 18
bpbHeadsPerCylinder:   dw 2
bpbHiddenSectors:      dd 0
bpbTotalSectorsBig:    dd 0
bsDriveNumber:         db 0
bsUnused:              db 0
bsExtBoodSignature:    db 0x29
bsSerialNumber:        dd 0x1
bsVolumeLabel:         db "SOS OS     "
bsFileSystem:          db "FAT12   "

%include "boot/basic_include/basic_io.S"
%include "boot/basic_include/basic_floppy.S"
s1: db "Preparing to jump",10,13,0
s2: db "Resetting floppy",10,13,0
s3: db "Reading sector 2",10,13,0
global main
main:
loader :
    cli 

    mov ax, 7C0h
    mov ds, ax

    mov si, s1

    call print

    mov si, s2

.Floppy_reset_retry:
    call print
    call Floppy_reset
    jc .Floppy_reset_retry

    mov si, s3
.Floppy_read_retry:
    call print    
    mov al, 1
    mov ch, 1
    mov cl, 2
    mov dh, 0
    call Floppy_read
    jc .Floppy_reset_retry

    jmp 1000h:0h ; Jump to the execution sector
    hlt 

times 510 - ($ - $$) db 0
dw 0xAA55
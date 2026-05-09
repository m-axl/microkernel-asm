; ============================================================================
; Stage 1 BIOS boot sector
; ============================================================================
; Loads the flat kernel image from disk sector 2 into 0000:1000 and jumps to it.

[bits 16]
[org 0x7C00]

KERNEL_OFFSET  equ 0x1000
KERNEL_SECTORS equ 8

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, [boot_drive]
    mov bx, KERNEL_OFFSET
    int 0x13
    jc disk_error

    jmp 0x0000:KERNEL_OFFSET

disk_error:
    mov si, disk_error_msg
    call bios_print

.halt:
    hlt
    jmp .halt

bios_print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp bios_print
.done:
    ret

boot_drive db 0
disk_error_msg db "Disk read error", 13, 10, 0

times 510 - ($ - $$) db 0
dw 0xAA55

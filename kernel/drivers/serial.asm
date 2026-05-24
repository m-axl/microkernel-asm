; ============================================================================
; Serial Driver - COM1 routines for 64-bit kernel code
; ============================================================================

[bits 64]

serial_init_64:
    mov dx, COM1 + 1
    mov al, 0x00
    out dx, al
    mov dx, COM1 + 3
    mov al, 0x80
    out dx, al
    mov dx, COM1 + 0
    mov al, 0x01
    out dx, al
    mov dx, COM1 + 1
    mov al, 0x00
    out dx, al
    mov dx, COM1 + 3
    mov al, 0x03
    out dx, al
    mov dx, COM1 + 2
    mov al, 0xC7
    out dx, al
    mov dx, COM1 + 4
    mov al, 0x0B
    out dx, al
    ret

serial_putchar_64:
    push rax
    push rdx
    mov ah, al
.wait:
    mov dx, COM1 + 5
    in al, dx
    test al, 0x20
    jz .wait
    mov al, ah
    mov dx, COM1
    out dx, al
    pop rdx
    pop rax
    ret

serial_print_64:
    push rax
    push rdx
    push rsi
.next:
    mov al, [rsi]
    test al, al
    jz .done
    inc rsi
.wait:
    mov dx, COM1 + 5
    in al, dx
    test al, 0x20
    jz .wait
    mov al, [rsi - 1]
    mov dx, COM1
    out dx, al
    jmp .next
.done:
    pop rsi
    pop rdx
    pop rax
    ret

serial_print_newline_64:
    mov al, 10
    call serial_putchar_64
    ret

serial_print_hex_64:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi

    mov rdx, rax
    mov rcx, 16
    lea rsi, [rel serial_hex_digits]
.next:
    mov rbx, rdx
    shr rbx, 60
    and ebx, 0x0F
    mov al, [rsi + rbx]
    call serial_putchar_64
    shl rdx, 4
    loop .next

    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

serial_hex_digits db "0123456789ABCDEF"

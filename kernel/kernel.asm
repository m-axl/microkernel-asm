; ============================================================================
; NeXus - Milestone 0 kernel entry
; ============================================================================
; This is a real-mode bootstrap kernel. It gives the project a bootable,
; testable baseline before protected mode, long mode, paging and ring3 servers.

[bits 16]
[org 0x1000]

%include "include/kernel.inc"

kernel_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, STACK_TOP
    sti

    call serial_init
    mov si, serial_banner
    call serial_print

    call clear_screen
    call draw_header

    call init_memory
    mov si, memory_msg
    call print_ok_line

    call init_scheduler
    mov si, scheduler_msg
    call print_ok_line

    call init_ipc
    mov si, ipc_msg
    call print_ok_line

    call start_servers
    mov si, servers_msg
    call print_ok_line

    mov si, shell_msg
    mov bl, VGA_ATTR_NORMAL
    call print_line

kernel_halt:
    hlt
    jmp kernel_halt

clear_screen:
    push ax
    push cx
    push di
    mov ax, VGA_BUFFER
    mov es, ax
    xor di, di
    mov ax, (VGA_ATTR_NORMAL << 8) | ' '
    mov cx, VGA_COLS * VGA_ROWS
    rep stosw
    xor ax, ax
    mov es, ax
    mov word [cursor_offset], 0
    pop di
    pop cx
    pop ax
    ret

draw_header:
    mov si, title_line
    mov bl, VGA_ATTR_TITLE
    call print_line
    mov si, subtitle_line
    mov bl, VGA_ATTR_NORMAL
    call print_line
    call print_blank_line
    ret

print_ok_line:
    push si
    mov si, ok_prefix
    mov bl, VGA_ATTR_OK
    call print_string
    pop si
    mov bl, VGA_ATTR_NORMAL
    call print_line
    ret

print_blank_line:
    mov si, blank_line
    mov bl, VGA_ATTR_NORMAL
    call print_line
    ret

print_line:
    call print_string
    call newline
    ret

print_string:
    push ax
    push di
    push es
    mov ax, VGA_BUFFER
    mov es, ax
    mov di, [cursor_offset]
.next:
    lodsb
    test al, al
    jz .done
    cmp al, 10
    je .linefeed
    mov ah, bl
    stosw
    jmp .next
.linefeed:
    mov [cursor_offset], di
    call newline
    mov di, [cursor_offset]
    jmp .next
.done:
    mov [cursor_offset], di
    pop es
    pop di
    pop ax
    ret

newline:
    push ax
    push bx
    xor dx, dx
    mov ax, [cursor_offset]
    mov bx, VGA_COLS * 2
    div bx
    sub bx, dx
    add [cursor_offset], bx
    pop bx
    pop ax
    ret

serial_init:
    mov dx, COM1 + 1
    mov al, 0x00
    out dx, al
    mov dx, COM1 + 3
    mov al, 0x80
    out dx, al
    mov dx, COM1
    mov al, 0x03
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

serial_print:
    lodsb
    test al, al
    jz .done
    call serial_write_char
    jmp serial_print
.done:
    ret

serial_write_char:
    push ax
.wait:
    mov dx, COM1 + 5
    in al, dx
    test al, 0x20
    jz .wait
    pop ax
    mov dx, COM1
    out dx, al
    ret

%include "kernel/memory.asm"
%include "kernel/scheduler.asm"
%include "kernel/ipc.asm"
%include "servers/fs_server.asm"
%include "servers/driver_server.asm"

cursor_offset dw 0

serial_banner db "NeXus milestone 0", 13, 10, 0
title_line db " NeXus  v0.2.0-m2  |  signed by @ghostroot", 0
subtitle_line db " --------------------------------------------------------", 0
ok_prefix db " [ok] ", 0
memory_msg db "memory allocator online", 0
scheduler_msg db "round-robin scheduler table online", 0
ipc_msg db "ipc mailbox online", 0
servers_msg db "user-space server stubs registered", 0
shell_msg db 10, " root@nexus:/# _", 0
blank_line db 0

times 4096 - ($ - $$) db 0

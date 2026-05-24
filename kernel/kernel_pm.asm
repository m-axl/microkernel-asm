; ============================================================================
; NeXus - Protected Mode Kernel (Milestone 1)
; ============================================================================
; This kernel runs in protected mode (32-bit) with GDT setup.
; It transitions from real mode and establishes the foundation for 64-bit.

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

    ; Initialize in real mode first
    call serial_init_pm
    mov si, serial_banner_pm
    call serial_print_pm

    ; Setup and enter protected mode
    call setup_gdt_pm
    call enable_a20_pm
    call enter_protected_mode_pm

    ; This is reached in protected mode (32-bit code)
    ; Cannot reach here due to far jump - handled in protected mode entry

kernel_halt:
    cli
    hlt
    jmp kernel_halt

; ============================================================================
; Real-mode helper functions
; ============================================================================

serial_init_pm:
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

serial_print_pm:
    lodsb
    test al, al
    jz .done
    call serial_write_char_pm
    jmp serial_print_pm
.done:
    ret

serial_write_char_pm:
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

; ============================================================================
; Enable A20 Line
; ============================================================================
enable_a20_pm:
    push ax
    cli
    
    in al, 0x92
    test al, 0x02
    jnz .a20_done
    or al, 0x02
    out 0x92, al
    
    mov cx, 0xFFFF
.a20_wait:
    loop .a20_wait
    
.a20_done:
    sti
    pop ax
    ret

; ============================================================================
; Setup Global Descriptor Table (GDT)
; ============================================================================
setup_gdt_pm:
    push ax
    
    lgdt [gdt_ptr_pm]
    
    pop ax
    ret

; ============================================================================
; Transition to Protected Mode
; ============================================================================
enter_protected_mode_pm:
    cli
    
    ; Set CR0.PE bit to enter protected mode
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    
    ; Far jump to flush pipeline and load code selector
    jmp 0x08:protected_mode_entry

; ============================================================================
; Protected Mode Code (32-bit)
; ============================================================================
[bits 32]

protected_mode_entry:
    ; Load data segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    
    ; Setup stack
    mov esp, STACK_TOP_PM
    
    ; Clear screen and display header (VGA memory access in PM)
    call pm_clear_screen
    call pm_draw_header

    ; Initialize subsystems
    call pm_init_memory
    mov esi, memory_msg_pm
    call pm_print_ok_line

    call pm_init_scheduler
    mov esi, scheduler_msg_pm
    call pm_print_ok_line

    call pm_init_ipc
    mov esi, ipc_msg_pm
    call pm_print_ok_line

    call pm_start_servers
    mov esi, servers_msg_pm
    call pm_print_ok_line

    mov esi, shell_msg_pm
    mov bl, VGA_ATTR_NORMAL
    call pm_print_line

pm_kernel_halt:
    cli
    hlt
    jmp pm_kernel_halt

; ============================================================================
; Protected Mode Display Functions (32-bit)
; ============================================================================

pm_clear_screen:
    push eax
    push ecx
    push edi
    
    mov eax, 0xB8000        ; VGA buffer address
    mov edi, eax
    mov eax, (VGA_ATTR_NORMAL << 8) | ' '
    mov ecx, VGA_COLS * VGA_ROWS
    rep stosd
    
    mov dword [pm_cursor_offset], 0
    
    pop edi
    pop ecx
    pop eax
    ret

pm_draw_header:
    mov esi, title_line_pm
    mov bl, VGA_ATTR_TITLE
    call pm_print_line
    mov esi, subtitle_line_pm
    mov bl, VGA_ATTR_NORMAL
    call pm_print_line
    call pm_print_blank_line
    ret

pm_print_ok_line:
    push esi
    mov esi, ok_prefix_pm
    mov bl, VGA_ATTR_OK
    call pm_print_string
    pop esi
    mov bl, VGA_ATTR_NORMAL
    call pm_print_line
    ret

pm_print_blank_line:
    mov esi, blank_line_pm
    mov bl, VGA_ATTR_NORMAL
    call pm_print_line
    ret

pm_print_line:
    call pm_print_string
    call pm_newline
    ret

pm_print_string:
    push eax
    push edi
    
.next:
    mov al, [esi]
    test al, al
    jz .done
    inc esi
    cmp al, 10
    je .linefeed
    mov ah, bl
    mov edi, 0xB8000
    add edi, [pm_cursor_offset]
    mov [edi], ax
    add dword [pm_cursor_offset], 2
    jmp .next
.linefeed:
    call pm_newline
    jmp .next
.done:
    pop edi
    pop eax
    ret

pm_newline:
    push eax
    push edx
    xor edx, edx
    mov eax, [pm_cursor_offset]
    mov edx, VGA_COLS * 2
    xor ecx, ecx
    mov ecx, edx
    xor edx, edx
    div ecx
    sub ecx, edx
    add [pm_cursor_offset], ecx
    pop edx
    pop eax
    ret

; ============================================================================
; Protected Mode Subsystem Initialization (32-bit)
; ============================================================================

pm_init_memory:
    mov dword [pm_free_mem], MEMORY_BASE
    ret

pm_init_scheduler:
    ; Initialize scheduler state (stub for now)
    ret

pm_init_ipc:
    ; Initialize IPC (stub for now)
    ret

pm_start_servers:
    ; Start server stubs (stub for now)
    ret

; ============================================================================
; GDT Definition (Real-mode)
; ============================================================================
[bits 16]

align 16
gdt_table_pm:
    ; Null descriptor
    dq 0x0000000000000000
    
    ; Kernel code (0x08)
    dq 0x00CF9A000000FFFF
    
    ; Kernel data (0x10)
    dq 0x00CF92000000FFFF
    
    ; User code (0x18)
    dq 0x00CFFA000000FFFF
    
    ; User data (0x20)
    dq 0x00CFF2000000FFFF

gdt_ptr_pm:
    dw $ - gdt_table_pm - 1
    dd gdt_table_pm

; ============================================================================
; Data Section (Real-mode)
; ============================================================================

pm_cursor_offset dd 0
pm_free_mem dd 0

serial_banner_pm db "NeXus milestone 1 (protected mode)", 13, 10, 0
title_line_pm db " NeXus  v0.2.0-m2  |  protected mode", 0
subtitle_line_pm db " --------------------------------------------------------", 0
ok_prefix_pm db " [ok] ", 0
memory_msg_pm db "memory allocator online", 0
scheduler_msg_pm db "round-robin scheduler table online", 0
ipc_msg_pm db "ipc mailbox online", 0
servers_msg_pm db "user-space server stubs registered", 0
shell_msg_pm db 10, " root@nexus:/# _", 0
blank_line_pm db 0

times 4096 - ($ - $$) db 0

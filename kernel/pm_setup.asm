; ============================================================================
; Protected Mode Setup
; ============================================================================
; Enables A20 line, sets up GDT, and transitions to protected mode.
; Called from real-mode kernel during boot.

[bits 16]

; ============================================================================
; Enable A20 Line (using fast method - PS/2 controller)
; ============================================================================
enable_a20:
    push ax
    
    ; Disable interrupts
    cli
    
    ; Try the fast A20 method first (Intel 8042 keyboard controller)
.a20_fast:
    in al, 0x92         ; Read from port 0x92
    test al, 0x02       ; Check if A20 is already set
    jnz .a20_done
    or al, 0x02         ; Set A20 bit
    out 0x92, al        ; Write back
    
    ; Wait a bit for A20 to stabilize
    mov cx, 0xFFFF
.a20_wait_loop:
    loop .a20_wait_loop
    
.a20_done:
    sti
    pop ax
    ret

; ============================================================================
; Setup Global Descriptor Table (GDT)
; ============================================================================
setup_gdt:
    push ax
    push si
    
    ; Load GDTR with address of GDT table
    mov ax, gdt_start
    mov [gdt_ptr + 2], ax
    lgdt [gdt_ptr]
    
    pop si
    pop ax
    ret

; ============================================================================
; Transition to Protected Mode
; ============================================================================
; Sets CR0.PE bit and jumps to protected mode code
enter_protected_mode:
    push ax
    
    ; Set PE bit in CR0
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax
    
    ; Far jump to protected mode code at offset 0x08 (kernel code selector)
    ; This also clears the prefetch queue
    jmp 0x08:pm_entry
    
    ; This code is never reached (jmp doesn't return)
    pop ax
    ret

; ============================================================================
; Protected Mode Entry Point
; ============================================================================
[bits 32]
pm_entry:
    ; Reload segment registers with kernel data selector (0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    
    ; Update stack pointer for protected mode
    mov esp, STACK_TOP_PM
    
    ; Return to caller (will be in protected mode now)
    ; Caller must handle the context switch
    jmp pm_continue

[bits 16]

; ============================================================================
; GDT Definition
; ============================================================================
align 16
gdt_start:
    ; Null descriptor (required)
    dq 0x0000000000000000
    
    ; Kernel code descriptor (offset 0x08)
    ; Base: 0x0000, Limit: 0xFFFF, Present, DPL=0, Executable, Readable
    dq 0x00CF9A000000FFFF
    
    ; Kernel data descriptor (offset 0x10)
    ; Base: 0x0000, Limit: 0xFFFF, Present, DPL=0, Data, Writable
    dq 0x00CF92000000FFFF
    
    ; User code descriptor (offset 0x18) - for future ring3
    ; Base: 0x0000, Limit: 0xFFFF, Present, DPL=3, Executable, Readable
    dq 0x00CFFA000000FFFF
    
    ; User data descriptor (offset 0x20) - for future ring3
    ; Base: 0x0000, Limit: 0xFFFF, Present, DPL=3, Data, Writable
    dq 0x00CFF2000000FFFF

gdt_end:

gdt_ptr:
    dw gdt_end - gdt_start - 1  ; GDT limit (size - 1)
    dd 0                         ; GDT base address (filled at runtime)

; ============================================================================
; Constants for protected mode
; ============================================================================
STACK_TOP_PM equ 0x9000

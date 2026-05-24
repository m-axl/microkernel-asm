; ============================================================================
; Interrupt Module - x86-64 IDT and exception halt handlers
; ============================================================================

[bits 64]

IDT_ENTRY_BYTES equ 16
IDT_ATTR_INT64  equ 0x8E
KERNEL_CS64     equ 0x18

idt_table: times 32 * IDT_ENTRY_BYTES db 0
idt_ptr:
    dw 32 * IDT_ENTRY_BYTES - 1
    dq idt_table

%macro exception_noerr 1
align 16
exception_%1:
    mov rdi, %1
    xor rsi, rsi
    jmp exception_common
%endmacro

%macro exception_err 1
align 16
exception_%1:
    pop rsi
    mov rdi, %1
    jmp exception_common
%endmacro

exception_noerr 0
exception_noerr 1
exception_noerr 2
exception_noerr 3
exception_noerr 4
exception_noerr 5
exception_noerr 6
exception_noerr 7
exception_err 8
exception_noerr 9
exception_err 10
exception_err 11
exception_err 12
exception_err 13
exception_err 14
exception_noerr 15
exception_noerr 16
exception_err 17
exception_noerr 18
exception_noerr 19

exception_common:
    mov rbx, rsi
    lea rsi, [rel exception_msg]
    call serial_print_64
    mov rax, rdi
    call serial_print_hex_64

    lea rsi, [rel exception_error_msg]
    call serial_print_64
    mov rax, rbx
    call serial_print_hex_64

    cmp rdi, 14
    jne .halt
    lea rsi, [rel exception_cr2_msg]
    call serial_print_64
    mov rax, cr2
    call serial_print_hex_64
.halt:
    lea rsi, [rel exception_halt_msg]
    call serial_print_64
    cli
    hlt
    jmp .halt

idt_init:
    push rax
    push rcx
    push rdi

    lea rdi, [rel idt_table]
    xor eax, eax
    mov ecx, 32 * IDT_ENTRY_BYTES / 8
    rep stosq

    lea rax, [rel exception_0]
    mov edi, 0
    call idt_set_entry
    lea rax, [rel exception_6]
    mov edi, 6
    call idt_set_entry
    lea rax, [rel exception_8]
    mov edi, 8
    call idt_set_entry
    lea rax, [rel exception_13]
    mov edi, 13
    call idt_set_entry
    lea rax, [rel exception_14]
    mov edi, 14
    call idt_set_entry

    pop rdi
    pop rcx
    pop rax
    ret

idt_load:
    lidt [rel idt_ptr]
    ret

idt_set_entry:
    push rax
    push rbx
    push rdi

    lea rbx, [rel idt_table]
    shl rdi, 4
    add rbx, rdi

    mov word [rbx], ax
    mov word [rbx + 2], KERNEL_CS64
    mov byte [rbx + 4], 0
    mov byte [rbx + 5], IDT_ATTR_INT64
    shr rax, 16
    mov word [rbx + 6], ax
    shr rax, 16
    mov dword [rbx + 8], eax
    mov dword [rbx + 12], 0

    pop rdi
    pop rbx
    pop rax
    ret

exception_msg db "[exception] vector 0x", 0
exception_error_msg db " error 0x", 0
exception_cr2_msg db " cr2 0x", 0
exception_halt_msg db " - halted", 10, 0

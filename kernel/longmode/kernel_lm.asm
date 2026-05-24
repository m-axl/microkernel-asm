; ============================================================================
; NeXus - Long Mode Kernel (Milestone 2)
; ============================================================================
; BIOS loads this flat image at 0000:1000. The image enters protected mode,
; builds minimal PML4 paging, enables IA-32e long mode, then runs 64-bit code.

[bits 16]
[org 0x1000]

%include "include/kernel.inc"

CODE32_SEL equ 0x08
DATA_SEL   equ 0x10
CODE64_SEL equ 0x18

PML4_ADDR  equ 0x10000
PDPT_ADDR  equ 0x11000
PD_ADDR    equ 0x12000

CR0_PE     equ 0x00000001
CR0_PG     equ 0x80000000
CR4_PAE    equ 0x00000020
EFER_MSR   equ 0xC0000080
EFER_LME   equ 0x00000100

PAGE_PRESENT equ 0x001
PAGE_WRITE   equ 0x002
PAGE_PS      equ 0x080

kernel_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, STACK_TOP

    call lm_serial_init_16
    mov si, lm_boot_msg
    call lm_serial_print_16

    lgdt [gdt_ptr_lm]

    mov eax, cr0
    or eax, CR0_PE
    mov cr0, eax

    jmp CODE32_SEL:protected_entry_lm

lm_serial_init_16:
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

lm_serial_print_16:
    lodsb
    test al, al
    jz .done
.wait:
    mov dx, COM1 + 5
    in al, dx
    test al, 0x20
    jz .wait
    mov dx, COM1
    mov al, [si - 1]
    out dx, al
    jmp lm_serial_print_16
.done:
    ret

[bits 32]

protected_entry_lm:
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov esp, STACK_TOP_PM

    call setup_boot_paging_lm

    mov eax, cr4
    or eax, CR4_PAE
    mov cr4, eax

    mov eax, PML4_ADDR
    mov cr3, eax

    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LME
    wrmsr

    mov eax, cr0
    or eax, CR0_PG
    mov cr0, eax

    jmp CODE64_SEL:long_entry_lm

setup_boot_paging_lm:
    push eax
    push ecx
    push edi

    mov edi, PML4_ADDR
    xor eax, eax
    mov ecx, 0x3000 / 4
    rep stosd

    mov dword [PML4_ADDR], PDPT_ADDR | PAGE_PRESENT | PAGE_WRITE
    mov dword [PML4_ADDR + 4], 0

    mov dword [PDPT_ADDR], PD_ADDR | PAGE_PRESENT | PAGE_WRITE
    mov dword [PDPT_ADDR + 4], 0

    ; Identity map the first 1 GiB using 2 MiB pages.
    xor ecx, ecx
.map_pd:
    mov eax, ecx
    shl eax, 21
    or eax, PAGE_PRESENT | PAGE_WRITE | PAGE_PS
    mov [PD_ADDR + ecx * 8], eax
    mov dword [PD_ADDR + ecx * 8 + 4], 0
    inc ecx
    cmp ecx, 512
    jne .map_pd

    pop edi
    pop ecx
    pop eax
    ret

[bits 64]

long_entry_lm:
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov rsp, 0x90000

    call kernel_main_64

.halt:
    cli
    hlt
    jmp .halt

align 16
gdt_table_lm:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF
    dq 0x00CF92000000FFFF
    dq 0x00AF9A000000FFFF

gdt_ptr_lm:
    dw gdt_ptr_lm - gdt_table_lm - 1
    dd gdt_table_lm

lm_boot_msg db "NeXus milestone 2 bootstrap", 13, 10, 0

%include "kernel/drivers/serial.asm"
%include "kernel/paging/paging.asm"
%include "kernel/interrupt/idt.asm"

kernel_main_64:
    call serial_init_64

    lea rsi, [rel kernel_banner_64]
    call serial_print_64

    call paging_init
    lea rsi, [rel paging_ok_msg]
    call serial_print_64

    call idt_init
    call idt_load
    lea rsi, [rel idt_ok_msg]
    call serial_print_64

    call paging_stats
    push rdx
    lea rsi, [rel paging_stats_msg]
    call serial_print_64
    call serial_print_hex_64
    lea rsi, [rel paging_free_msg]
    call serial_print_64
    pop rax
    call serial_print_hex_64
    call serial_print_newline_64

    lea rsi, [rel kernel_ready_msg]
    call serial_print_64

.halt:
    cli
    hlt
    jmp .halt

kernel_banner_64:
    db "========================================", 10
    db " NeXus v0.2.0-m2 - Long Mode x86-64", 10
    db "========================================", 10, 0

paging_ok_msg db "[ok] bootstrap paging active (1 GiB identity map)", 10, 0
idt_ok_msg db "[ok] IDT loaded for CPU exceptions", 10, 0
paging_stats_msg db "[*] Pages allocated: 0x", 0
paging_free_msg db ", free: 0x", 0
kernel_ready_msg db "[ok] 64-bit kernel ready", 10, 0

times 4096 - ($ - $$) db 0

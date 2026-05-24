; ============================================================================
; Long Mode Module - Transition from Protected Mode to x86-64
; ============================================================================
; Implements PAE setup, EFER configuration, and far jump to 64-bit code

[bits 32]

; ============================================================================
; Constants for Long Mode Transition
; ============================================================================

CR4_PAE         equ 0x20            ; CR4 bit 5: Physical Address Extension
CR4_PGE         equ 0x80            ; CR4 bit 7: Page Global Enable
CR0_PG          equ 0x80000000      ; CR0 bit 31: Paging
CR0_PE          equ 0x01            ; CR0 bit 0: Protected Mode
EFER_LME        equ 0x100           ; EFER bit 8: Long Mode Enable
EFER_NXE        equ 0x800           ; EFER bit 11: No-Execute Enable
MSR_EFER        equ 0xC0000080      ; Extended Feature Enable Register

; ============================================================================
; Setup Long Mode
; ============================================================================
; Called from protected mode (32-bit)
; Assumes paging has been initialized with PML4 table

    global longmode_prepare

longmode_prepare:
    push eax
    push edx
    
    ; Enable PAE in CR4
    mov eax, cr4
    or eax, CR4_PAE
    or eax, CR4_PGE                 ; Also enable global pages
    mov cr4, eax
    
    ; Load PML4 address into CR3 (parameter in edi)
    mov eax, edi                    ; rdi already set by caller
    mov cr3, eax
    
    ; Enable EFER.LME (long mode)
    mov ecx, MSR_EFER
    rdmsr                           ; Read EFER into EDX:EAX
    or eax, EFER_LME
    or eax, EFER_NXE                ; Enable NX bit
    wrmsr                           ; Write back
    
    ; Enable paging (already in protected mode)
    mov eax, cr0
    or eax, CR0_PG
    mov cr0, eax
    
    pop edx
    pop eax
    ret

; ============================================================================
; Enter Long Mode
; ============================================================================
; Far jump to 64-bit code segment (assumes GDT has code selector at 0x18)
; This is an indirect jump - does not return

    global longmode_enter

longmode_enter:
    ; Do a far jump to 64-bit code
    ; ljmp 0x18:longmode_entry64
    
    ; Using indirect far jump via memory:
    jmp dword far [longmode_entry_addr]

; Data for far jump
align 8
longmode_entry_addr:
    dd longmode_entry64_start       ; 32-bit offset
    dw 0x18                         ; 64-bit code selector

; ============================================================================
; 64-bit Entry Point
; ============================================================================
; Executed in long mode (64-bit)

[bits 64]

    global longmode_entry64_start

align 16
longmode_entry64_start:
    ; Now in 64-bit mode
    
    ; Setup 64-bit stack
    mov rsp, 0x7000                 ; Stack at 28 KB
    
    ; Initialize GS base for per-CPU data (future use)
    mov rcx, 0xC0000101             ; IA32_GS_BASE MSR
    xor eax, eax
    xor edx, edx
    wrmsr
    
    ; Call kernel entry point (from kernel_lm.asm)
    call kernel_main_64
    
    ; Should not reach here
    cli
    hlt

; ============================================================================
; Utility: Print 64-bit value in hex via serial
; ============================================================================

    global print_hex_64

print_hex_64:
    ; rax = value to print
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    
    lea rsi, [hex_digits]
    mov rcx, 16                     ; 16 hex digits
    
.print_loop:
    ; Extract high nibble
    mov ebx, eax
    shr ebx, 28
    and ebx, 0x0F
    
    movzx rax, byte [rsi + rbx]
    call serial_putchar_64          ; Not yet defined, placeholder
    
    ; Shift left for next digit
    shl eax, 4
    
    loop .print_loop
    
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Hex digit lookup
hex_digits: db "0123456789ABCDEF"

; ============================================================================
; Forward declarations (in serial.asm)
; ============================================================================

extern serial_putchar_64
extern kernel_main_64

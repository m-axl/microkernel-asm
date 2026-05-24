# Interrupt - Módulo de Interrupções e Exceções

## Responsabilidades

Este módulo gerencia interrupções (hardware e software) e exceções da CPU:

- **IDT (Interrupt Descriptor Table)**: Tabela de 256 descritores de interrupção
- **Exception handlers**: Divide-by-zero, Page Fault, GPF, etc.
- **IRQ routing**: PIC (8259) ou APIC (Advanced)
- **ISR (Interrupt Service Routines)**: Rotinas de tratamento

## Arquivos

- `idt.asm` - Setup e gerenciamento da IDT
- `exceptions.asm` - Handlers para exceções x86-64
- `pic.asm` - Programação do PIC (8259) para IRQs
- `apic.asm` - Suporte futuro para APIC

## Exceções Tratadas (Milestone 2)

| Vetor | Nome | Handler | Ação |
|-------|------|---------|------|
| 0 | #DE | divide_error | Print debug, halt |
| 6 | #UD | invalid_opcode | Print debug, halt |
| 8 | #DF | double_fault | Print debug, halt |
| 11 | #NP | segment_not_present | Print debug, halt |
| 12 | #SS | stack_fault | Print debug, halt |
| 13 | #GP | general_protection | Print debug, halt |
| 14 | #PF | page_fault | Handle ou halt |

## Interface

```asm
; Inicializar IDT
call idt_init

; Registrar um handler
call idt_set_entry  ; param: rdi = vetor, rsi = handler_address, rdx = flags

; Limpar entry
call idt_clear_entry ; param: rdi = vetor

; Carregar IDTR
call idt_load        ; sem parâmetros
```

## Constantes

```asm
GATE_INTERRUPT  = 0xE   ; Interrupt gate (CLI automático)
GATE_TRAP       = 0xF   ; Trap gate (sem CLI)
DPL_KERNEL      = 0     ; Descriptor Privilege Level = 0
DPL_USER        = 3     ; Descriptor Privilege Level = 3
```

## Page Fault Handler

Trata #PF (vetor 14) com código de erro:

```
Bits 0: P (Present) - 1 if page table entry is present
Bits 1: R/W (Write) - 1 if access was write
Bits 2: U/S (User) - 1 if access was from user mode
Bits 3: RSVD (Reserved write) - 1 if reserved bits violated
Bits 4: I/D (Instruction fetch) - 1 if instruction fetch
```

## Limitações (v0.1)

- Sem stack switching (#DF, #SS)
- Sem nested interrupt handling
- Sem interrupt priority levels
- PIC fixo em IRQ0-15

## Próximas Funcionalidades

- APIC support (Local + I/O)
- Nested interrupt queuing
- IRQ priorities
- MSI/MSI-X para devices

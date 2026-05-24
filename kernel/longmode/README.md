# Long Mode - Módulo de Transição e Execução em x86-64

## Responsabilidades

Este módulo gerencia a transição de protected mode (32-bit) para long mode (64-bit) e execução nativa em 64 bits:

- **PAE activation**: Ativar PAE no CR4
- **EFER setup**: Ativar long-mode flag (LME) no MSR 0xC0000080
- **Far jump**: Salto de 32-bit para 64-bit code
- **64-bit kernel**: Entrada e ambiente 64-bit

## Arquivos

- `kernel_lm.asm` - Bootstrap bootável M2 e entrada do kernel em 64-bit
- `longmode.asm` - Rotinas de referência para setup e transição para long mode

## Estágios de Transição

### Estágio 1: Protected Mode Setup (32-bit)
```
1. GDT com segmentos 32-bit e 64-bit carregada
2. PML4/PDPT/PD inicializadas em memoria fixa
3. PAE habilitado (CR4.PAE = 1)
4. CR3 aponta para PML4
5. EFER.LME = 1 (ativar long mode)
6. CR0.PG = 1 (paginação ativa)
```

### Estágio 2: Transição (32-bit jump)
```
jmp 0x18:long_entry_lm  ; Jump para 64-bit code
```

### Estágio 3: Long Mode (64-bit)
```
- Registradores RIP, RSP, RAX-R15 de 64 bits
- Virtual address space de 48 bits (256 TB)
- Stack de 64 bits
```

## Funcionalidades

```asm
; Preparar transição para long mode
call longmode_prepare    ; param: rdi = PML4 address

; Executar transição (não retorna, continua em 64-bit)
call longmode_enter

; Funções em 64-bit
call print_64bit        ; Serial output de 64-bit
call test_registers     ; Testar registradores
```

## Verificações CPUID

- Bit 29: LM (Long Mode Available) - Suporte a 64-bit
- Bit 26: PDM (Physical Address Extension) - PAE
- Bit 16: PAT (Page Attribute Table)
- Bit 12: MTRR (Memory Type Range Registers)

## Constantes

```asm
CR4_PAE         = 0x20      ; CR4 bit 5: Physical Address Extension
CR0_PG          = 0x80000000 ; CR0 bit 31: Paging
CR0_PE          = 0x01      ; CR0 bit 0: Protected Mode
EFER_LME        = 0x100     ; EFER bit 8: Long Mode Enable
EFER_NXE        = 0x800     ; EFER bit 11: No-Execute Enable
```

## Limitações (v0.1)

- Sem CPUID check para long-mode (assume suporte)
- Sem NX bit obrigatório nesta etapa
- Sem SME (Secure Memory Encryption)

## Próximas Funcionalidades

- CPUID verification antes de transição
- NX bit support (DEP - Data Execution Prevention)
- 5-level paging (LA57) para endereços maiores
- SMEP/SMAP (Supervisor Mode Execution/Access Prevention)

# Paging - Módulo de Gerenciamento de Memória Paginada

## Responsabilidades

Este módulo gerencia a paginação x86-64 com hierarquia PML4 (4-level page tables):

- **PML4 (Page Map Level 4)**: Tabela de nível superior (511 entradas úteis)
- **PDPT (Page Directory Pointer Table)**: Nível 2
- **PD (Page Directory)**: Nível 3
- **PT (Page Table)**: Nível 4 (folhas)

## Arquivos

- `paging.asm` - Estado minimo de paginação e alocador físico inicial

## Funcionalidades

### v0.1 (Milestone 2)
- [x] Identity mapping do primeiro 1 GiB no bootstrap M2
- [x] PML4/PDPT/PD inicializadas em runtime para manter o binário pequeno
- [x] Alocador físico bump de páginas de 4 KiB
- [ ] Demand paging
- [ ] Swap support

## Interface

```asm
; Inicializar paginação
call paging_init

; Alocar uma página física
call page_alloc    ; ret: rax = endereço da página (4 KB aligned)

; Liberar uma página
call page_free     ; param: rdi = endereço da página

```

## Constantes

```asm
PAGE_SIZE       = 0x1000        ; 4 KiB
PAGE_PRESENT    = 0x01          ; P bit
PAGE_WRITE      = 0x02          ; R/W bit
PAGE_USER       = 0x04          ; U/S bit
PAGE_WT         = 0x08          ; PWT (write-through)
PAGE_CD         = 0x10          ; PCD (cache-disable)
PAGE_ACCESSED   = 0x20          ; A bit
PAGE_DIRTY      = 0x40          ; D bit
PAGE_PS         = 0x80          ; PS (page size)
PAGE_GLOBAL     = 0x100         ; G bit
```

## Limitações (v0.1)

- Apenas identity mapping (VA = PA)
- Sem NUMA support
- Sem huge pages (1GB, 2MB)
- `page_free` ainda é stub; free-list/bitmap fica para M3+
- Sem API `page_map`/`page_unmap` ainda

## Próximas Funcionalidades

- Virtual address mapping (VA ≠ PA)
- Demand paging com page faults
- Swap support via server
- NUMA-aware allocation

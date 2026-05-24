# Build e Execução - NeXus

**Versão atual:** `0.2.0-m2`

## Dependências

- `nasm` - Netwide Assembler (NASM 2.15+)
- `qemu-system-x86_64` - QEMU x86-64 emulator
- `make` - GNU Make
- `xxd` e `od` - Para análise hexadecimal

## Compilar

### Milestone 0 (Real Mode - padrão)
```bash
make all        # Compila imagem bootável real-mode
make clean      # Remove artifacts de build
```

### Milestone 1 (Protected Mode)
```bash
make pm         # Compila imagem bootável protected-mode
```

### Milestone 2 (Long Mode x86-64)
```bash
make lm         # Compila imagem bootavel long-mode
```

### Verificações
```bash
make check      # Valida tamanho de boot sector e kernel
make quality    # Executa todas as verificações
```

## Executar

### Real Mode (Milestone 0)
```bash
make run        # Executa imagem em QEMU (headless)
make debug      # Executa com console serial em stdio e debugger (gdb -q -ex 'target remote :1234')
```

### Protected Mode (Milestone 1)
```bash
make pm-run     # Executa imagem PM em QEMU (headless)
make pm-debug   # Executa com console serial em stdio e debugger
```

### Long Mode (Milestone 2)
```bash
make lm-run     # Executa imagem LM em QEMU
make lm-debug   # Executa com console serial em stdio e debugger
```

## Estrutura de Build

```
build/
├── boot.bin         # Boot sector (512 bytes)
├── kernel.bin       # Real-mode kernel (max 4096 bytes)
├── kernel_pm.bin    # Protected-mode kernel (max 4096 bytes)
├── kernel_lm.bin    # Long-mode kernel/bootstrap (max 4096 bytes)
├── os.img           # Final image real-mode (boot + kernel)
├── os_pm.img        # Final image protected-mode (boot + kernel_pm)
└── os_lm.img        # Final image long-mode (boot + kernel_lm)
```

## Limites

- **Boot sector**: Exatamente 512 bytes (com assinatura `55 AA`)
- **Kernel**: Máximo 8 setores = 4096 bytes
- **Imagem total**: 512 + 4096 = 4608 bytes
- **M2**: As tabelas PML4/PDPT/PD ficam em memoria fixa inicializada em runtime
  para manter `kernel_lm.bin` dentro dos 8 setores carregados pelo bootloader.

## Debugging

### Breakpoints via GDB

```bash
make pm-debug
# Em outro terminal:
gdb -q -ex 'target remote :1234' -ex 'break *0x1000' -ex 'continue'
```

### Análise de imagem

```bash
# Ver boot signature
od -An -tx1 -j510 -N2 build/os.img | grep -qi "55 aa" && echo "OK"

# Ver conteúdo em hex
xxd build/os.img | head -20
```

## Constantes

Definidas em `include/kernel.inc`:

- `COM1 = 0x3F8` - Serial port I/O address
- `STACK_TOP = 0x9000` - Stack real-mode
- `STACK_TOP_PM = 0x90000` - Stack protected-mode
- `KERNEL_LOAD_ADDR = 0x1000` - Kernel load address
- `MEMORY_BASE = 0x2000` - Usable memory start inicial

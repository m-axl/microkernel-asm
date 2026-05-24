# Testes e qualidade

## Dependências

- `nasm` (2.15+) - Assembler
- `make` - Build automation
- `qemu-system-x86_64` - Emulator para execução visual
- `gdb` - Debugger para análise
- `xxd`, `od` - Análise hexadecimal

## Compilação

### Real Mode (Milestone 0 - padrão)
```sh
make            # Compila tudo
make all        # Equivalente a make
make clean      # Remove artifacts
```

### Protected Mode (Milestone 1)
```sh
make pm         # Compila versão protected mode
make clean      # Remove todos os artifacts
```

## Validação e Testes

### Checks de build
```sh
make check      # Valida tamanhos, assinatura e recompilação isolada
make quality    # Executa check + static analysis (scripts/quality.sh)
```

**O que `make check` valida:**
- `boot.bin` tem exatamente 512 bytes
- Boot sector signature é `55 aa`
- `kernel.bin` cabe nos 8 setores (4096 bytes max)
- `os.img` possui tamanho esperado (512 + 4096 = 4608 bytes)
- Boot e kernel recompilam isoladamente com NASM

## Execução

### Real Mode
```sh
make run        # Executa em QEMU (headless)
make debug      # Executa com serial em stdio + GDB stub na porta 1234
```

### Protected Mode
```sh
make pm-run     # Executa versão PM em QEMU (headless)
make pm-debug   # Executa com serial em stdio + GDB stub
```

## Debugging

### Via Serial Console
A saída serial é enviada para `/dev/ttyS0` (COM1). No modo debug, aparece em stdio.

### Via GDB
```bash
# Terminal 1: iniciar debug
make pm-debug

# Terminal 2: conectar ao debugger
gdb -q
(gdb) target remote :1234
(gdb) break *0x1000           # Breakpoint na entrada do kernel
(gdb) continue
(gdb) stepi                   # Step instruction
(gdb) info registers          # Ver registradores
(gdb) x/16i 0x1000           # Disassemble 16 instruções em 0x1000
```

## Análise de Imagem

### Visualizar boot sector
```bash
xxd build/os.img | head -10    # Primeiros 512 bytes
```

### Verificar assinatura
```bash
od -An -tx1 -j510 -N2 build/os.img  # Bytes 510-511 (boot signature)
```

### Tamanho
```bash
stat build/os.img              # Deve ser 4608 bytes
stat build/os_pm.img           # Deve ser 4608 bytes (PM)
```

## Limites Atuais

O teste automatizado ainda nao executa QEMU porque o ambiente pode nao ter
`qemu-system-x86_64` instalado. Quando QEMU estiver disponivel, o proximo passo
de qualidade deve capturar a saida serial e validar o banner de boot.

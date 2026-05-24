# 03 - Build e Execucao

## Dependencias

- `nasm`
- `make`
- `qemu-system-x86_64`
- `od`
- `xxd`
- `gdb` para debug remoto

## Builds principais

| Comando | Saida | Milestone |
| --- | --- | --- |
| `make` ou `make all` | `build/os.img` | M0 real-mode |
| `make pm` | `build/os_pm.img` | M1 protected-mode |
| `make lm` | `build/os_lm.img` | M2 long-mode |
| `make check` | validacoes estaticas | M0/M1/M2 |
| `make quality` | checks de qualidade | M0/M1/M2 |

## Executar

```sh
make run
make pm-run
make lm-run
```

## Debug

```sh
make debug
make pm-debug
make lm-debug
```

Os alvos `*-debug` ativam serial em stdio e GDB stub. Em outro terminal:

```sh
gdb -q
(gdb) target remote :1234
(gdb) break *0x1000
(gdb) continue
```

## Imagens geradas

```text
build/
├── boot.bin
├── kernel.bin
├── kernel_pm.bin
├── kernel_lm.bin
├── os.img
├── os_pm.img
└── os_lm.img
```

## Limites atuais

- Boot sector: `512` bytes.
- Kernel carregado pelo bootloader: `8` setores.
- Tamanho maximo por kernel: `4096` bytes.
- Tamanho total da imagem: `4608` bytes.

## Smoke test serial M2

```sh
timeout 3 qemu-system-x86_64 \
  -drive format=raw,file=build/os_lm.img \
  -serial stdio \
  -display none \
  -no-reboot
```

O timeout e esperado porque o kernel para em `hlt` depois de inicializar.

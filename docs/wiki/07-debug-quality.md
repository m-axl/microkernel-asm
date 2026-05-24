# 07 - Debug e Qualidade

## Checks principais

```sh
make check
make quality
```

`make check` valida:

- tamanho do boot sector;
- assinatura `55 aa`;
- tamanho da imagem M0;
- recompilacao isolada de boot, M0, M1 e M2.

`make quality` roda `make check` e validacoes estaticas de documentacao.

## Serial

O M2 usa serial COM1 para diagnostico.

Configuração:

- porta: `0x3F8`;
- baud divisor: `0x0001`;
- 8 bits;
- sem paridade;
- 1 stop bit.

## GDB

Inicie um alvo debug:

```sh
make lm-debug
```

Conecte:

```sh
gdb -q
(gdb) target remote :1234
(gdb) break *0x1000
(gdb) continue
```

## Verificacao de imagem

```sh
stat build/os_lm.img
od -An -tx1 -j510 -N2 build/boot.bin
xxd build/os_lm.img | head
```

## QEMU sem janela

```sh
timeout 3 qemu-system-x86_64 \
  -drive format=raw,file=build/os_lm.img \
  -serial stdio \
  -display none \
  -no-reboot
```

O retorno `124` do `timeout` e aceitavel quando a saida mostra que o kernel
chegou em `[ok] 64-bit kernel ready`.

## Falhas comuns

| Sintoma | Causa provavel | Acao |
| --- | --- | --- |
| Sem saida serial | QEMU sem `-serial stdio` | usar `make lm-debug` ou comando serial. |
| Triple fault | GDT/IDT/paging invalido | testar transicao por etapas. |
| Binario maior que 4096 | tabelas ou buffers no binario | inicializar em runtime. |
| Page fault imediato | mapping insuficiente | revisar identity map e enderecos fixos. |

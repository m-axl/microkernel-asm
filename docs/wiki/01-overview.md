# 01 - Visao Geral

NeXus e um sistema operacional experimental com arquitetura de microkernel. A
base atual e escrita em Assembly x86 para manter controle explicito sobre boot,
modos de CPU, memoria, interrupcoes e contratos de baixo nivel.

## Objetivo

O objetivo e evoluir em marcos pequenos e verificaveis:

1. criar uma base bootavel;
2. entrar em protected mode;
3. entrar em long mode x86-64;
4. adicionar interrupcoes reais e timer;
5. isolar tarefas em ring3;
6. definir syscalls, IPC e loader ELF;
7. abrir caminho para runtime e servidores em C/Rust.

## Principios

- **Pequenos passos**: cada milestone deve compilar e ser testavel.
- **Kernel pequeno**: funcionalidades maiores devem migrar para servidores.
- **Contratos explicitos**: ABI, syscall e IPC devem ser documentados antes de
  crescer.
- **Hardware primeiro**: boot, GDT, IDT, paging e context switch continuam em
  Assembly ate ficarem estaveis.
- **Produtos reais**: o projeto e dividido em Core, Boot, Drivers, Services,
  Runtime e SDK para evitar uma massa unica sem fronteiras.

## Estado atual

O Milestone 2 (`0.2.0-m2`) ja possui:

- bootstrap M2 em `kernel/longmode/kernel_lm.asm`;
- PML4 minima com identity map inicial;
- IDT x86-64 inicial;
- serial COM1 64-bit;
- imagens separadas para M0, M1 e M2.

## Saida esperada do M2

```text
NeXus milestone 2 bootstrap
========================================
 NeXus v0.2.0-m2 - Long Mode x86-64
========================================
[ok] bootstrap paging active (1 GiB identity map)
[ok] IDT loaded for CPU exceptions
[*] Pages allocated: 0x0000000000000000, free: 0x000000000000FE00
[ok] 64-bit kernel ready
```

## Proxima leitura

Continue em [02 - Arquitetura](02-architecture.md).

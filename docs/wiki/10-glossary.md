# 10 - Glossario

## A20

Linha de endereco que permite acessar memoria acima de 1 MiB em maquinas x86
compatíveis com legado BIOS.

## BIOS

Firmware legado que carrega o primeiro setor do disco em `0x7C00`.

## CR0

Registrador de controle. Bits importantes:

- `PE`: protected mode;
- `PG`: paging.

## CR3

Registrador que aponta para a tabela de paginação de nivel superior. Em long
mode x86-64, aponta para a PML4.

## CR4

Registrador de controle com flags adicionais. `PAE` e necessario para entrar
em long mode.

## EFER

MSR usado para ativar recursos extendidos. `EFER.LME` habilita long mode.

## GDT

Global Descriptor Table. Define descritores de codigo/dados usados em protected
mode e long mode.

## IDT

Interrupt Descriptor Table. Define handlers de excecoes, interrupcoes e traps.

## Identity mapping

Mapeamento em que endereco virtual e endereco fisico sao iguais.

## IPC

Inter-process communication. No NeXus, sera o contrato principal entre kernel e
servidores.

## Long mode

Modo x86-64. Exige protected mode, PAE, PML4 e `EFER.LME`.

## PAE

Physical Address Extension. Requisito para paginação usada pelo long mode.

## PML4

Page Map Level 4. Tabela raiz da paginação x86-64 de quatro niveis.

## Ring3

Nivel de privilegio de userspace. O kernel roda em ring0.

## Syscall

Entrada controlada de userspace para kernel.

## TSS

Task State Segment. Em x86-64, e usado principalmente para stacks de privilegio
e IST.

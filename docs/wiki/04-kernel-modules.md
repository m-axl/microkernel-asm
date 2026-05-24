# 04 - Modulos do Kernel

Esta pagina descreve os modulos existentes e o que pode ou nao crescer em cada
um deles.

## Boot

`boot/boot.asm`

- roda em 16-bit real mode;
- inicia em `0x7C00`;
- salva o drive da BIOS;
- carrega o kernel em `0x1000`;
- habilita A20 pelo metodo rapido;
- salta para o kernel carregado.

## Entradas de kernel

| Arquivo | Papel |
| --- | --- |
| `kernel/kernel.asm` | Kernel M0 em real-mode. |
| `kernel/kernel_pm.asm` | Kernel M1 com protected mode. |
| `kernel/longmode/kernel_lm.asm` | Kernel M2 com transicao ate long mode. |

## Long mode

`kernel/longmode/kernel_lm.asm`

- contem a entrada 16-bit do M2;
- carrega GDT com segmentos 32-bit e 64-bit;
- entra em protected mode;
- monta PML4/PDPT/PD em memoria fixa;
- ativa PAE e long mode;
- entra em codigo 64-bit;
- chama `kernel_main_64`.

## Paging

`kernel/paging/paging.asm`

- mantem estado minimo de paginas;
- implementa `page_alloc`;
- expõe `paging_stats`;
- deixa `page_free` como stub;
- evita tabelas grandes no binario para respeitar o limite de 4096 bytes.

## Interrupt

`kernel/interrupt/idt.asm`

- define IDT x86-64;
- registra handlers para excecoes principais;
- imprime diagnostico pela serial;
- captura `CR2` em page fault;
- para a CPU com `hlt` apos excecao.

## Drivers

`kernel/drivers/serial.asm`

- inicializa COM1;
- envia byte por `serial_putchar_64`;
- envia string por `serial_print_64`;
- imprime valores hexadecimais de 64 bits.

## Modulos herdados do M0

| Arquivo | Estado |
| --- | --- |
| `kernel/memory.asm` | Alocador linear inicial. |
| `kernel/scheduler.asm` | Scheduler cooperativo inicial. |
| `kernel/ipc.asm` | Mailbox minima. |
| `servers/fs_server.asm` | Stub de servidor FS. |
| `servers/driver_server.asm` | Stub de servidor driver. |

## Regras de manutencao

- Se toca registrador de CPU, GDT, IDT, paging ou syscall entry, fica no Core.
- Se conversa com hardware, entra em `kernel/drivers/`.
- Se representa servico isolavel, deve migrar para `servers/`.
- Se define contrato com userspace, deve ser documentado antes de codificado.

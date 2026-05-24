# NeXus - Subdivisões de Produto

Este documento separa o projeto em produtos funcionais reais. A ideia e manter
o kernel pequeno, mas transformar cada parte em uma entrega verificavel.

## Linha Atual

| Produto | Objetivo | Status |
| --- | --- | --- |
| **NeXus Core** | Microkernel x86-64 com boot, memoria, interrupcoes e IPC minimo. | M2 em desenvolvimento |
| **NeXus Boot** | Boot BIOS/legacy e, futuramente, UEFI/limine-style loader. | BIOS funcional |
| **NeXus Drivers** | Drivers essenciais: serial, VGA, PIT, teclado, disco e virtio. | Serial M2 |
| **NeXus Services** | Servidores isolados para FS, driver manager e processos de sistema. | Stubs M0 |
| **NeXus Runtime** | ABI de syscall, IPC, loader ELF e bibliotecas de usuario. | Planejado |
| **NeXus SDK** | Ferramentas para build, debug, testes, headers e exemplos userspace. | Planejado |

## Produtos Funcionais Pretendidos

### NeXus Core
Entrega principal do repositorio. Deve bootar em QEMU, entrar em long mode,
inicializar memoria, IDT, timer e escalonador real.

Primeira definicao de pronto:
- boot x86-64 reproduzivel;
- serial debug estavel;
- IDT carregada;
- page fault diagnosticavel;
- timer IRQ0 funcional;
- troca de contexto inicial.

### NeXus Services
Camada de servidores fora do nucleo. O alvo e validar a direcao microkernel:
drivers e filesystem nao devem crescer dentro do kernel quando puderem virar
tarefas isoladas.

Primeiros servidores:
- `fs_server`: filesystem minimo em memoria;
- `driver_server`: roteamento de drivers basicos;
- `init_server`: inicializacao de tarefas e servicos.

### NeXus Runtime
Contrato entre kernel e programas. Esta linha define syscalls, ABI de IPC,
loader ELF e uma biblioteca minima de usuario.

Primeiros artefatos:
- syscall table x86-64;
- mensagens IPC com cabecalho fixo;
- loader ELF64 estatico;
- exemplo `hello` em userspace.

### NeXus SDK
Ferramentas para tornar o projeto usavel fora do ciclo manual de QEMU.

Primeiros artefatos:
- comandos `make run-*` e `make debug-*`;
- scripts de validacao serial;
- exemplos de programas userspace;
- documentacao de ABI.

## Trilha C/Rust Futura

Assembly continua sendo a base de bootstrap e hardware bring-up. Depois que o
M3/M4 estiverem estaveis, o projeto pode ganhar duas trilhas complementares:

| Trilha | Uso esperado | Regra |
| --- | --- | --- |
| **NeXus-C** | Servidores, runtime inicial, testes de ABI e bibliotecas pequenas. | Sem substituir bootstrap critico antes do M4. |
| **NeXus-RS** | Servidores seguros, componentes de userspace e ferramentas. | Entrar depois de ABI, linker e loader ELF estarem definidos. |

A decisao entre C e Rust deve ser por produto, nao por moda:
- C e melhor para validar ABI, linker e chamadas simples rapidamente.
- Rust e melhor para servidores com estado mais complexo, depois que alocacao,
  panic strategy e ambiente `no_std` estiverem claros.
- Assembly permanece para entrada de CPU, GDT/IDT, transicoes de modo, syscall
  entry e context switch.

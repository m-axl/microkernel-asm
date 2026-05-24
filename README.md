# NeXus

NeXus e um sistema operacional experimental em Assembly, com arquitetura de
microkernel, boot progressivo x86 e foco em entregas pequenas, verificaveis e
evolutivas.

**Versão atual:** `0.2.0-m2`

## Estado atual

**Milestone 2:** long mode x86-64 em desenvolvimento, mantendo builds
separados para M0, M1 e M2.

O projeto agora gera imagens bootaveis separadas:

- boot sector valido;
- kernel carregado em `0x1000`;
- saida serial COM1 para debug;
- M0 real-mode com tela VGA, memoria, scheduler, IPC e stubs de servidores;
- M1 protected-mode com A20, GDT e entrada 32-bit;
- M2 long-mode com PML4 minima, IDT de excecoes e entrada 64-bit;
- testes de build e qualidade via `make check` e `make quality`.

## Previa

```text
 NeXus  v0.2.0-m2  |  signed by @ghostroot
 --------------------------------------------------------

 [ok] memory allocator online
 [ok] round-robin scheduler table online
 [ok] ipc mailbox online
 [ok] user-space server stubs registered

 root@nexus:/# _
```

## Principais mudanças em 0.2.0-m2

- Nome do projeto atualizado para **NeXus**.
- Bootstrap M2 com fluxo real-mode → protected-mode → long-mode.
- Paginação PML4 minima com identity mapping inicial.
- IDT x86-64 com handlers de exceções críticas.
- Driver serial 64-bit separado em `kernel/drivers/`.
- Documentação reorganizada por arquitetura, build, roadmap e produtos.

## Arquitetura

```mermaid
flowchart TD
    BIOS[BIOS] --> Boot[Boot sector]
    Boot --> Kernel[NeXus Core]
    Kernel --> Memory[Memory manager]
    Kernel --> Scheduler[Scheduler]
    Kernel --> IPC[IPC mailbox]
    Kernel --> Servers[User-space server stubs]
    Servers --> FS[File system server]
    Servers --> Drivers[Driver server]
```

## Estrutura

```text
.
├── boot/
│   └── boot.asm
├── docs/
│   ├── architecture.md
│   ├── error-analysis.md
│   ├── products.md
│   └── testing.md
├── include/
│   └── kernel.inc
├── kernel/
│   ├── drivers/
│   │   ├── README.md
│   │   └── serial.asm
│   ├── interrupt/
│   │   ├── README.md
│   │   └── idt.asm
│   ├── longmode/
│   │   ├── README.md
│   │   ├── kernel_lm.asm
│   │   └── longmode.asm
│   ├── paging/
│   │   ├── README.md
│   │   └── paging.asm
│   ├── ipc.asm
│   ├── kernel.asm
│   ├── kernel_pm.asm
│   ├── memory.asm
│   ├── pm_setup.asm
│   └── scheduler.asm
├── scripts/
│   └── quality.sh
├── servers/
│   ├── driver_server.asm
│   └── fs_server.asm
├── VERSION
└── Makefile
```

## Dependencias

```sh
sudo apt install nasm make qemu-system-x86
```

## Build e testes

```sh
make
make pm
make lm
make check
make quality
```

Executar no QEMU:

```sh
make run
make pm-run
make lm-run
```

Debug:

```sh
make debug
make pm-debug
make lm-debug
```

## Documentacao

- [Arquitetura](docs/architecture.md)
- [Analise de erros](docs/error-analysis.md)
- [Subdivisões de produto](docs/products.md)
- [Assinatura digital](docs/signature.md)
- [Testes e qualidade](docs/testing.md)

## Subdivisões de produto

- **NeXus Core**: microkernel x86-64, memoria, interrupcoes, timer e IPC.
- **NeXus Boot**: boot BIOS atual e futuro caminho UEFI.
- **NeXus Drivers**: serial, VGA, PIT, teclado, disco e virtio.
- **NeXus Services**: servidores de FS, drivers e init fora do nucleo.
- **NeXus Runtime**: syscalls, ABI IPC, loader ELF e biblioteca minima.
- **NeXus SDK**: ferramentas, exemplos e validadores de build/debug.

## Trilha futura C/Rust

O bootstrap e as rotinas criticas continuam em Assembly. Depois de timer,
context switch, syscalls e ABI de IPC, o projeto podera incluir componentes em
C ou Rust para servidores, runtime e ferramentas userspace. A escolha sera por
produto: C para validar ABI rapidamente; Rust para servidores `no_std` com mais
estado e seguranca.

## Roadmap

- [x] Boot sector BIOS valido
- [x] Kernel minimo carregado por disco
- [x] Console VGA com aparencia inicial
- [x] Stubs de memoria, scheduler, IPC e servidores
- [x] Ativar A20
- [x] Entrar em protected mode
- [x] Criar GDT inicial
- [x] Entrar em long mode x86-64
- [x] Implementar paginacao PML4 minima
- [x] Criar IDT inicial de excecoes
- [ ] Implementar interrupcao de timer
- [ ] Implementar troca de contexto real
- [ ] Criar ABI de IPC para servidores
- [ ] Adicionar processos ring3
- [ ] Criar loader ELF simples

## Convencao de commits

Use mensagens objetivas por area:

```text
boot: implement disk loader
kernel: add vga console
docs: document milestone 0
test: add image quality checks
```

## Licenca

MIT.

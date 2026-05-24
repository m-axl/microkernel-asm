# Roadmap - NeXus

Evolução planejada do NeXus por milestones, com épocas estimadas e prioridades.

**Versão atual:** `0.2.0-m2`

## Overview

```
Real Mode      Protected Mode    Long Mode       Interrupts        User Space       ELF Loader
   [✅]            [✅]            [🔄]         [Future]          [Future]         [Future]
Milestone 0    Milestone 1     Milestone 2     Milestone 3       Milestone 4      Milestone 5
```

## Milestone 0: Base Bootável ✅ COMPLETO

**Status**: Concluído em 2026-05-20 (tag: `bios_v0.1`)

### Objetivos Alcançados
- [x] Boot sector BIOS com leitura de kernel do disco
- [x] Kernel real-mode com stack e segmentos
- [x] Serial console (COM1) para debug
- [x] VGA text output para UI terminal
- [x] Memory allocator linear simples
- [x] Scheduler round-robin cooperativo
- [x] IPC mailbox primitivo
- [x] Server stubs (FS, Driver)

### Saída Terminal
```
NeXus  v0.1  |  signed by @ghostroot
-------------------------------------------------------

[ok] memory allocator online
[ok] round-robin scheduler table online
[ok] ipc mailbox online
[ok] user-space server stubs registered

root@nexus:/# _
```

### Tamanho Binário
- Boot: 512 bytes (exato)
- Kernel: ~3.2 KB (within 4 KB limit)
- Total: ~4.7 KB

---

## Milestone 1: Protected Mode ✅ COMPLETO

**Status**: Concluído em 2026-05-24 (tag: `delta_v0.1`)

### Objetivos Alcançados
- [x] A20 line ativada no bootloader (fast method via port 0x92)
- [x] GDT com descritores: null, kernel code (0x08), kernel data (0x10)
- [x] Transição real-mode → protected-mode com CR0.PE
- [x] kernel_pm.asm - entrada 32-bit protected mode
- [x] pm_setup.asm - funções A20 e GDT
- [x] Makefile targets: `make pm`, `make pm-run`, `make pm-debug`
- [x] Documentação BUILD.md e CHANGELOG.md
- [x] Verificação de compilação para ambas versões

### Builds Suportados
```bash
make        # real-mode (os.img)
make pm     # protected-mode (os_pm.img)
make check  # validate both
```

### Mudanças Técnicas
- Boot sector ainda em real mode (compatibilidade)
- Kernel pode ser real-mode (`kernel.asm`) ou protected-mode (`kernel_pm.asm`)
- GDT com 4KB limit, expandível para 16KB com entry adicional
- A20 habilitado antes de qualquer acesso > 1 MB

### Próximos Passos (Milestone 2)
Implementar long mode x86-64 com paginação PML4

---

## Milestone 2: Long Mode x86-64 🔄 EM PROGRESSO

**Status**: Bootstrap e build concluídos em 2026-05-24; validação em QEMU pendente
**Estimado**: Conclusão para 2026-05-31

### Objetivos
- [x] Setup de paginação PML4 minima
  - [x] PML4, PDPT e PD inicializadas em runtime
  - [x] Identity mapping do primeiro 1 GiB com paginas de 2 MiB
  - [x] Allocator fisico bump para paginas de 4 KiB

- [x] IDT (Interrupt Descriptor Table)
  - [x] Setup IDT em 64-bit
  - [x] Handlers para exceções: #DE, #UD, #DF, #GPF, #PF
  - [ ] Stub handlers para IRQs (próximo: M3)

- [x] Transição protected-mode → long-mode
  - [x] Entrada real-mode em `kernel/longmode/kernel_lm.asm`
  - [x] Ativar PAE no CR4
  - [x] Carregar CR3 com PML4 address
  - [x] Ativar EFER.LME para long-mode
  - [x] Far jump para código 64-bit

- [x] Novo módulo: `kernel/longmode/kernel_lm.asm`
  - [x] Entry ponto 64-bit
  - [x] Serial console 64-bit
  - [x] Stack e registradores de modo longo

- [x] Pastas separadas para manutenção
  - [x] `kernel/longmode/` para bootstrap e transição 64-bit
  - [x] `kernel/paging/` para paginação e alocação de páginas
  - [x] `kernel/interrupt/` para IDT e exceções
  - [x] `kernel/drivers/` para drivers como serial COM1

### Pendente para M2 Final
- [ ] Validar paginacao com page fault
- [ ] Testar todos exception handlers
- [x] Manter `kernel_lm.bin` dentro de 4096 bytes

### Build Targets
```bash
make lm         # long-mode build (os_lm.img)
make lm-run     # execute long-mode
make lm-debug   # execute with serial stdio and GDB stub
```

### Dependências
- Milestone 1 (protected mode) ✅ já concluído
- CPUID para verificar suporte a long-mode

---

## Milestone 3: Interrupções e Timer ⏱️ PRÓXIMO

**Estimado**: 2-3 semanas (após M2)

### Objetivos
- [ ] Timer de sistema (PIT - 8254)
  - [ ] Configurar para frequência fixa (1000 Hz)
  - [ ] Handler de IRQ0

- [ ] Real context switching
  - [ ] Task state save/restore
  - [ ] Stack frame em interrupção
  - [ ] Implementar yield() syscall
  - [ ] Preemptive scheduling

- [ ] Tratamento de exceções x86-64
  - [ ] Divide-by-zero (#DE)
  - [ ] General protection (#GPF)
  - [ ] Page fault (#PF) com COW support

### Módulos Novos
- `kernel/timer.asm` - PIT configuration
- `kernel/exceptions.asm` - Exception handlers
- `kernel/context.asm` - Context switch primitives

---

## Milestone 4: Isolamento e IPC 👥 FUTURO

**Estimado**: 3 semanas (após M3)

### Objetivos
- [ ] Ring3 isolation
  - [ ] Task gates com DPL=3
  - [ ] TSS (Task State Segment)
  - [ ] Privilege level validation

- [ ] Syscall/Sysret x86-64
  - [ ] MSR setup para SYSCALL
  - [ ] Syscall handlers em kernel
  - [ ] Parameter passing conventions

- [ ] Task separation
  - [ ] Move FS server to ring3
  - [ ] Move Driver server to ring3
  - [ ] Isolated memory spaces per task

- [ ] Advanced IPC
  - [ ] Message validation
  - [ ] Capability tokens
  - [ ] Async notifications

### Módulos Novos
- `kernel/ring3.asm` - Ring3 isolation primitives
- `kernel/syscall.asm` - Syscall handling
- `kernel/task.asm` - Task state management

---

## Milestone 5: ELF Loader 📦 FUTURO

**Estimado**: 2 semanas (após M4)

### Objetivos
- [ ] Parser ELF minimo
  - [ ] Header validation
  - [ ] Program headers parsing
  - [ ] Section header support

- [ ] Dynamic loading
  - [ ] Load segments into memory
  - [ ] Relocation (símbolos básicos)
  - [ ] BSS zero initialization

- [ ] User programs
  - [ ] Simple "hello world" userspace binary
  - [ ] Statically linked programs
  - [ ] Libc stub

### Módulos Novos
- `kernel/elf.asm` - ELF parser
- `kernel/loader.asm` - Program loader
- `userspace/` - User program directory

---

## Milestone 6: Runtime C/Rust 🧩 FUTURO

**Estimado**: após M5, somente quando syscall, IPC e ELF estiverem estáveis

### Objetivos
- [ ] Definir headers de ABI para C
- [ ] Criar biblioteca minima `nexus-libc` ou `nexus-rt`
- [ ] Compilar primeiro programa userspace em C
- [ ] Avaliar Rust `no_std` para servidores isolados
- [ ] Definir panic strategy, linker script e contrato de alocação

### Direção
- Assembly permanece no caminho critico de CPU e interrupcoes.
- C entra primeiro para validar ABI e loader ELF com baixo atrito.
- Rust entra depois para servidores com estado mais complexo e isolamento.

---

## Subdivisões de Produto

| Produto | Entrega funcional |
| --- | --- |
| **NeXus Core** | Kernel x86-64, memoria, interrupcoes, scheduler e IPC. |
| **NeXus Boot** | Boot BIOS atual, futuro UEFI e validadores de imagem. |
| **NeXus Drivers** | Serial, VGA, PIT, teclado, disco e virtio. |
| **NeXus Services** | FS, driver manager, init e servicos em ring3. |
| **NeXus Runtime** | Syscalls, ABI IPC, loader ELF, libc/rt minima. |
| **NeXus SDK** | Ferramentas, exemplos, testes e documentacao de contratos. |

---

## Roadmap Visual (Gráfico de Gantt)

```
Jun 2026  |████████████████ Milestone 2 (Long Mode)
Jul 2026  |    ████████████ Milestone 3 (Interrupts)
Aug 2026  |          ██████████ Milestone 4 (Ring3 IPC)
Sep 2026  |               ████████ Milestone 5 (ELF)
Oct 2026  |                    ████ Milestone 6 (C/Rust Runtime)
```

---

## Métricas de Sucesso

### Por Milestone
- **M0**: Bootável, VGA output, 4.7 KB total ✅
- **M1**: 32-bit protected mode, GDT, A20 ✅
- **M2**: 64-bit long mode, paginação, IDT
- **M3**: Timer real, context switching, 100+ tasks
- **M4**: Ring3 execution, syscalls, capability IPC
- **M5**: ELF loading, userspace programs, isolation
- **M6**: Runtime C/Rust, primeiros programas userspace

### Gerais
- Tamanho binário: < 64 KB total (boot + kernel + tools)
- Build time: < 1 segundo
- Boot time: < 100 ms to kernel ready
- Code quality: Assembly no caminho critico; C/Rust apenas apos ABI estavel
- Documentation: Complete per milestone

---

## Dependências e Bloqueadores

| Dependência | Status | Bloqueador |
| --- | --- | --- |
| NASM 2.15+ | ✅ Instalado | Nenhum |
| QEMU x86-64 | ✅ Disponível | Nenhum |
| GDB | ✅ Instalado | Nenhum (M3: debug IRQs) |
| CPU com long-mode | ✅ Assumido | M2: CPUID check |
| CPU com PAE | ✅ Assumido | M2: CPUID check |

---

## Branches e Workflow

```
main
├── feature/milestone-2-longmode
├── feature/milestone-3-interrupts
├── feature/milestone-4-ring3
├── feature/milestone-5-elf
└── feature/milestone-6-runtime
```

**Convenção de Commits**
```
feat(module): description               # Nova feature
fix(module): description                # Bug fix
docs(area): description                 # Documentação
perf(module): description               # Otimização
refactor(module): description           # Refatoração
test(module): description               # Testes/validação
chore(build): description               # Build/CI changes
```

---

## Contato e Contribuições

- Autor: @ghostroot
- Linguagem atual: x86 Assembly (16/32/64-bit)
- Linguagens futuras: C e Rust `no_std` para runtime, servidores e userspace
- Licença: Verificar LICENSE
- Status: Active development (M2 long mode)

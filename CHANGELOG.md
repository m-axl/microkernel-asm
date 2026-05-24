# Changelog

Todas as mudanças notáveis neste projeto são documentadas neste arquivo.

## [0.2.0-m2] - 2026-05-24 (Em Desenvolvimento)

### Project
- Projeto renomeado de **Microkernel ASM** para **NeXus**
- Versão atual registrada em `VERSION`
- Documentação passa a separar produtos: Core, Boot, Drivers, Services, Runtime e SDK
- Roadmap inclui trilha futura C/Rust após estabilização de ABI, syscalls e ELF

### Added
- ✨ Bootstrap M2 bootável em `kernel/longmode/kernel_lm.asm`
- ✨ Paginação PML4 minima com identity mapping de 1 GiB
- ✨ IDT com exception handlers para #DE, #UD, #DF, #GPF, #PF
- ✨ Módulos separados: kernel/paging/, kernel/interrupt/, kernel/longmode/, kernel/drivers/
- ✨ Transição real-mode → protected-mode → long-mode com PAE + EFER.LME
- ✨ Serial I/O 64-bit em `kernel/drivers/serial.asm`
- ✨ Build targets: `make lm`, `make lm-run`, `make lm-debug`

### Technical Details
- Tabelas PML4/PDPT/PD ficam em memoria fixa e sao limpas em runtime
- Alocador fisico M2 usa bump allocation a partir de 2 MiB
- Exception handlers imprimem vetor, codigo de erro e CR2 para #PF
- Stack em 0x90000 para 64-bit mode
- `make check` recompila tambem o kernel M2 isoladamente

### Product Direction
- **NeXus Core** continua sendo a entrega principal em Assembly
- **NeXus Services** e **NeXus Runtime** serão os primeiros candidatos para C/Rust
- Assembly permanece obrigatório para boot, transições de CPU, IDT, syscalls e context switch

## [Planejado]

### Milestone 3: Interrupções e Timer
- [ ] PIT (Programmable Interval Timer) setup
- [ ] Implementar handlers de interrupção x86-64
- [ ] Setup timer de sistema (PIT ou APIC)
- [ ] Troca de contexto real com stack frames
- [ ] Preempção de tarefas com timer interrupt

### Milestone 4: Isolamento e IPC
- [ ] Separar servidores em tarefas de user-space
- [ ] Definir ABI completa de IPC
- [ ] Implementar syscalls com validação de privilégio

### Milestone 5: Loader ELF
- [ ] Parser ELF minimo
- [ ] Loader de programas de user-space
- [ ] Isolamento de ring3 com validação

### Milestone 6: Runtime C/Rust
- [ ] Headers de ABI para C
- [ ] Primeiro programa userspace em C
- [ ] Avaliação de Rust `no_std` para servidores

## [0.1.0-delta] - 2026-05-24 (Delta Demo)

### Added
- ✨ Transição clara de real mode para protected mode
- ✨ Ativação da A20 line no bootloader (fast method via port 0x92)
- ✨ Setup GDT com descritores de kernel code e data
- ✨ Novo módulo `kernel/pm_setup.asm` para setup de protected mode
- ✨ Novo módulo `kernel/kernel_pm.asm` como entrada protected mode
- ✨ Build target `make pm` para compilação protected mode
- ✨ Build target `make pm-run` e `make pm-debug` para execução PM
- 📚 Documentação BUILD.md com instruções completas

### Changed
- 📝 Atualizado `boot/boot.asm` para ativar A20 antes do salto para kernel
- 📝 Atualizado `include/kernel.inc` com constantes de protected mode
- 🔧 Makefile agora suporta compilação paralela real-mode e protected-mode
- 📝 Atualizado `docs/architecture.md` com status de Milestone 1

### Technical Details
- A20 habilitado via método rápido (Intel 8042 controller, porta 0x92)
- GDT com 3 descritores: null, kernel code (0x08), kernel data (0x10)
- Protected mode habilitado via bit CR0.PE
- Boot sector mantém compatibilidade com real-mode
- Suporte para builds paralelos mantém retrocompatibilidade

## [0.0.1-bios_v0.1] - 2026-05-20 (First Bootable Release)

### Added
- ✨ Boot sector BIOS completo com leitura de kernel do disco
- ✨ Kernel real-mode com serial console (COM1) e VGA text output
- ✨ Memory allocator linear simples
- ✨ Scheduler round-robin cooperativo
- ✨ IPC mailbox primitivo
- ✨ Server stubs (filesystem e driver)
- 📚 Documentação inicial de arquitetura
- 🧪 Script de quality checks

### Features
- Console visual tipo terminal em VGA text
- Output de diagnóstico em serial (debug)
- Estrutura modular separada por responsabilidade
- Tamanho otimizado (boot ~512B, kernel ~3KB)

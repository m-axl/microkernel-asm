# Changelog

Todas as mudanças notáveis neste projeto são documentadas neste arquivo.

## [Planejado]

### Milestone 2: Long Mode
- [ ] Ativar paginação PML4 minima
- [ ] Setup IDT para interrupções x86-64
- [ ] Transição de protected mode para long mode (64-bit)

### Milestone 3: Interrupções e Timer
- [ ] Implementar handlers de interrupção x86-64
- [ ] Setup timer de sistema (PIT ou APIC)
- [ ] Troca de contexto real com stack frames

### Milestone 4: Isolamento e IPC
- [ ] Separar servidores em tarefas de user-space
- [ ] Definir ABI completa de IPC
- [ ] Implementar syscalls com validação de privilégio

### Milestone 5: Loader ELF
- [ ] Parser ELF minimo
- [ ] Loader de programas de user-space
- [ ] Isolamento de ring3 com validação

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

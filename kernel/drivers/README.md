# Drivers - Módulo de Drivers de Hardware

## Responsabilidades

Este módulo gerencia drivers para dispositivos de hardware:

- **Serial (COM)**: Console de debug
- **VGA/Display**: Output visual (texto)
- **PIT (Timer)**: Timekeeping e preemption
- **Teclado**: Input de usuário
- **Disco (ATA)**: Leitura/escrita de dados
- **Rede (futuro)**: NIC drivers
- **USB (futuro)**: USB host controller

## Arquivos

- `serial.asm` - Serial port driver (COM1)
- `vga.asm` - VGA text mode output
- `pit.asm` - Programmable Interval Timer
- `keyboard.asm` - PS/2 keyboard input
- `disk.asm` - ATA disk driver
- `pci.asm` - PCI bus enumeration (futuro)
- `nic.asm` - Network interface controller (futuro)

## Drivers Implementados (v0.1)

### Serial Port (COM1 @ 0x3F8)
```
Baud: 115200
Data: 8 bits
Stop: 1 bit
Parity: None
Handshake: None
```

Funções:
```asm
call serial_init_64      ; Inicializar
call serial_putchar_64   ; Enviar 1 byte (al)
call serial_print_64     ; Enviar string (rsi)
```

### VGA Text (80x25)
```
Endereço: 0xB8000 (primeira página)
Cores: 16 (preto, azul, verde, ciano, vermelho, magenta, marrom, branco)
Atributos: FG (4 bits) + BG (3 bits) + Bright (1 bit)
```

Funções:
```asm
call vga_init            ; Limpar tela
call vga_putchar         ; Mostrar caractere
call vga_print           ; Mostrar string
call vga_clear_row       ; Limpar linha
```

### PIT (8254 @ 0x40-0x43)
```
Frequency: Programável
Mode: Square wave (3)
Counter: 16-bit
```

Funções:
```asm
call pit_init            ; Setup timer (1000 Hz)
call pit_wait_ms         ; Esperar N ms
call pit_set_frequency   ; Mudar frequência
```

### Keyboard (PS/2 @ 0x60-0x64)
```
Scancode: 8-bit (com make/break codes)
Rate: ~100 scancodes/sec
```

Funções:
```asm
call kbd_init            ; Inicializar
call kbd_getchar         ; Ler 1 caractere (blocking)
call kbd_enable_int      ; Habilitar interrupção (IRQ1)
```

### Disk (ATA PIO @ 0x1F0-0x1F7)
```
Setor: 512 bytes
Modo: PIO (Programmed I/O)
```

Funções:
```asm
call disk_read_sector    ; param: rax = setor, rdi = buffer
call disk_write_sector   ; param: rax = setor, rsi = buffer
```

## Limitações (v0.1)

- Serial: sem flow control
- VGA: apenas modo texto 80x25
- Teclado: sem layout de teclado
- Disco: apenas LBA28, setor único
- Sem PCI enumeration

## Próximas Funcionalidades

- PCI bus scanning para device discovery
- AHCI support (SATA moderno)
- Interrupt-driven I/O
- DMA support
- Network driver (RTL8139 ou virtio-net)
- USB 2.0 EHCI

## Ordem de Inicialização

```
1. Serial (COM1) - para debug
2. VGA - para UI
3. PIT - para timebase
4. Keyboard - para input
5. Disk - para storage (on-demand)
```

## Testing

```bash
make test-drivers       # Teste simples de cada driver
make test-interrupt     # Teste de IRQ
```

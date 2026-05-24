# 09 - Futuro C/Rust

Assembly continua sendo a linguagem certa para bring-up inicial. A entrada em
C ou Rust deve acontecer apenas quando o NeXus tiver contratos estaveis.

## O que permanece em Assembly

- boot;
- transicoes de modo;
- GDT;
- IDT;
- syscall entry;
- context switch;
- acesso direto a registradores sensiveis;
- rotinas onde layout binario precisa ser obvio.

## Trilha C

C deve entrar primeiro para validar ABI com baixo atrito.

Possiveis entregas:

- `nexus/abi.h`;
- wrappers de syscall;
- primeiro `hello` userspace;
- runtime minimo sem libc completa;
- testes de IPC.

Riscos:

- dependencia implicita de runtime externo;
- stack protector involuntario;
- chamadas a funcoes de libc inexistentes;
- linker script incompleto.

## Trilha Rust

Rust deve entrar depois, preferencialmente em `no_std`.

Possiveis entregas:

- servidores isolados;
- bibliotecas userspace;
- ferramentas de validacao;
- componentes com estado mais complexo.

Riscos:

- panic strategy;
- alocador global;
- layout de ABI;
- tamanho de binario;
- dependencias de target e linker.

## Criterios para iniciar

Antes de C/Rust, o projeto deve ter:

- syscalls minimas;
- IPC ABI documentada;
- loader ELF64;
- linker script conhecido;
- layout de processo;
- regra de memoria userspace;
- exemplo userspace em Assembly.

## Decisao recomendada

1. Primeiro userspace em Assembly.
2. Segundo userspace em C.
3. Servidor simples em C.
4. Servidor com estado em Rust `no_std`.
5. SDK com ferramentas em linguagem mais conveniente.

# Testes e qualidade

## Dependencias

- `nasm`
- `make`
- `qemu-system-x86_64` somente para execucao visual

## Comandos

Compilar a imagem:

```sh
make
```

Rodar verificacoes de build:

```sh
make check
```

Rodar qualidade estatica e validacao de documentacao:

```sh
make quality
```

Executar no QEMU:

```sh
make run
```

Modo debug com serial e GDB stub:

```sh
make debug
```

## O que o `make check` valida

- `boot.bin` tem exatamente 512 bytes;
- assinatura do boot sector esta em `55 aa`;
- `kernel.bin` cabe nos 8 setores carregados pelo bootloader;
- `os.img` possui o tamanho esperado;
- boot e kernel recompilam isoladamente com NASM.

## Limites atuais

O teste automatizado ainda nao executa QEMU porque o ambiente pode nao ter
`qemu-system-x86_64` instalado. Quando QEMU estiver disponivel, o proximo passo
de qualidade deve capturar a saida serial e validar o banner de boot.

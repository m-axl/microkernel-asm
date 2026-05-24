# 08 - Guia de Contribuicao

## Fluxo recomendado

1. Escolha um milestone.
2. Leia a pagina da wiki correspondente.
3. Mantenha o escopo pequeno.
4. Compile o alvo afetado.
5. Rode `make check`.
6. Atualize documentacao quando mudar contrato ou arquitetura.

## Padrao de commits

Use escopos pequenos:

```text
feat(boot): add disk loader guard
feat(architecture): establish NeXus milestone 2 structure
fix(paging): correct identity map flags
docs(wiki): document boot flow
build(make): validate long mode image
test(qemu): add serial smoke command
```

## Regras de arquitetura

- Nao misture M0, M1 e M2 sem motivo claro.
- Nao coloque drivers complexos dentro do Core se puderem virar Services.
- Nao introduza C/Rust antes de haver ABI, loader e linker claros.
- Nao aumente o kernel acima do limite carregado pelo bootloader.
- Nao remova retrocompatibilidade dos alvos `make`, `make pm` e `make lm`.

## Checklist antes de finalizar

- [ ] `make lm` passa.
- [ ] `make pm` passa se M1 foi afetado.
- [ ] `make check` passa.
- [ ] `make quality` passa quando o workspace estiver limpo de arquivos vazios.
- [ ] Docs foram atualizadas.
- [ ] O commit tem escopo coerente.

## Quando criar nova pagina de wiki

Crie uma pagina quando:

- o assunto tiver fluxo proprio;
- houver contrato publico;
- houver passos de debug repetiveis;
- a informacao for maior que uma secao pequena em outro arquivo.

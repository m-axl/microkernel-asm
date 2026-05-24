# Analise de erros - NeXus

Este documento registra o estado encontrado antes da retomada e as correcoes
aplicadas para criar uma base minima compilavel. O projeto agora usa o nome
NeXus; `microkernel-asm` permanece apenas como nome historico do repositorio.

## Erros encontrados

| Area | Problema | Correcao |
| --- | --- | --- |
| Build | Nao havia `Makefile` na raiz e `build.sh/makefile` estava vazio. | Criado `Makefile` com alvos `all`, `check`, `quality`, `run`, `debug` e `clean`. |
| Boot | `org 0x7c000` apontava para endereco incorreto do setor de boot. | Corrigido para `org 0x7C00`. |
| Boot | O carregamento de disco nao preservava o drive da BIOS nem tratava erro. | Bootloader agora salva `dl`, carrega setores do kernel e mostra erro via BIOS se `int 13h` falhar. |
| Kernel | Label `start;` nao definia uma entrada valida e chamadas usavam nomes inexistentes. | Criado `kernel_start` com inicializacao de segmentos, pilha e subsistemas. |
| Memoria | Implementacao usava contador de pagina, mas sem limite real. | Criado alocador simples com `MEMORY_BASE`, `MEMORY_LIMIT` e retorno zero em estouro. |
| Scheduler | Havia divergencia entre `current_task` e `current_tasks`. | Criada tabela estatica de tarefas e funcao `schedule_next`. |
| IPC | `inc_send` estava nomeado incorretamente para o subsistema. | Criado `ipc_send`, `ipc_receive` e `init_ipc`. |
| Servidores | Stubs chamavam labels inexistentes como `wait_message`, `process_request` e `fs_main`. | Criadas inicializacoes de servidor de arquivos e driver com estados rastreaveis. |
| Documentacao | README descrevia long mode e build que ainda nao existiam. | README e docs agora separam o marco atual dos proximos passos. |

## Decisao tecnica

O projeto passa a ter um marco inicial bootavel em modo real de 16 bits. Isso
nao e o objetivo final x86-64, mas e a base correta para evoluir com qualidade:

- imagem gerada de forma repetivel;
- boot sector validado;
- kernel carregado e executavel;
- interface visual inicial estilo Unix/DOS;
- testes estaticos antes de avancar para protected mode e long mode.

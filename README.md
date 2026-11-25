# Decodificador-UTF-8-em-Assembly
Um programa em Assembly NASM para Linux de 64 bits. O programa lê um arquivo de texto codificado em UTF-8 e produz outro arquivo com o código Unicode de cada caractere, escrito em hexadecimal.

## Como funciona

O programa não trata cada byte como um caractere. Em UTF-8, um caractere pode ocupar de 1 a 4 bytes, e o **primeiro byte** indica o tamanho da sequência.

Fluxo para cada caractere:

1. Lê 1 byte do arquivo de entrada.
2. Identifica o tamanho da sequência (1 a 4) pelos bits mais significativos.
3. Lê os bytes de continuação, se houver.
4. Remove os bits de controle e junta os bits de dados (máscaras `AND` e deslocamentos `SHL 6`) para reconstruir o code point.
5. Converte o valor para texto hexadecimal (`0x...`) com LF e NUL no final.
6. Grava a string no arquivo de saída, sem o NUL.
7. Repete até a leitura retornar 0 bytes, ou seja, até chegar no final do arquivo.

Exemplo de decodificação de `F0 9F 98 8E`:

```
F0 = 11110 000   -> 000
9F = 10 011111   -> 011111
98 = 10 011000   -> 011000
8E = 10 001110   -> 001110

000 011111 011000 001110 = 0x1F60E
```

---

## Requisitos

- Linux x86-64
- NASM
- `ld` (GNU binutils)
- `make`

---

## Como compilar

```bash
make
```

O executável é gerado em `Artifacts/programa` (a pasta `Artifacts/` é criada automaticamente).

Alvos disponíveis:

| Comando      | O que faz                                      |
|--------------|------------------------------------------------|
| `make`       | Monta e liga o programa                        |
| `make build` | Igual ao `make`                                |
| `make run`   | Compila (se necessário) e executa o programa   |
| `make clean` | Remove `Artifacts/main.o` e `Artifacts/programa` |

Sem o Makefile, os comandos equivalentes são:

```bash
mkdir -p Artifacts
nasm -f elf64 -g -F dwarf tarefa3-Grupo6.asm -o Artifacts/main.o
ld -o Artifacts/programa Artifacts/main.o
```

---

## Como usar

Depois de compilar:

```bash
./Artifacts/programa
```

ou

```bash
make run
```

O programa pede os dois nomes de arquivo:

```
Digite o nome do arquivo de entrada: testes/entradas/teste1_ascii.txt
Digite o nome do arquivo de saída: minha_saida.txt
```

- O arquivo de entrada é aberto para **leitura**.
- O arquivo de saída é **criado** se não existir e **sobrescrito** se já existir.
- Os nomes podem ser caminhos relativos ou absolutos, com até 255 caracteres.

Para conferir o resultado:

```bash
cat minha_saida.txt
```

### Mensagens de erro

| Situação                                              | Mensagem                                    |
|-------------------------------------------------------|---------------------------------------------|
| Arquivo de entrada inexistente ou sem permissão       | `Arquivo de entrada não encontrado!`        |
| Falha ao criar/abrir o arquivo de saída (ex.: pasta inexistente, sem permissão) | `Erro ao processar o arquivo de saida!` |

No erro de saída, o arquivo de entrada já aberto é fechado antes de encerrar.

---

## Testes

A pasta `Tests/` contém arquivos de entrada, as saídas esperadas.

```
Tests/
├── testeX_descrição.txt
├── testeX_esperado.txt
└── ...
```

### Rodando um teste manualmente

```bash
./Artifacts/programa
# entrada: testes/entradas/teste6_limites.txt
# saída:   minha_saida.txt

diff testes/saidas_esperadas/teste6_limites_saida.txt minha_saida.txt
```

Se o `diff` não imprimir nada, os arquivos são idênticos.

### Casos de teste

| Arquivo                  | O que testa                                                         |
|--------------------------|---------------------------------------------------------------------|
| `teste1_ascii`           | Letras, espaços, pontuação e quebra de linha                        |
| `teste2_multibyte`       | Caracteres de 2, 3 e 4 bytes                                        |
| `teste3_misto`           | Acentos, pontuação, símbolos e várias linhas                        |
| `teste4_vazio`           | Arquivo vazio (saída vazia, sem travar)                             |
| `teste5_sem_lf`          | `ABç` sem quebra de linha no final                                  |
| `teste6_caracteres_anormais`         | Caracteres limites de cada tamanho: U+7F, U+80, U+7FF, U+800, U+FFFF, U+10000, U+10FFFF |
| `teste7_quebras`         | Somente `\n\n\n\n\n\n` (seis `0xA`)                                 |
| `teste8_emojis`          | Diversos emojis diferentes                                          |
| `teste9_letras_internacionais`            | Caracteres japoneses, chineses e coreanos                      |
| `teste10_longo`          | 30 linhas misturando caracteres de 1, 2 e 3 bytes                   |

---

## Funções

Todos os parâmetros são passados **pela pilha**, cada um ocupando 8 bytes. O resultado, quando existe, volta em `RAX`. Dentro de cada função, o primeiro parâmetro empilhado por último fica em `[rsp + 8]`, o seguinte em `[rsp + 16]`.

### Funções obrigatórias

| Função | Descrição | Retorno (`RAX`) |
|--------|-----------|-----------------|
| `le_string(char* buffer, int tam_max)` | Lê uma linha da entrada padrão (`sys_read`), troca o LF por NUL | Quantidade de caracteres lidos (`-1` em erro) |
| `escreve_string(char* buffer)` | Escreve uma string terminada em NUL na saída padrão (`sys_write`) | — |
| `abre_arquivo(char* nome, int modo)` | Abre um arquivo (`sys_open`). Modo `0` = leitura, `577` = escrita + criação + truncamento. Permissões `438` (octal `0666`) | Descritor (negativo em erro) |
| `fecha_arquivo(int descritor)` | Fecha um arquivo (`sys_close`) | — |
| `le_byte_arquivo(int descritor, char* byte_arq)` | Lê 1 byte do arquivo (`sys_read`) | Bytes lidos (`0` = fim do arquivo) |
| `grava_string_arquivo(int descritor, char* buffer)` | Grava a string no arquivo, incluindo o LF e **sem** o NUL | — |
| `gera_string_hexadecimal(int valor, char* buffer)` | Converte para hexadecimal maiúsculo com prefixo `0x`, acrescenta LF e NUL | — |

### Funções auxiliares

| Função | Descrição |
|--------|-----------|
| `identificar_tamanho(char* byte_buffer)` | Olha os bits do primeiro byte e retorna `1`, `2`, `3` ou `4` (`-1` se inválido) |
| `le_todos_bytes(int qtd)` | Lê os bytes de continuação para `byte_buffer` |
| `decodificar(char* byte_buffer)` | Reconstrói o code point a partir dos bytes em `byte_buffer` |

### Registradores com papel fixo

| Registrador | Uso |
|-------------|-----|
| `r15` | Descritor do arquivo de entrada |
| `r14` | Descritor do arquivo de saída |
| `r12` | Quantidade de bytes do caractere atual (definido em `le_todos_bytes`, lido em `decodificar`) |

### Memória (`.bss`)

| Variável        | Tamanho   | Uso                                           |
|-----------------|-----------|-----------------------------------------------|
| `buffer_entrada`| 256 bytes | Nome do arquivo de entrada                    |
| `buffer_saida`  | 256 bytes | Nome do arquivo de saída                      |
| `byte_buffer`   | 4 bytes   | Bytes do caractere UTF-8 atual                |
| `string_buffer` | 16 bytes  | String hexadecimal pronta para gravar         |

---

## Estrutura do repositório

```
.
├── tarefa3-Grupo6.asm    # código-fonte
├── Makefile              # build
├── Artifacts/            # gerada pelo make (main.o e programa)
├── Tests/
│   ├── testeX_descrição.txt
│   ├── testeX_esperado.txt
│   └── ...
└── README.md
```

---

## Observações

- Assume que os arquivos de entrada contêm **UTF-8 válido**, como definido no enunciado. Bytes inválidos não são tratados.
- Não usa bibliotecas externas: toda a decodificação é feita com operações de bits.
- Funciona apenas em Linux x86-64, pois usa `syscall` diretamente.

---

## Integrantes

- Antônio Cezar de Castro Ramos
- Jefferson Junior Medeiros de Mesquita
- Rafael Yugo Caballero Tamaki
- Henrique de Assunção Ferreira
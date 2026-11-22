section .data                                                             ; variaveis inicializadas
  meu_arquivo db "teste_texto", 0                                         ; path do arquivo que queremos ler
  mensagem db "arquivo aberto, prosseguindo para o fechamento", 10, 0     ; mensagem de teste

section .bss                          ; variaveis não inicializadas
  buffer resb 100                     ; reserva 100 bytes para guardar a leitura
  byte_buffer resb  1                 ; reserva 1 byte

section .text                         ; programa em si
  global _start                       ; inicio do programa

abre_arquivo:

  ; - abre o arquivo -

  mov rax, 2                      ; instrução syscall open
  mov rdi, [rsp + 8]              ; arquivo
  mov rsi, [rsp + 16]             ; recebe o modo de abertura desejado
  mov rdx, 438                    ; muda a permissão do arquivo
  syscall                         ; coloca o descritor do arquivo no rax
  ret                             ; retorna para onde a função foi chamada

le_string:

  ; - lê o conteudo do arquivo -

  mov rax, 0                      ; instrução syscall read
  mov rdi, 0                      ; informações passadas em stdin pelo usuario
  mov rsi, [rsp + 8]              ; buffer de destino armazenado na stack
  mov rdx, [rsp + 16]             ; lê a quantidade de bytes armazenados na stack
  dec rdx                         ; remove 1 de rdx para ter onde colocar o NUL
  syscall                         ; coloca a quantidade de bytes lidos em rax

  cmp rax, 0                      ; testa se deu algum erro
  jle erro_leitura                ; se deu erro vai para erro_leitura

  cmp byte [rsi + rax - 1], 10    ; checa se o ultimo caractere é \n
  jne buffer_cheio                ; se o ultimo caractere não for \n pula para buffer_cheio
  mov byte [rsi + rax - 1], 0     ; substitui o último caractere pelo caractere nulo
  dec rax                         ; retira a quebra de linha da contagem de caracteres válidos
  ret

  erro_leitura:
    mov rax, -1                   ; coloca o valor -1 em rax para demonstrar um erro
    mov byte [rsi], 0             ; coloca o caractere nulo no buffer
    ret                           ; retorna para onde a função foi chamada

  buffer_cheio:
    mov byte [rsi + rax], 0       ; coloca NUl após os caracteres para simbolizar o fim da string
    ret                           ; retorna para onde a função foi chamada

escreve_string:

  ; - escreve a string passada na saida padrão -

  mov rdx, 0                      ; inicia o contador em 0
  mov rsi, [rsp + 8]              ; coloca o endereço da string em rsi

  while_inicio:
    cmp byte [rsi + rdx], 0       ; descobre o tamanho da string 
    je while_fim                  ; quando descobrir executa a escrita
    inc rdx                       ; aumenta o contador de bytes em 1
    jmp while_inicio              ; faz o loop do while

  while_fim:
    mov rax, 1                    ; instrução syscall write
    mov rdi, 1                    ; manda para stdout
    syscall                       ; finaliza o comando
    ret                           ; retorna para onde a função foi chamada

fecha_arquivo:

  ; - fecha o arquivo -

  mov rax, 3                      ; instrução syscall close
  mov rdi, [rsp + 8]              ; descritor do arquivo
  syscall                         ; executa o close
  ret                             ; retorna para onde a função foi chamada

; --------------------------------------------------------------------------

; Leitura dos bytes do arquivo e identificação de tamanho UTF-8

; --------------------------------------------------------------------------

identificar_tamanho:

  ; - Calcula quantos bytes cada caractere ocupa -

    mov rsi, [rsp + 8]  ; move para rsi o endereço do byte_buffer passado pelo _start

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 10000000b   ; verifica o bit mais significativos de dl
    cmp dl, 00000000b   ; se dl tiver o bit mais significativo 0, retorna 0
    jz tam1             ; se cmp retornou 0, vai para tam1

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 11100000b   ; verifica os 3 bits mais significativos de dl
    cmp dl, 11000000b   ; se dl tiver os 3 bits mais significativos 110, retorna 0
    jz tam2             ; se cmp retornou 0, vai para tam2

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 11110000b   ; verifica os 4 bits mais significativos de dl
    cmp dl, 11100000b   ; se dl tiver os 4 bits mais significativos 1110, retorna 0
    jz tam3             ; se cmp retornou 0, vai para tam3

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 11111000b   ; verifica os 5 bits mais significativos de dl
    cmp dl, 11110000b   ; se dl tiver os 5 bits mais significativos 11110, retorna 0
    jz tam4             ; se cmp retornou 0, vai para tam4

        mov rax, -1     ; coloca o valor -1 em rax para demonstrar um erro (nenhum dos tipos)
        ret             ; retorna para onde a função foi chamada

    tam1:
        mov rax, 1      ; coloca o valor 1 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

    tam2:
        mov rax, 2      ; coloca o valor 2 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

    tam3:
        mov rax, 3      ; coloca o valor 3 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

    tam4:
        mov rax, 4      ; coloca o valor 4 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

le_byte_arquivo:

  ; - Lê byte a byte dos caracteres do arquivo -

    mov rax, 0                  ; número da syscall para read
    mov rdi, [rsp + 8]          ; descritor de arquivo passado na stack
    mov rsi, [rsp + 16]         ; o que será lido irá para o buffer passado na stack
    mov rdx, 1                  ; indica que só 1 byte será lido
    syscall                     ; executa a chamada do sistema
    ret                         ; retorna para onde a função foi chamada

; --------------------------------------------------------------------------

; Zona de Testes

; --------------------------------------------------------------------------

  ; - programa de teste -

_start:
  push 100                        ; tam_max = 100
  push buffer                     ; coloca o endereço do buffer na stack
  call le_string                  ; chama a função de ler
  add rsp, 16                     ; limpa a stack

  push buffer                     ; coloca o endereço do buffer na stack
  call escreve_string             ; chama a função de escrever
  add rsp, 8                      ; limpa a stack

  ; ----------------------------

  push 577                        ; escrever e criar caso necessário
  push meu_arquivo                ; endereço do arquivo na stack
  call abre_arquivo               ; chama a função abrir o arquivo
  add rsp, 16                     ; limpa a stack

  mov r12, rax                    ; coloca o descritor do arquivo em r12

  push mensagem                   ; coloca o endereço do buffer na stack
  call escreve_string             ; chama a função de escrever
  add rsp, 8                      ; limpa a stack

  push r12                        ; coloca o descritor do arquivo na stack
  call fecha_arquivo              ; chama a função de fechar o arquivo
  add rsp, 8                      ; limpa a stack

  ; - encerra o programa -

fim: 
  mov rax, 60                     ; instrução syscall exit
  xor rdi, rdi                    ; codigo de saída 0
  syscall                         ; termina o programa
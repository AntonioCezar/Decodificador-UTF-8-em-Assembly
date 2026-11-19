section .data                         ; variaveis inicializadas
  meu_arquivo db "teste_texto", 0     ; path do arquivo que queremos ler

section .bss                          ; variaveis não inicializadas
  buffer resb 100                     ; reserva 100 bytes para guardar a leitura

section .text                         ; programa em si
  global _start                       ; inicio do programa

abre_arquivo:

  ; - Abre o arquivo - (falta especificar o modo de leitura e escrita)

  mov rax, 2                      ; instrução syscall open
  mov rdi, meu_arquivo            ; arquivo
  mov rsi, 0                      ; abre somente para leitura
  syscall                         ; retorna o rax
  cmp rax, 0                      ; verifica se houve erro
  jl fim                          ; se rax < 0 encerra o programa
  mov r12, rax                    ; guarda o descritor do arquivo

le_string:

  ; - Lê o conteudo do arquivo -

  mov rax, 0                      ; instrução syscall read
  mov rdi, 0                      ; informações passadas em stdin pelo usuario
  mov rsi, [rsp + 8]              ; buffer de destino armazenado na stack
  mov rdx, [rsp + 16]             ; lê a quantidade de bytes armazenados na stack
  dec rdx                         ; remove 1 de rdx para ter onde colocar o NUL
  syscall                         ; coloca a quantidade de bytes lidos em rax

  cmp rax, 0                      ; testa se deu algum erro
  jle erro_leitura                ; se deu erro vai para erro_leitura

  mov r13, rax                    ; move a quantidade de bytes lidos para r13
  cmp byte [rsi + r13 - 1], 10    ; checa se o ultimo caractere é \n
  jne buffer_cheio                ; se o ultimo caractere não for \n pula para buffer_cheio
  mov byte [rsi + r13 - 1], 0     ; substitui o último caractere
  lea rax, [r13 - 1]              ; guarda a quantidade de caracteres lidos em rax
  ret

  erro_leitura:
    mov rax, 0                    ; coloca o valor 0 em rax
    ret                           ; retorna para onde a função foi chamada

  buffer_cheio:
    mov byte [rsi + r13], 0       ; coloca NUl no byte 101
    ret                           ; retorna para onde a função foi chamada

escreve_string:

  ; - teste escrita do que foi lido -

  mov rax, 1                      ; instrução syscall write
  mov rdi, 1                      ; manda para stdout
  mov rsi, [rsp + 8]              ; pega os dados que foram guardados no buffer
  mov rdx, r13                    ; quantidade de bytes que vão ser escritos
  syscall                         ; finaliza o comando
  ret                             ; retorna para onde a função foi chamada

fechar:

  ; - fecha o arquivo -

  mov rax, 3                      ; instrução syscall close
  mov rdi, r12                    ; descritor do arquivo
  syscall                         ; executa o close

_start:
  push 101                        ; tam_max = 101, (1 a mais para armazenar o NUL)
  push buffer                     ; coloca o endereço do buffer na stack
  call le_string                  ; chama a função de ler
  add rsp, 16                     ; limpa a stack

  push buffer                     ; coloca o endereço do buffer na stack
  call escreve_string             ; chama a função de escrever
  add rsp, 8                      ; limpa a stack

  ; [j] - Encerra o programa
fim: 
  mov rax, 60                     ; instrução syscall exit
  xor rdi, rdi                    ; codigo de saída 0
  syscall                         ; termina o programa

global _start                         ; função inicio do programa

section .data                                                        ; variaveis inicializadas
  msg_entrada db "Digite o nome do arquivo de entrada: ", 0          ; mensagem de entrada
  msg_saida db "Digite o nome do arquivo de saída: ", 0              ; mensagem de saida
  msg_erro_entrada db "Arquivo de entrada não encontrado!", 10, 0    ; mensagem de erro de entrada
  msg_erro_saida db "Erro ao processar o arquivo de saída!", 10, 0   ; mensagem de erro de saida

section .bss                          ; variaveis não inicializadas
  buffer_entrada resb 256             ; reserva 256 bytes para guardar a leitura do arquivo de entrada
  buffer_saida resb 256               ; reserva 256 bytes para guardar a leitura do arquivo de saida
  byte_buffer resb  4                 ; reserva 4 bytes para guardar os bytes que irão fazer o code point
  string_buffer resb 16               ; reserva 16 bytes para guardar uma string hexadecimal singular

section .text                         ; programa em si

abre_arquivo:

  ; - abre o arquivo -

  mov rax, 2                      ; instrução syscall open
  mov rdi, [rsp + 8]              ; arquivo
  mov rsi, [rsp + 16]             ; recebe o modo de abertura desejado
  mov rdx, 438                    ; muda a permissão do arquivo
  syscall                         ; coloca o descritor do arquivo no rax
  ret                             ; retorna para onde a função foi chamada

le_string:

  ; - lê uma linha da entrada padrão -

  mov rax, 0                      ; instrução syscall read
  mov rdi, 0                      ; informações passadas em stdin pelo usuario
  mov rsi, [rsp + 8]              ; buffer de destino armazenado na stack
  mov rdx, [rsp + 16]             ; lê a quantidade de bytes armazenados na stack
  dec rdx                         ; remove 1 de rdx para ter onde colocar o NUL
  syscall                         ; coloca a quantidade de bytes lidos em rax

  cmp rax, 0                      ; testa se deu algum erro
  jle .erro_leitura               ; se deu erro vai para erro_leitura

  cmp byte [rsi + rax - 1], 10    ; checa se o ultimo caractere é \n
  jne .buffer_cheio               ; se o ultimo caractere não for \n pula para buffer_cheio
  mov byte [rsi + rax - 1], 0     ; substitui o último caractere pelo caractere nulo
  dec rax                         ; retira a quebra de linha da contagem de caracteres válidos
  ret                             ; retorna para onde a função foi chamada

  .erro_leitura:
    mov rax, -1                   ; coloca o valor -1 em rax para demonstrar um erro
    mov byte [rsi], 0             ; coloca o caractere nulo no buffer
    ret                           ; retorna para onde a função foi chamada

  .buffer_cheio:
    mov byte [rsi + rax], 0       ; coloca NUl após os caracteres para simbolizar o fim da string
    ret                           ; retorna para onde a função foi chamada

escreve_string:

  ; - escreve a string passada na saida padrão -

  mov rdx, 0                      ; inicia o contador em 0
  mov rsi, [rsp + 8]              ; coloca o endereço da string em rsi

  .while_inicio:
    cmp byte [rsi + rdx], 0       ; descobre o tamanho da string 
    je .while_fim                 ; quando descobrir executa a escrita
    inc rdx                       ; aumenta o contador de bytes em 1
    jmp .while_inicio             ; faz o loop do while

  .while_fim:
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
    jz .tam1            ; se cmp retornou 0, vai para tam1

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 11100000b   ; verifica os 3 bits mais significativos de dl
    cmp dl, 11000000b   ; se dl tiver os 3 bits mais significativos 110, retorna 0
    jz .tam2            ; se cmp retornou 0, vai para tam2

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 11110000b   ; verifica os 4 bits mais significativos de dl
    cmp dl, 11100000b   ; se dl tiver os 4 bits mais significativos 1110, retorna 0
    jz .tam3            ; se cmp retornou 0, vai para tam3

    mov dl, [rsi]       ; coloca o conteúdo de rsi em dl
    and dl, 11111000b   ; verifica os 5 bits mais significativos de dl
    cmp dl, 11110000b   ; se dl tiver os 5 bits mais significativos 11110, retorna 0
    jz .tam4            ; se cmp retornou 0, vai para tam4

        mov rax, -1     ; coloca o valor -1 em rax para demonstrar um erro (nenhum dos tipos)
        ret             ; retorna para onde a função foi chamada

    .tam1:
        mov rax, 1      ; coloca o valor 1 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

    .tam2:
        mov rax, 2      ; coloca o valor 2 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

    .tam3:
        mov rax, 3      ; coloca o valor 3 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

    .tam4:
        mov rax, 4      ; coloca o valor 4 em rax para demonstrar o numero de bytes
        ret             ; retorna para onde a função foi chamada

le_byte_arquivo:

  ; - Lê byte a byte dos caracteres do arquivo -

    mov rax, 0                    ; número da syscall para read
    mov rdi, [rsp + 8]            ; descritor de arquivo passado na stack
    mov rsi, [rsp + 16]           ; o que será lido irá para o buffer passado na stack
    mov rdx, 1                    ; indica que só 1 byte será lido
    syscall                       ; executa a chamada do sistema (coloca a quantidade de bytes lidos em rax)
    ret                           ; retorna para onde a função foi chamada

le_todos_bytes:

  ; - Lê a quantidade de bytes de acordo com o que identificar_tamanho retornou -

  mov r12, [rsp + 8]              ; coloca a quantidade de bytes a ler em r12
  mov r13, 1                      ; move o valor 1 para r13 (contador)

  .loop_inicio:
    cmp r13, r12                  ; compara para ver se pode terminar o loop
    je .loop_fim                  ; se r12 = r13 pula para .loop_fim
    lea rax, [byte_buffer + r13]  ; calcula onde colocar o byte novo
    push rax                      ; preenche byte a byte de byte_buffer
    push r15                      ; coloca o descritor do arquivo na stack
    call le_byte_arquivo          ; chama a função le_byte_arquivo
    add rsp, 16                   ; limpa a stack
    inc r13                       ; aumenta 1 no valor em r13
    jmp .loop_inicio              ; volta para o começo do loop

  .loop_fim:
    ret                           ; retorna para onde a função foi chamada


; --------------------------------------------------------------------------

; Decodificação dos caracteres em UTF-8 para hexadecimal

; --------------------------------------------------------------------------

  ; - decodifica os bytes do caractere que foi lido por ler_byte_arquivo -

decodificar:

    mov rsi, [rsp + 8]             ; recebe o buffer usado para guardar os bytes do caractere atual

	cmp r12, 1                     ; verifica se o caractere tem 1 byte
	jz .1byte                      ; se sim, pula para .1byte
	cmp r12, 2                     ; verifica se o caractere tem 2 byte
	jz .2bytes                     ; se sim, pula para .2bytes
	cmp r12, 3                     ; verifica se o caractere tem 3 byte
	jz .3bytes                     ; se sim, pula para .3bytes
	cmp r12, 4                     ; verifica se o caractere tem 4 byte
	jz .4bytes                     ; se sim, pula para .4bytes
	
  ; - se chegou aqui, não é 1, 2, 3 ou 4 (inválido) -

	mov rax, -1                    ; coloca rax como -1 para indicar erro
	ret                            ; retorna para onde a função foi chamada 

.1byte:

  ; - byte 1: ignora o primeiro bit e guarda os 7 restantes em RAX -

	movzx rax, byte [rsi]          ; zera rax e coloca o primeiro byte do buffer no lugar
	and rax, 01111111b             ; ignora primeiro bit
	ret                            ; retorna para onde a função foi chamada

.2bytes:

  ; - byte 1: ignora os 3 primeiros bits e guarda o restante -

	movzx rax, byte [rsi]          ; zera rax e coloca o primeiro byte do buffer no lugar
	and rax, 00011111b             ; ignora os 3 primeiros bits
	shl rax, 6                     ; move rax 6 bits para a esquerda

  ; - byte 2: ignora os 2 primeiros bits e guarda o restante -

	movzx rcx, byte [rsi + 1]      ; zera rax e coloca o segundo byte do buffer no lugar
	and rcx, 00111111b             ; ignora os 2 primeiros bits
	or rax, rcx                    ; junta as informações em rcx e rax
	ret                            ; retorna para onde a função foi chamada

.3bytes:

  ; - byte 1: ignora os 4 primeiros bits e guarda o restante -

	movzx rax, byte [rsi]          ; zera rax e coloca o primeiro byte do buffer no lugar
	and rax, 00001111b             ; ignora os 4 primeiros bits
	shl rax, 6                     ; move rax 6 bits para a esquerda

  ; - byte 2: ignora os 2 primeiros bits e guarda o restante -

	movzx rcx, byte [rsi + 1]      ; zera rax e coloca o segundo byte do buffer no lugar
	and rcx, 00111111b             ; ignora os 2 primeiros bits
	or rax, rcx                    ; junta as informações em rcx e rax 
	shl rax, 6                     ; move rax 6 bits para a esquerda

  ; - byte 3: ignora os 2 primeiros bits e guarda o restante -

	movzx rcx, byte [rsi + 2]      ; zera rax e coloca o terceiro byte do buffer no lugar
	and rcx, 00111111b             ; ignora os 2 primeiros bits
	or rax, rcx                    ; junta as informações em rcx e rax
	ret                            ; retorna para onde a função foi chamada 

.4bytes:

  ; - byte 1: ignora os 5 primeiros bits e guarda o restante -

	movzx rax, byte [rsi]          ; zera rax e coloca o primeiro byte do buffer no lugar
	and rax, 00000111b             ; ignora os 5 primeiros bits
	shl rax, 6                     ; move rax 6 bits para a esquerda

  ; - byte 2: ignora os 2 primeiros bits e guarda o restante -

	movzx rcx, byte [rsi + 1]      ; zera rax e coloca o segundo byte do buffer no lugar
	and rcx, 00111111b             ; ignora os 2 primeiros bits
	or rax, rcx                    ; junta as informações em rcx e rax 
	shl rax, 6                     ; move rax 6 bits para a esquerda

  ; - byte 3: ignora os 2 primeiros bits e guarda o restante -

	movzx rcx, byte [rsi + 2]      ; zera rax e coloca o terceiro byte do buffer no lugar
	and rcx, 00111111b             ; ignora os 2 primeiros bits
	or rax, rcx                    ; junta as informações em rcx e rax
    shl rax, 6                     ; move rax 6 bits para a esquerda

  ; - byte 4: ignora os 2 primeiros bits e guarda o restante -

	movzx rcx, byte [rsi + 3]      ; zera rax e coloca o quarto byte do buffer no lugar
	and rcx, 00111111b             ; ignora os 2 primeiros bits
	or rax, rcx                    ; junta as informações em rcx e rax
	ret                            ; retorna para onde a função foi chamada

; --------------------------------------------------------------------------

; Converte o codigo hexadecimal em texto padrão e manda para o arquivo saida

; --------------------------------------------------------------------------

gera_string_hexadecimal:

  ; - gera a string em forma hexadecimal com base no que decodificar retornou -

    mov rax, [rsp + 8]        ; valor a converter
    mov rdi, [rsp + 16]       ; endereço do buffer
    mov byte [rdi], '0'       ; coloca 0 como caractere inicial da string
    mov byte [rdi + 1], 'x'   ; coloca x como segunda caractere da string
    add rdi, 2                ; rdi aponta para a próxima posição livre do buffer
    mov rcx, 60               ; deslocamento começa pelo nibble mais alto (bits 60 a 63)
    xor rdx, rdx              ; flag: já foi escrito um digito dif de 0?

.laco:
    mov rsi, rax              ; preserva valor original do rax
    shr rsi, cl               ; traz o nibble desejado para os 4 bits mais baixos
    and rsi, 0xF              ; apaga todos os bits superiores e deixa só o nibble
    test rdx, rdx             ; verifica se rdx é 0
    jnz .emite                ; a flag já foi ativada, então escreve esse nibble
    test rsi, rsi             ; verifica se o nibble é 0
    jz .proximo               ; o nibble é um 0 à esquerda. Ignorar
    mov rdx, 1                ; o nibble é o primeiro dígito dif de 0. Liga a flag

.emite:
    cmp rsi, 10               ; o nibble é menor que 10?
    jb .digito                ; 0 a 9 viram "0"-"9" 
    add rsi, 'A' - 10         ; 10 a 15 viram A-F maiúsculos
    jmp .grava                ; grava no buffer

.digito:
    add rsi, '0'              ; transforma em texto

.grava:
    mov [rdi], sil            ; escrevemos o byte mais baixo de rsi na posição livre do buffer
    inc rdi                   ; avançamos para a próxima posição livre do buffer

.proximo:
    sub rcx, 4                ; avançar para o próximo nibble à direita
    jns .laco                 ; volta para o laço e gera o resto
    test rdx, rdx             ; verifica a flag
    jnz .fim                  ; escrevemos algum dígito. A string já está pronta
    mov byte [rdi], '0'       ; valor 0 -> "0x0"
    inc rdi                   ; avançamos para a próxima posição do buffer

.fim:
    mov byte [rdi], 10        ; LF
    mov byte [rdi + 1], 0     ; NUL
    ret                       ; retorna para onde a função foi chamada

grava_string_arquivo:

  ; - grava a string final no arquivo de saida -

    mov rdi, [rsp + 8]        ; descritor do arquivo
    mov rsi, [rsp + 16]       ; endereço da string
    xor rdx, rdx              ; zera o contador de caracteres

.conta:
    cmp byte [rsi + rdx], 0   ; o byte na posição rdx é o NUL?
    je .escreve               ; se for NUL, a string acabou. Vai escrever
    inc rdx                   ; senão conta mais um caractere
    jmp .conta                ; repete para o próximo byte

.escreve:
    mov rax, 1                ; número da syscall write
    syscall                   ; (obs.: os parametros já estao nos registradores certos) logo grava o LF mas não grava o NUL (rdx não conta o NUL)
    ret                       ; retorna para onde a função foi chamada

; --------------------------------------------------------------------------

; Operações centrais do programa

; --------------------------------------------------------------------------

erro_arquivo_entrada:

  ; - trata o erro de arquivo de entrada não encontrado -

  push msg_erro_entrada             ; coloca o endereço de msg_erro_entrada na stack
  call escreve_string               ; chama a função escreve_string
  add rsp, 8                        ; limpa a stack
  jmp fim                           ; finaliza o programa

erro_arquivo_saida:

  ; - trata o erro de arquivo de saida não encontrado -

  push msg_erro_saida               ; coloca o endereço de msg_erro_saida na stack
  call escreve_string               ; chama a função escreve_string
  add rsp, 8                        ; limpa a stack
  push r15                          ; coloca o descritor de entrada na stack
  call fecha_arquivo                ; chama a função fecha_arquivo
  add rsp, 8                        ; limpa a stack
  jmp fim                           ; finaliza o programa

_start:

  ; - programa central -

  push msg_entrada                  ; coloca o endereço de msg_entrada na stack
  call escreve_string               ; chama a função escreve_string
  add rsp, 8                        ; limpa a stack

  push 256                          ; tam_max = 256
  push buffer_entrada               ; coloca o endereço do buffer na stack
  call le_string                    ; chama a função le_string
  add rsp, 16                       ; limpa a stack

  push 0                            ; passa 0 como a instrução de ler para a stack
  push buffer_entrada               ; endereço do arquivo na stack
  call abre_arquivo                 ; chama a função abrir o arquivo
  add rsp, 16                       ; limpa a stack

  cmp rax, 0                        ; verifica se abre_arquivo conseguiu encontrar o arquivo
  jle erro_arquivo_entrada          ; caso não, exibe erro e finaliza o programa

  mov r15, rax                      ; move o descritor do arquivo de entrada para r15

  push msg_saida                    ; coloca o endereço de msg_saida na stack
  call escreve_string               ; chama a função escreve_string
  add rsp, 8                        ; limpa a stack

  push 256                          ; tam_max = 256
  push buffer_saida                 ; coloca o endereço do buffer na stack
  call le_string                    ; chama a função le_string
  add rsp, 16                       ; limpa a stack

  push 577                          ; passa a instruçao de escrever e criar caso necessário
  push buffer_saida                 ; endereço do arquivo na stack
  call abre_arquivo                 ; chama a função abrir o arquivo
  add rsp, 16                       ; limpa a stack

  cmp rax, 0                        ; verifica se abre_arquivo conseguiu encontrar o arquivo
  jle erro_arquivo_saida            ; caso não, exibe erro e finaliza o programa

  mov r14, rax                      ; move o descritor do arquivo de saida para r14

  .proximo_caractere:

  ; - loop principal para processar todos os caracteres do arquivo de entrada -

    push byte_buffer                ; coloca o endereço do byte_buffer na stack
    push r15                        ; coloca o descritor do arquivo de entrada na stack
    call le_byte_arquivo            ; chama a função le_byte_arquivo
    add rsp, 16                     ; limpa a stack

    cmp rax, 0                      ; verifica se leu algo
    jle .finalizacao                ; se não leu nada o arquivo acabou, pode finalizar

    push byte_buffer                ; coloca o endereço do byte_buffer na stack
    call identificar_tamanho        ; chama a função identificar_tamanho
    add rsp, 8                      ; limpa a stack

    push rax                        ; manda a quantidade de bytes do caractere para a stack
    call le_todos_bytes             ; chama a função le_todos_bytes
    add rsp, 8                      ; limpa a stack

    push byte_buffer                ; coloca o endereço do byte_buffer na stack
    call decodificar                ; chama a função decodificar
    add rsp, 8                      ; limpa a stack

    push string_buffer              ; manda o string_buffer para a stack
    push rax                        ; manda o code point para a stack
    call gera_string_hexadecimal    ; chama a função gera_string_hexadecimal
    add rsp, 16                     ; limpa a stack

    push string_buffer              ; coloca o endereço do string_buffer na stack
    push r14                        ; manda o descritor do arquivo de saida para a stack
    call grava_string_arquivo       ; chama a função grava_string_arquivo
    add rsp, 16                     ; limpa a stack

    jmp .proximo_caractere          ; volta para o loop

  .finalizacao:

  ; - fecha ambos arquivos de entrada e saida -

    push r15                        ; coloca o descritor de entrada na stack
    call fecha_arquivo              ; chama a função fechar_arquivo
    add rsp, 8                      ; limpa a stack

    push r14                        ; coloca o descritor de saida na stack
    call fecha_arquivo              ; chama a função fechar_arquivo
    add rsp, 8                      ; limpa a stack

fim:

  ; - encerra o programa -

  mov rax, 60                       ; instrução syscall exit
  xor rdi, rdi                      ; codigo de saída 0
  syscall                           ; termina o programa
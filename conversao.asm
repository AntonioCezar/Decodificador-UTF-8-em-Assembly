; gera_string_hexadecimal(int valor, char* buffer)
; [rsp+8] = valor, [rsp+16] = buffer
gera_string_hexadecimal:
    mov rax, [rsp+8]          ; valor a converter
    mov rdi, [rsp+16]         ; endereço do buffer
    mov byte [rdi], '0'
    mov byte [rdi+1], 'x'
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
    jmp .grava
.digito:
    add rsi, '0'              
.grava:
    mov [rdi], sil            ; escrevemos o byte mais baixo de rsi na posição livre do buffer
    inc rdi                   ; avançamos para a próxima posição livre do buffer
.proximo:
    sub rcx, 4                ; avançar para o próximo nibble à direita
    jns .laco                 
    test rdx, rdx             
    jnz .fim                  ; escrevemos algum dígito. A string já está pronta
    mov byte [rdi], '0'       ; valor 0 -> "0x0"
    inc rdi
.fim:
    mov byte [rdi], 10        ; LF
    mov byte [rdi+1], 0       ; NUL
    ret

; grava_string_arquivo(int fd, char* buffer)
; [rsp+8] = fd, [rsp+16] = buffer
grava_string_arquivo:
    mov rdi, [rsp+8]          ; descritor do arquivo
    mov rsi, [rsp+16]         ; endereço da string
    xor rdx, rdx              ; zera o contador de caracteres
.conta:
    cmp byte [rsi+rdx], 0     ; o byte na posição rdx é o NUL?
    je .escreve               ; se for NUL, a string acabou. Vai escrever
    inc rdx                   ; senão conta mais um caractere
    jmp .conta                ; repete para o próximo byte
.escreve:
    mov rax, 1                ; número da syscall write
    syscall                   ; (obs.: os parametros já estao nos registradores certos)
                              ; grava o LF mas não grava o NUL (rdx não conta o NUL)
    ret
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
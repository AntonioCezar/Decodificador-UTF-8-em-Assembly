global _start

selection .bss ;dados não inicializados
    buffer resb 100 ; reserva 100 bytes
    numero resq  1 ;reserva 1 qword (8 bytes)

selection .text

identificar_tamanho:

    cmp [rsi],00000000b ;se rsi tivesse só elementos 0 (vazio), retorna 0
    jz tam0             ;vai para tam0 se rsi for vazio

    mov bl, [rsi]       ; coloca o conteúdo de rsi em bl
    and bl, 10000000b   ;verifica o bit mais significativos de bl
    cmp bl, 00000000b   ;se bl tiver o bit mais significativo 0, retorna 0
    jz tam1             ;se cmp retornou 0, vai para tam1

    mov bl, [rsi]       ; coloca o conteúdo de rsi em bl
    and bl, 11100000b   ;verifica os 3 bits mais significativos de bl
    cmp bl, 11000000b   ;se bl tiver os 3 bits mais significativos 110, retorna 0
    jz tam2             ;se cmp retornou 0, vai para tam2


    mov bl, [rsi]       ; coloca o conteúdo de rsi em bl
    and bl, 11110000b   ;verifica os 4 bits mais significativos de bl
    cmp bl, 11100000b   ;se bl tiver os 4 bits mais significativos 1110, retorna 0
    jz tam3             ;se cmp retornou 0, vai para tam3


    mov bl, [rsi]       ; coloca o conteúdo de rsi em bl
    and bl, 11111000b   ;verifica os 5 bits mais significativos de bl
    cmp bl, 11110000b   ;se bl tiver os 5 bits mais significativos 11110, retorna 0
    jz tam4             ;se cmp retornou 0, vai para tam4

        mov r12, -1     ; coloca o valor -1 em r12 para demonstrar um erro, pois não foi identificado nenhum dos tipos
        ret             ;retorna para onde a função foi chamada

    tam0:
        mov r12, 0      ; coloca o valor 0 em r12 para demonstrar que não foi lido nada
        ret             ;retorna para onde a função foi chamada

    tam1:
        mov r12, 1      ; coloca o valor 1 em r12 para demonstrar o numero de bytes
        ret             ;retorna para onde a função foi chamada

    tam2:
        mov r12, 2      ;coloca o valor 2 em r12 para demonstrar o numero de bytes
        ret             ;retorna para onde a função foi chamada

    tam3:
        mov r12, 3      ;coloca o valor 3 em r12 para demonstrar o numero de bytes
        ret             ;retorna para onde a função foi chamada

    tam4:
        mov r12, 4      ;coloca o valor 4 em r12 para demonstrar o numero de bytes
        ret             ;retorna para onde a função foi chamada


le_byte_arquivo:
    mov rax, 0                  ;número da syscall para read
    mov rdi, [rsp + 8]          ;descritor de arquivo passado na stack
    mov rsi, [rsp + 16]         ;o que será lido irá para o buffer passado na stack
    mov rdx, 1                  ;indica que só 1 byte será lido
    syscall                     ;executa a chamada do sistema
        ret                     ;retorna para onde a função foi chamada




_start:




    mov rax, 60        ; numero de syscall para exit
    mov rdi, 0         ; código de saída: 0 (sucesso).
    syscall            ; chama o sistema operacional para encerrar o programa
section .text
	global decodificar 

decodificar:
	cmp r12, 1
	jz opcao1
	cmp r12, 2
	jz opcao2
	cmp r12, 3
	jz opcao3 
	cmp r12, 4
	jz opcao4
	
	;se chegou aqui, não é 1, 2, 3 nem 4
	xor rax, rax 
	ret

opcao1:
    ; byte 1 - ignora o primeiro bit e guarda os 7 restantes em RAX
	movzx rax, byte [rsi]
	and rax, 01111111b
	ret

opcao2:
    ; byte 1 - ignora os 3 primeiros bits e guarda o restante
	movzx rax, byte [rsi]
	and rax, 00011111b
	shl rax, 6

    ; byte 2 - ignora os 2 primeiros bits e guarda o restante
	movzx rcx, byte [rsi + 1]
	and rcx, 00111111b
	or rax, rcx 
	ret

opcao3:
    ; byte 1
	movzx rax, byte [rsi]
	and rax, 00001111b
	shl rax, 6

    ; byte 2
	movzx rcx, byte [rsi + 1]
	and rcx, 00111111b
	or rax, rcx 
	shl rax, 6

    ; byte 3
	movzx rcx, byte [rsi + 2]
	and rcx, 00111111b
	or rax, rcx
	ret 

opcao4:
    ; byte 1
	movzx rax, byte [rsi]
	and rax, 00000111b
	shl rax, 6

    ; byte 2
	movzx rcx, byte [rsi + 1]
	and rcx, 00111111b
	or rax, rcx 
	shl rax, 6

    ; byte 3
	movzx rcx, byte [rsi + 2]
	and rcx, 00111111b
	or rax, rcx

    ; byte 4
	movzx rcx, byte [rsi + 3]
	and rcx, 00111111b
	or rax, rcx
	ret

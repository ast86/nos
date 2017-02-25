org 0x7c00

bits 16

jmp start
string db 'We are borgs, you will be assimilated. Lower your shields!', 0

section .text
start:

	mov si, string
	call print_str
.loop_forever:
	jmp .loop_forever


; Takes argument in SI
;
;
print_str:
	mov bx, 0xff00
	cld
.loop:
	lodsb
	cmp al, 0
	je .exit
	mov ah, 0xE
	int 0x10
	jmp short .loop
.exit:
	ret

times 510-($-$$) db 1
dw 0xAA55

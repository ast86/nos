org 0x7c00

bits 16

jmp start
string db 'We are borgs, you will be assimilated. Lower your shields!', 0

section .text
start:

	mov si, string

	mov ax, 7c0h
	add ax, 544
	
	cli
	mov ss, ax
	mov sp, 4096
	sti

	; cx - column
	; dx - row

	; for cols
	; 	for rows
	;		do int10_C
.loop2:
	mov cx, 0 
		.loop3:
		mov dx, 0
			push dx
			push cx
			call int10_C
			pop cx
			pop dx
		inc dx
		cmp dx, 40
		jne .loop3

	inc cx
	cmp cx, 25
	jne .loop2
	
	;call int10_C
	
	mov ax, 0
	;call int10_2
.loop_forever:
	jmp .loop_forever

;set video mode
; input:
;	AL = desired video mode
;	00h 40x25 16 colors, 8 pages
;	03h 80x25 16 colors, 8 pages
;	13h 40x25 256 colors, 320x200 pixels, 8 pages
int10_0:
	mov al, 03h
	mov ah, 0
	int 10h
	
	ret
; set text-mode cursor shape
; input:
;	CH = cursor start line (0-4), options (5-7)
;	CL = bottom cursor line (0-4)
;	when bit 5 of CH is set to 0 - cursor is visible
;	mov ch, 32 <- curser is not visible (2^5) = 32 meaning bit 5 is set to 1

int10_1:
int10_1_hide_cursor:
; hide blinking text cursor:
	mov ch, 32
	mov ah, 1
	int 10h
	
	ret 

int10_1_std_blink_crsr:
; show standard blinking text cursor
	mov ch, 6
	mov cl, 7
	mov ah, 1
	int 10h

	ret

int10_1_box_shaped:
	mov ch, 0
	mov cl, 7
	mov ah, 1
	int 10h

	ret
; int 10h_2
; set cursor position
; input:
;	DH = row
;	DL = column
;	BH = page number
int10_2:
	mov dh, ah ; row
	mov dl, al ; column 
	mov bh, 0
	mov ah, 2
	int 10h
	
	ret
; change color for a single pixel
; input:
;	AL = pix color
;	CX = column
; 	DX = row
int10_C:
	push bp
	mov bp, sp
	pusha
	
	mov al, 13h
	mov ah, 0
	int 10h

	mov al, 1100b
;	mov cx,10
;	mov dx,20

	mov ah, 0ch
	int 10h
	
	popa
	pop bp
	mov sp, bp
	ret

; write a string to the console
; int 0x10 func 0xE
; input:
; 	AL = character to write 
; 
int10_Eh:
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

; write string
; input:
;	AL = write mode
;	  bit 0: update cursor after writing
;	  bit 1: string contains attributes
;	BH = page number
;	BL = attribute if string contains only chars (bit 1 of AL=0) 
;	CX = number of characters in string (attributes are not counted)
;	DL,DH = column, row at which to start writing
;	ES:BP = points to string to be printed 

int10_13h:
	mov al, 1 ; set bit 0 to 1 -> update cursor after writing
	mov bh, 0 ; select page number 0
	mov bl, 00110010b ; color attribute 
	

	;   3210 - dark/light = 1/0, R G B 
	; 0 0000 black
	; 1 0001 blue
	; 2 0010 green
	; 3 0011 cyan
	mov cx, msglend - msg1
	mov dl, 10 ; column
	mov dh, 7  ; row
	push cs
	pop es
	mov bp,  msg1
	mov ah, 13h
	int 10h
	jmp msglend
	msg1 db "hello world|"
	msglend:
	


times 510-($-$$) db 1
dw 0xAA55

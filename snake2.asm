IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
dir db 'a'
RandomValue dw 0
snakel dw 3
check db 0
snake dw 2000,2002,2004
dw 2000 dup(?)
; --------------------------
CODESEG
;========================================
proc delay
	push cx
;----------------------
	mov cx,0ffffh
lop1:
	push cx
	mov cx,10
lop2:
	loop lop2
	pop cx
	loop lop1
;----------------------
	pop cx
	ret
endp delay
;========================================
proc clear
	push bx
	push ax
;----------------------
	xor bx,bx
	mov ah,00
	mov al,' '
clear_loop:
	mov [es:bx],ax
	add bx,2
	cmp bx,4000
	jnz clear_loop
;----------------------
	pop ax
	pop bx
	ret
endp clear
;========================================
proc random
	push ax
	push es
;----------------------
	mov ax,40h
	mov es,ax
	mov ax,[es:6ch]
	and ax,111111111111b
	mov [RandomValue],ax
	mov ax,0b800h
	mov es,ax
	mov al,'*'
	mov ah,10
	mov bx,[RandomValue]
	mov [es:bx],ax
;----------------------
	pop es
	pop ax
	ret
endp random
;========================================
proc draw
	push ax
	push bx
	push di
	push cx
;----------------------
	mov cx,[snakel]
	mov bx,offset snake
	mov di,[bx+6]
	mov ah,0
	mov al,' '
	mov [es:di],ax
	mov ah,200
	mov al,'*'
draw_loop:
	mov di,[bx]
	add bx,2
	mov [es:di],ax
	loop draw_loop
;----------------------
	pop cx
	pop di
	pop bx
	pop ax
	ret
endp draw
;========================================
proc next
	push bp
	mov bp,sp

	push bx
	push di
	push cx
	push ax
;----------------------
	mov cx,[snakel]
	inc cx ;to have the last value to clear it later
	mov ax,[bp+4]
	mov di, offset snake
nlxt:
	mov bx,[di]
	mov [di],ax
	mov ax,bx
	add di,2
	loop nlxt
;----------------------
	pop ax
	pop cx
	pop di
	pop bx
	pop bp
	ret 2
endp next
;========================================
proc w
	push ax
	push bx
;----------------------
	mov ax,[snake]
	sub ax,(1*80)*2
	
	call w_check

	push ax
	call cheeck
	pop ax
	
	mov bl,[check]
	cmp bl,1
	jz ew
	
	push ax
	call next
	call draw
ew:
;----------------------
	pop bx
	pop ax
	ret
endp w
;========================================
proc s
	push ax
	push bx
;----------------------
	mov ax,[snake]
	add ax,(1*80)*2

	call s_check

	push ax
	call cheeck
	pop ax
	
	mov bl,[check]
	cmp bl,1
	jz ees
	
	push ax
	call next
	call draw
ees:
;----------------------
	pop bx
	pop ax
	ret
endp s
;========================================
proc a
	push ax
	push bx
;----------------------
	mov ax,[snake]
	sub ax,2

	call a_check
	
	push ax
	call cheeck
	pop ax
	
	mov bl,[check]
	cmp bl,1
	jz ea
	push ax
	call next
	call draw
ea:
;----------------------
	pop ax
	pop bx
	ret
endp a
;========================================
proc d
	push ax
	push bx
;----------------------
	mov ax,[snake]
	add ax,2

	call d_check

	push ax
	call cheeck
	pop ax
	
	mov bl,[check]
	cmp bl,1
	jz ed
	
	push ax
	call next
	call draw
ed:
;----------------------
	pop ax
	pop bx
	ret
endp d
;========================================
proc w_check
	push ax
;----------------------
	mov ax,[snake]
	cmp ax,160
	jnb ecw
	mov [check],1
ecw:
;----------------------
	pop ax
	ret
endp w_check
;========================================
proc s_check
	push ax
;----------------------
	mov ax,[snake]
	cmp ax,3840
	jna ecs
	mov [check],1
ecs:
;----------------------
	pop ax
	ret 
endp s_check
;========================================
proc a_check
	push bx
	push ax
	push dx
;----------------------	
	mov ax,[snake]
	xor dx,dx
	mov bx,160
	div bx
	cmp dx,0
	jnz eca
	mov [check],1
eca:
;----------------------
	pop dx
	pop ax
	pop bx
	ret
endp a_check
;========================================
proc d_check
	push ax
	push bx
	push dx
;----------------------	
	mov ax,[snake]
	xor dx,dx
	mov bx,160
	div bx
	cmp dx,158
	jnz ecd
	mov [check],1
ecd:
;----------------------	
	pop dx
	pop bx
	pop ax
	ret
endp d_check
;========================================
proc cheeck
push bp
mov bp,sp

	push ax
	push di
	push bx
	push dx
	
;----------------------
	mov ax,[bp+4]
	mov cx,[snakel]
	mov di,offset snake

check_loop:
	mov bx,[di]
	cmp ax,bx
	jnz ok_check
	mov [check],1
ok_check:
	add di,2
	loop check_loop

;----------------------
	pop dx
	pop bx
	pop di
	pop ax
	pop bp
	ret
endp cheeck
;--------------------------
start:
	mov ax, @data
	mov ds, ax
	mov ax,0b800h
	mov es,ax
call clear
call draw

lop:
	call delay

	mov al,[dir]
	mov ah,1
	int 16h
	jz noinput
	mov ah,0
	int 16h
noinput:
	mov [dir],al

	mov bl,[check]
	cmp bl,1
	jz exit

	cmp al,'w'
	jnz not_w
	call w
not_w:
	cmp al,'a'
	jnz not_a
	call a
not_a:
	cmp al,'s'
	jnz not_s
	call s
not_s:
	cmp al,'d'
	jnz not_d
	call d
not_d:
	cmp al,27
	jz exit
	jmp lop

	
exit:
	mov ax, 4c00h
	int 21h
END start



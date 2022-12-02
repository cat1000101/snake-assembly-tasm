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

;========================================
;clear the screan to black by placing in every cell of the screan a space charecter in the color black
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

;========================================
proc delay
;loop for to much times
	push cx
;----------------------
	mov cx,0ffffh
lop1:
	push cx
	mov cx,100
lop2:
	loop lop2
	pop cx
	loop lop1
;----------------------
	pop cx
	ret
endp delay
;========================================

;========================================
;checks if the next place the snake will be has a apple and if yes incroment the snake length
;[bp+4] - offset of the snake
;[bp+6] - offset of the snake length
;[bp+8] - offset of the random value
;doesnt returne anything
proc apple_check
	push bp
	mov bp,sp
	push cx
	push ax
	push si
;----------------------
	mov si,[bp+4]
;----------------------
	mov ax,[si]
;----------------------
	mov si,[bp+8]
;----------------------
	mov cx,[si]
	cmp ax,cx
	jnz no_apple
;----------------------
	mov si,[bp+6]
;----------------------
	mov cx,[si]
	inc cx
	mov [si],cx
;----------------------
	push [bp+8]
	call random
no_apple:
;----------------------
	pop si
	pop ax
	pop cx
	pop bp
	ret 6
endp apple_check
;========================================

;========================================
;generate a random number and places in that random number spot a apple
;[bp+4] - offset of the random value
;doesnt returne anything
proc random
	push bp
	mov bp,sp
	push ax
	push es
	push bx
	push dx
	push cx

	mov ax,40h
	mov es,ax
;----------------------
	mov ax,[es:6ch]
	mov cx,111000000000000b
	ror cx,12
	ror ax,cl
	push ax


	mov bx,[bp+4]
	mov dx,[bx]
	rol dx,cl
	and dx,1111000b
	ror dx,3
	mov cx,dx
	xor dx,dx
	mov ax,32h
	mul cx
	xor dx,ax
	mov cx,[bx]
	and cx,dx

	pop ax
	and ax,111111111111b
	xor ax,cx
;----------------------
	and ax,111111111110b
	mov bx,4000
	xor dx,dx
	div bx

;----------------------
	mov bx,[bp+4]
;----------------------
	mov [bx],dx

	mov ax,0b800h
	mov es,ax
	mov al,'*'
	mov ah,10
	mov bx,[bx]
	mov [es:bx],ax
;----------------------
	pop cx
	pop dx
	pop bx
	pop es
	pop ax
	pop bp
	ret 2
endp random
;========================================

;========================================
;erase the last place of the snake and after this draws the snake
;[bp+4] - offset of the snake itself
;[bp+6] - offset of the snake length
;doesnt returne anything
proc draw
	push bp
	mov bp,sp

	push ax
	push bx
	push di
	push cx
;----------------------
	mov bx,[bp+6]
	mov cx,[bx]
	mov bx,[bp+4]
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;clear the last star that is left behind
	add bx,cx
	add bx,cx
	mov di,[bx]
	mov ah,0
	mov al,' '
	mov [es:di],ax
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	mov bx,[bp+4]
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
	pop bp
	ret 4
endp draw
;========================================

;========================================
;mov all the snake one byte next and places the next place of  the snake at the head
;[bp+4] - the next place the snake will go to put it in the star of the snake
;[bp+6] - the offset of the snake length
;[bp+8] - the offset of the snake
;doesnt returne anything
proc next
	push bp
	mov bp,sp

	push bx
	push di
	push cx
	push ax
;----------------------
	mov bx,[bp+6]
;----------------------
	mov cx,[bx]
	inc cx ;to have the last value to clear it later
	mov ax,[bp+4]
	mov di, [bp+8]
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
	ret 6
endp next
;========================================

;========================================
;checks if the snake will hit the upper wall if you hit will change the check value to 1
;[bp+6] - offset of the check wich will check if you hit something
;[bp+4] - offset of the snake itself
;doesnt return anything
proc w_check
	push bp
	mov bp,sp
	push ax
	push di
	push si
;----------------------
	mov di,[bp+4]
	mov si,[bp+6]
;----------------------
	mov ax,[di]
	cmp ax,160
	jnb ecw
	mov [byte type si],1
ecw:
;----------------------
	pop si
	pop di
	pop ax
	pop bp
	ret 4
endp w_check
;========================================

;========================================
;checks if the snake will hit the lower wall if you hit will change the check value to 1
;[bp+6] - offset of the check wich will check if you hit something
;[bp+4] - offset of the snake itself
;doent return anything
proc s_check
	push bp
	mov bp,sp
	push ax
	push di
	push si
;----------------------
	mov di,[bp+4]
	mov si,[bp+6]
;----------------------
	mov ax,[di]
	cmp ax,3840
	jna ecs
	mov [byte type si],1
ecs:
;----------------------
	pop si
	pop di
	pop ax
	pop bp
	ret 4
endp s_check
;========================================

;========================================
;checks if the snake will hit the left wall if you hit will change the check value to 1
;[bp+6] - offset of the check wich will check if you hit something
;[bp+4] - offset of the snake itself
;doesnt return anything
proc a_check
	push bp
	mov bp,sp
	push bx
	push ax
	push dx
	push di
	push si
;----------------------	
	mov di,[bp+4]
	mov si,[bp+6]
;----------------------
	mov ax,[di]
	xor dx,dx
	mov bx,160
	div bx
	cmp dx,0
	jnz eca
	mov [byte type si],1
eca:
;----------------------
	pop si
	pop di
	pop dx
	pop ax
	pop bx
	pop bp
	ret 4
endp a_check
;========================================

;========================================
;checks if the snake will hit the right wall if you hit will change the check value to 1
;[bp+6] - offset of the check wich will check if you hit something
;[bp+4] - offset of the snake itself
;doesnt return anything
proc d_check
	push bp
	mov bp,sp
	push ax
	push bx
	push dx
	push di
	push si
;----------------------
	mov di,[bp+4]
	mov si,[bp+6]
;----------------------
	mov ax,[di]
	xor dx,dx
	mov bx,160
	div bx
	cmp dx,158
	jnz ecd
	mov [byte type si],1
ecd:
;----------------------
	pop si
	pop di
	pop dx
	pop bx
	pop ax
	pop bp
	ret 4
endp d_check
;========================================

;========================================
;checks if the snake hits itself if it hit itself it will change the check value to 1
;[bp+4] - the next place to check if it is intersepting the snake itself
;[bp+6] - offset of the snake length
;[bp+8] - offset of the check wich will check if you hit something
;[bp+10] - offset of the snake itself
;doent return anything
proc cheeck
push bp
mov bp,sp

	push ax
	push di
	push bx
	push dx
	push di
	push si
;----------------------
	mov di,[bp+6]
	mov si,[bp+8]
;----------------------
	mov ax,[bp+4]
	mov cx,[di]
	mov di,[bp+10]
	
check_loop:
	mov bx,[di]
	cmp ax,bx
	jnz ok_check
	mov [byte type si],1
ok_check:
	add di,2
	loop check_loop
	
;----------------------
	pop si
	pop di
	pop dx
	pop bx
	pop di
	pop ax
	pop bp
	ret 8
endp cheeck
;========================================

;========================================
proc w
;[bp+4] - offset of the place wich stores the random vlue
;[bp+6] - offset of the snake length
;[bp+8] - offset of the check wich will check if you hit something
;[bp+10] - offset of the snake itself
	push bp
	mov bp,sp
	push ax
	push bx
	push di
;----------------------
	mov di,[bp+10]
;----------------------
	mov ax,[di]
	sub ax,(1*80)*2
	mov bx,[di + 2]
	cmp ax,bx
	jne w_looking_s
	add ax,(2*80)*2
w_looking_s:
;----------------------
	push [bp+8]
	push [bp+10]
	call w_check
;----------------------
	push [bp+10]
	push [bp+8]
	push [bp+6]
	push ax
	call cheeck
;----------------------
	mov di,[bp+8]
	mov bl,[di]
	cmp bl,1
	jz ew
;----------------------
	push [bp+10]
	push [bp+6]
	push ax
	call next
;----------------------
	push [bp+6]
	push [bp+10]
	call draw
;----------------------
	push [bp+4]
	push [bp+6]
	push [bp+10]
	call apple_check
ew:
;----------------------
	pop di
	pop bx
	pop ax
	pop bp
	ret 8
endp w
;========================================

;========================================
proc s
;[bp+4] - offset of the place wich stores the random vlue
;[bp+6] - offset of the snake length
;[bp+8] - offset of the check wich will check if you hit something
;[bp+10] - offset of the snake itself
	push bp
	mov bp,sp
	push ax
	push bx
	push di
;----------------------
	mov di,[bp+10]
;----------------------
	mov ax,[di]
	add ax,(1*80)*2
	mov bx,[di + 2]
	cmp ax,bx
	jne s_looking_w
	sub ax,(2*80)*2
s_looking_w:
;----------------------
	push [bp+8]
	push [bp+10]
	call s_check
;----------------------
	push [bp+10]
	push [bp+8]
	push [bp+6]
	push ax
	call cheeck
;----------------------
	mov di,[bp+8]
	mov bl,[di]
	cmp bl,1
	jz ees
;----------------------
	push [bp+10]
	push [bp+6]
	push ax
	call next
;----------------------
	push [bp+6]
	push [bp+10]
	call draw
;----------------------
	push [bp+4]
	push [bp+6]
	push [bp+10]
	call apple_check
ees:
;----------------------
	pop di
	pop bx
	pop ax
	pop bp
	ret 8
endp s
;========================================

;========================================
proc a
	;[bp+4] - offset of the place wich stores the random vlue
	;[bp+6] - offset of the snake length
	;[bp+8] - offset of the check wich will check if you hit something
	;[bp+10] - offset of the snake itself
	push bp
	mov bp,sp
	push ax
	push bx
	push di
	;----------------------
	mov di,[bp+10]
	;----------------------
	mov ax,[di]
	sub ax,2
	mov bx,[di + 2]
	cmp ax,bx
	jne a_looking_d
	add ax,4
	a_looking_d:
	;----------------------
	push [bp+8]
	push [bp+10]
	call a_check
	;----------------------
	push [bp+10]
	push [bp+8]
	push [bp+6]
	push ax
	call cheeck
	;----------------------
	mov di,[bp+8]
	mov bl,[di]
	cmp bl,1
	jz ea
	;----------------------
	push [bp+10]
	push [bp+6]
	push ax
	call next
	;----------------------
	push [bp+6]
	push [bp+10]
	call draw
	;----------------------
	push [bp+4]
	push [bp+6]
	push [bp+10]
	call apple_check
	ea:
	;----------------------
	pop di
	pop ax
	pop bx
	pop bp
	ret 8
endp a
;========================================

;========================================
proc d
	;[bp+4] - offset of the place wich stores the random vlue
	;[bp+6] - offset of the snake length
	;[bp+8] - offset of the check wich will check if you hit something
	;[bp+10] - offset of the snake itself
	push bp
	mov bp,sp
	push ax
	push bx
	push di
	;----------------------
	mov di,[bp+10]
	;----------------------
	mov ax,[di]
	add ax,2
	mov bx,[di + 2]
	cmp ax,bx
	jne d_looking_a
	sub ax,4
	d_looking_a:
	;----------------------
	push [bp+8]
	push [bp+10]
	call d_check
	;----------------------
	push [bp+10]
	push [bp+8]
	push [bp+6]
	push ax
	call cheeck
	;----------------------
	mov di,[bp+8]
	mov bl,[di]
	cmp bl,1
	jz ed
	;----------------------
	push [bp+10]
	push [bp+6]
	push ax
	call next
	;----------------------
	push [bp+6]
	push [bp+10]
	call draw
	;----------------------
	push [bp+4]
	push [bp+6]
	push [bp+10]
	call apple_check
	ed:
	;----------------------
	pop di
	pop ax
	pop bx
	pop bp
	ret 8
endp d
;========================================

;========================================
;--------------------------
start:
	mov ax, @data
	mov ds, ax
	mov ax,0b800h
	mov es,ax
;--------------------------
;start things like clearing the screan and puting the first apple and drawing the snake
call clear
;----------------------
	push offset snakel
	push offset snake
;----------------------
call draw
;----------------------
	push offset RandomValue
;----------------------
call random
;--------------------------
;main loop
lop:
	call delay ;delay between every frame
;--------------------------
;getting input or if no input gets the input from the last frame
	mov al,[dir]
	mov ah,1
	int 16h
	jz noinput
	mov ah,0
	int 16h
	mov [dir],al
;--------------------------
noinput:

	mov bl,[check]
	cmp bl,1 ;checks if the snake hit a wall of somthing like that and will spot the program
	jz exit
;--------------------------
;calls to the proc of the coresponding direction
	push offset snake
	push offset check
	push offset snakel
	push offset randomvalue

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
;--------------------------
	
exit:
	mov ax, 4c00h
	int 21h
END start



.model small 
.stack 100h 
.data 

myField db 100 dup('0')
AIField db 100 dup('0')
x db ?
y db ?
siize dw ?
siize1 dw 3
flag dw 0
flagX dw ?
flagY dw ?
num db ?
gameOver db ?
killed_message db "the ship is killed"
coords_message db "enter coordinates:"
myMove_message db "it's your move!"
AIMove_message db "it's computer's move!"
gameOver_message db "GAME OVER"
youWon_message db "you won!"
AIWon_message db "computer won!"
killedFlag db ?

.code 
.386
start:  mov ax, @data 
	mov es, ax 
	mov ds, ax

	mov ax, 0003h
        int 10h
	
	call showMyField
	call showAIField

	call setShips
	call setAIShips

	mov siize, 3
play:
	mov killedFlag, 0
	call playerMove
	
	call checkGameAI
	cmp gameOver, 1
	je youWon
	cmp killedFlag, 1
	je play
play1:	
	mov killedFlag, 0
	call AIMove
	
	call checkGame
	cmp gameOver, 1
	je AIWon
	cmp killedFlag, 1
	je play1
	jmp play

youWon:
	mov ax, 03
    	int 10h

	mov bp, offset youWon_message
	mov cx, 8
	mov ah, 13h
	mov al, 0
	mov bl, 00011111b
	mov dh, 8
	mov dl, 20
	int 10h
	jmp exit

AIWon:
	mov ax, 03
    	int 10h

	mov bp, offset AIWon_message
	mov cx, 13
	mov ah, 13h
	mov al, 0
	mov bl, 00011111b
	mov dh, 8
	mov dl, 20
	int 10h
	jmp exit

exit:
	mov bp, offset gameOver_message
	mov cx, 9
	mov ah, 13h
	mov al, 0
	mov bl, 00011111b
	mov dh, 6
	mov dl, 20
	int 10h

	call sleep

	mov ax, 03
    	int 10h

	mov ax, 4C00h
	int 21h

output proc
	push ax
	push bx
	push dx
	
	mov ah, 13h
	mov al, 0
	mov bl, 00011111b
	mov dh, 5
	mov dl, 53
	int 10h
	
	pop dx
	pop bx
	pop ax
	ret
endp output

output1 proc
	push ax
	push bx
	push dx
	
	mov ah, 13h
	mov al, 0
	mov bl, 00011111b
	mov dh, 14
	mov dl, 0
	int 10h
	
	pop dx
	pop bx
	pop ax
	ret
endp output1

output2 proc
	push ax
	push bx
	push dx
	
	mov ah, 13h
	mov al, 0
	mov bl, 00011111b
	mov dh, 11
	mov dl, 0
	int 10h
	
	pop dx
	pop bx
	pop ax
	ret
endp output2

playerMove proc
	push ax
	push bx
	push cx
	push dx

	mov ax, 03
    	int 10h

	call showMyField
	call showAIField

	mov cx, 15
	mov bp, offset myMove_message
	call output2
lop1:
	call getCoords

	xor ax, ax
	mov al, x
	mov bl, 10
	mul bl
	add al, y

	mov di, offset AIField
	add di, ax

	mov bl, 'x'
	cmp [di], bl
	je lop1

	mov bl, '.'
	cmp [di], bl
	je lop1

	mov bl, '1'
	cmp [di], bl
	je ranen
	
	mov bl, '.'
	mov [di], bl
	call showAIField
	jmp endd

ranen:
	mov killedFlag, 1
	mov bl, 'x'
	mov [di], bl
	call showAIField
	mov flag, 0
	call checkAI
	cmp flag, 1
	je endd

	mov bp, offset killed_message
	mov cx, 18
	call output
	call sleep 
		
endd:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp playerMove

sleep proc 
	push ax
  	push bx
  	push dx

	mov ax, 00h
	int 1Ah

   	mov bx, dx ; запоминаем начальное значение тиков в bx
delay:
    	mov ax, 00h
	int 1Ah
    	sub dx, bx ; отнимаем от изначального значения тиков текущее
    	cmp dl, 30 ; сравниваем младший бит после вычитания с нунжной задержкой                                                 
   	jl delay; если нужное значение еще не достигнуто, повторяем 
   
  	pop dx
  	pop bx 
	pop ax
  	ret 
sleep endp

AIMove proc
	push ax
	push bx

	mov ax, 03
    	int 10h

	call showMyField
	call showAIField

	mov cx, 21
	mov bp, offset AIMove_message
	call output2

	call sleep

lop:
	call getAICoords
	
	xor ax, ax
	mov al, x
	mov bl, 10
	mul bl
	add al, y

	mov di, offset myField
	add di, ax

	mov bl, 'x'
	cmp [di], bl
	je lop

	mov bl, '.'
	cmp [di], bl
	je lop

	mov bl, '1'
	cmp [di], bl
	je ranen1
	
	mov bl, '.'
	mov [di], bl
	call showMyField
	jmp endd1

ranen1:
	mov killedFlag, 1
	mov bl, 'x'
	mov [di], bl
	call showMYField
	mov flag, 0
	call check
	cmp flag, 1
	je endd1

	mov bp, offset killed_message
	mov cx, 18
	call output
	call sleep

endd1:
	pop bx
	pop ax
	ret
endp AIMove

checkGame proc
	push ax
	push si
	push di

	mov si, 10
	mov di, offset myField
	mov gameOver, 1

l11:
	push si
	mov si, 10

l21:
	mov al, '1'
	cmp [di], al
	je notGameOver1
goBack1:
	inc di
	
	dec si
	jnz l21

	pop si
	dec si
	jnz l11

	pop di
	pop si
	pop ax
	ret
notGameOver1:
	mov gameOver, 0
	jmp goBack1
endp checkGame

checkGameAI proc
	push ax
	push si
	push di

	mov si, 10
	mov di, offset AIField
	mov gameOver, 1

l1:
	push si
	mov si, 10

l2:
	mov al, '1'
	cmp [di], al
	je notGameOver
goBack:
	inc di
	
	dec si
	jnz l2

	pop si
	dec si
	jnz l1

	pop di
	pop si
	pop ax
	ret
notGameOver:
	mov gameOver, 0
	jmp goBack
endp checkGameAI

showMyField proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov si, 10
	mov di, offset myField

	mov ah, 02
	mov dl, 0
	mov dh, 0
	int 10h

loopaa:
	push si
	mov si, 10

loopbb:
	mov al, [di]
	mov ah, 09
	mov cx, 1
	mov bl, 00011111b
	int 10h
	inc di

	mov ah, 02
	inc dl
	int 10h

	mov ah, 09
	mov al, 32
	int 10h

	mov ah, 02
	inc dl
	int 10h	
	
	dec si
	jnz loopbb

	pop si

	mov ah, 02
	mov dl, 0
	inc dh
	int 10h

	dec si
	jnz loopaa

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret
endp showMyField

showAIField proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov si, 10
	mov di, offset AIField
	
	mov ah, 02
	mov dl, 30
	mov dh, 0
	int 10h

loopa:
	push si
	mov si, 10

loopb:
	mov bl, '1'
	cmp [di], bl
	je printZero
	mov al, [di]
comeBackk:
	mov ah, 09
	mov cx, 1
	mov bl, 00011111b
	int 10h
	inc di

	mov ah, 02
	inc dl
	int 10h

	mov ah, 09
	mov al, 32
	int 10h

	mov ah, 02
	inc dl
	int 10h	
	
	dec si
	jnz loopb

	pop si

	mov ah, 02
	mov dl, 30
	inc dh
	int 10h

	dec si
	jnz loopa

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	ret
printZero:
	mov al, '0'
	jmp comeBackk
endp showAIField

setAIShips proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di	

	mov si, 3
	mov siize, 4

loop12:
	mov flag, 0
	call getAICoords
	call check2
	cmp flag, 1
	je loop12
	call checkAI
	cmp flag, 1
	je loop12

	call setTwoAI
	call showAIField

	dec si
	jnz loop12

	mov si, 2
	mov siize, 5

loop13:
	mov flag, 0
	call getAICoords
	call check2
	cmp flag, 1
	je loop13
	call checkAI
	cmp flag, 1
	je loop13

	call setThreeAI
	call showAIField

	dec si
	jnz loop13

	mov siize, 6

loop14:
	mov flag, 0
	call getAICoords
	call check2
	cmp flag, 1
	je loop14
	call checkAI
	cmp flag, 1
	je loop14

	call setFourAI
	call showAIField

	mov si, 4
	mov siize, 3

loop11:
	mov flag, 0
	call getAICoords
	call checkAI
	cmp flag, 1
	je loop11

	call setOneAI
	call showAIField

	dec si
	jnz loop11

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp setAIShips

setShips proc
	push ax
	push bx
	push cx
	push dx
	push si
	push di	

	mov si, 4
	mov siize, 3

loop1:
	mov flag, 0
	call getCoords
	call check
	cmp flag, 1
	je loop1

	call setOne
	call showMyField

	dec si
	jnz loop1

	mov si, 3
	mov siize, 4

loop2:
	mov flag, 0
	call getCoords
	call check2
	cmp flag, 1
	je loop2
	call check
	cmp flag, 1
	je loop2

	call setTwo
	call showMyField

	dec si
	jnz loop2

	mov si, 2
	mov siize, 5

loop3:
	mov flag, 0
	call getCoords
	call check2
	cmp flag, 1
	je loop3
	call check
	cmp flag, 1
	je loop3

	call setThree
	call showMyField

	dec si
	jnz loop3

	mov siize, 6

loop4:
	mov flag, 0
	call getCoords
	call check2
	cmp flag, 1
	je loop4
	call check
	cmp flag, 1
	je loop4

	call setFour
	call showMyField

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp setShips

getCoords proc
	push ax
	push bx
	push cx
	push dx
	push si

	mov ah, 02
	mov dh, 12
	mov dl, 0
	int 10h

	mov cx, 18
	mov bp, offset coords_message
	call output1
again:
	mov ah, 02
	mov dh, 14
	mov dl, 20
	int 10h

	mov ah, 0
	int 16h

	mov ah, 09
	mov cx, 1
	mov bl, 00011111b
	int 10h

	cmp al, '0'
	jl again
	cmp al, '9'
	jg again

	sub al, '0'
	mov x, al
again1:
	mov ah, 02
	mov dl, 21
	int 10h

	mov ah, 0
	int 16h

	mov ah, 09
	mov cx, 1
	mov bl, 00011111b
	int 10h

	cmp al, '0'
	jl again1
	cmp al, '9'
	jg again1

	sub al, '0'
	mov y, al

	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp getCoords

getAICoords proc
	push ax
	push dx
	
	call randomNumber
	mov al, num
	mov x, al

	call randomNumber1
	mov al, num
	mov y, al
	
	pop dx
	pop ax
	ret
endp getAICoords

check proc
	push ax
	push bx
	push dx
	push si
	push di

	mov dx, 12
	sub dx, siize

	xor ax, ax
	xor bx, bx	

	mov flagX, 0
	mov flagY, 0

	cmp x, 0
	je xZero

	cmp x, dl
	je xNine
back:
	cmp y, 0
	je yZero

	cmp y, 9
	je yNine

	cmp flagX, 1
	je setY

	mov al, x
	sub al, 1
	mov bl, 10
	mul bl
	mov si, siize

setY:
	add al, y
	sub al, 1
	mov siize1, 3
outer:
	push si

	mov si, siize1
	mov di, offset myField
	add di, ax
inner:
	xor bx, bx
	mov bl, '1'
	cmp [di], bl
	je setFlag

comeBack:
	inc di
	dec si
	jnz inner

	add al, 10
	pop si
	dec si
	jnz outer

	pop di
	pop si
	pop dx
	pop bx
	pop ax
	ret

setFlag:
	mov flag, 1
	jmp comeBack

xZero:
	mov flagX, 1

	mov al, x
	mov bl, 10
	mul bl

	mov si, siize
	dec si
	jmp back

xNine:
	mov flagX, 1

	mov al, x
	sub al, 1
	mov bl, 10
	mul bl

	mov si, siize
	dec si
	jmp back

yZero:
	mov siize1, 2
	mov flagY, 1

	cmp flagX, 1
	je setY1
	mov al, x
	sub al, 1
	mov bl, 10
	mul bl
	mov si, siize

setY1:
	add al, y
	jmp outer

yNine:
	mov siize1, 2
	mov flagY, 1

	cmp flagX, 1
	je setY2
	mov al, x
	sub al, 1
	mov bl, 10
	mul bl
	mov si, siize

setY2:
	add al, y
	sub al, 1
	jmp outer
endp check

checkAI proc
	push ax
	push bx
	push dx
	push si
	push di

	mov dx, 12
	sub dx, siize

	xor ax, ax
	xor bx, bx	

	mov flagX, 0
	mov flagY, 0

	cmp x, 0
	je xZeroA

	cmp x, dl
	je xNineA
backA:
	cmp y, 0
	je yZeroA

	cmp y, 9
	je yNineA

	cmp flagX, 1
	je setYA

	mov al, x
	sub al, 1
	mov bl, 10
	mul bl
	mov si, siize

setYA:
	add al, y
	sub al, 1
	mov siize1, 3
outerA:
	push si

	mov si, siize1
	mov di, offset AIField
	add di, ax
innerA:
	xor bx, bx
	mov bl, '1'
	cmp [di], bl
	je setFlagA

comeBackA:
	inc di
	dec si
	jnz innerA

	add al, 10
	pop si
	dec si
	jnz outerA

	pop di
	pop si
	pop dx
	pop bx
	pop ax
	ret

setFlagA:
	mov flag, 1
	jmp comeBackA

xZeroA:
	mov flagX, 1

	mov al, x
	mov bl, 10
	mul bl

	mov si, siize
	dec si
	jmp backA

xNineA:
	mov flagX, 1

	mov al, x
	sub al, 1
	mov bl, 10
	mul bl

	mov si, siize
	dec si
	jmp backA

yZeroA:
	mov siize1, 2
	mov flagY, 1

	cmp flagX, 1
	je setY1A
	mov al, x
	sub al, 1
	mov bl, 10
	mul bl
	mov si, siize

setY1A:
	add al, y
	jmp outerA

yNineA:
	mov siize1, 2
	mov flagY, 1

	cmp flagX, 1
	je setY2A
	mov al, x
	sub al, 1
	mov bl, 10
	mul bl
	mov si, siize

setY2A:
	add al, y
	sub al, 1
	jmp outerA
endp checkAI

check2 proc
	push ax
	
	xor ax, ax
	mov al, 12
	sub ax, siize
	cmp x, al
	jg setFlag1

comeBack1:
	pop ax
	ret

setFlag1:
	mov flag, 1
	jmp comeBack1
endp check2

setOne proc
	push ax
	push bx
	push si

	xor ax, ax
	xor bx, bx

	mov si, offset myField
	
	mov al, x
	mov bl, 10
	mul bl
	add al, y
	add si, ax
	
	xor ax, ax
	mov al, '1'
	mov [si], al

	pop si
	pop bx
	pop ax

	ret
endp setOne

setTwo proc

	call setOne
	add x, 1
	call SetOne

	ret
endp setTwo

setThree proc

	call setOne
	add x, 1
	call SetOne
	add x, 1
	call setOne

	ret
endp setThree

setFour proc

	call setOne
	add x, 1
	call SetOne
	add x, 1
	call setOne
	add x, 1
	call setOne

	ret
endp setFour

setOneAI proc
	push ax
	push bx
	push si

	xor ax, ax
	xor bx, bx

	mov si, offset AIField
	
	mov al, x
	mov bl, 10
	mul bl
	add al, y
	add si, ax
	
	xor ax, ax
	mov al, '1'
	mov [si], al

	pop si
	pop bx
	pop ax

	ret
endp setOneAI

setTwoAI proc

	call setOneAI
	add x, 1
	call SetOneAI

	ret
endp setTwoAI

setThreeAI proc

	call setOneAI
	add x, 1
	call SetOneAI
	add x, 1
	call setOneAI

	ret
endp setThreeAI

setFourAI proc

	call setOneAI
	add x, 1
	call SetOneAI
	add x, 1
	call setOneAI
	add x, 1
	call setOneAI

	ret
endp setFourAI

randomNumber proc
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 2Ch
	int 21h

	xor ax, ax
	xor bx, bx

	mov bl, 10
	mov al, dl
	div bl
	mov num, ah

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp randomNumber

randomNumber1 proc
	push ax
	push bx
	push cx
	push dx
	
	mov ah, 00h
	int 1Ah

	xor ax, ax
	xor bx, bx

	mov bl, 10
	mov al, dl
	div bl
	mov num, ah

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp randomNumber1
end start 
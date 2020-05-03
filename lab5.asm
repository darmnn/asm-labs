.model small 
.stack 100h 
.386
.data

error db "file is not open", '$'
result db "lines without your word: ", '$'
buffer db 0
endFlag dw 0
flag dw ?
flag1 dw ?
endOfStringFlag dw ?
count dw 0
string db 7, 7 dup('$')
string_end = $ - 1 
fileName db 129 dup(0)
wordd db 50 dup(0)
cmdLen db 0
wrong_args db "second argument(word) is missing!", '$'
wrong_word db "the word can't contain spaces and tabs!", '$'

.code 
start:	mov ax, @data 
	mov es, ax 

	xor ch, ch
	mov cl, ds:[80h] ;получаем длину командной строки
	dec cl           ;первый символ - пробел
	mov cmdLen, cl

	mov si, 81h 
	inc si
	lea di, fileName

loopa:
	mov dl, [si]
	cmp dl, ' '   ;если встречается пробел
	je break      ;переходим к записи слова
	movsb   
	loop loopa

	cmp cx, 0
	je wrongArgs

break:	
	inc si
	dec cl
	lea di, wordd
	rep movsb

	mov ds, ax
	call checkWord
	call countStrings
quit:
	mov ax, 4C00h 
	int 21h

wrongArgs:
	mov ds, ax
	lea dx, wrong_args
	call output
	jmp quit

checkWord proc
	push dx
	push si

	lea si, wordd

nextSym:
	mov dl, [si]
	cmp dl, ' '
	je badWord
	cmp dl, 9  ;символ табуляции
	je badWord
	cmp dl, 0
	je ok
	inc si
	jmp nextSym
ok:
	pop si
	pop dx
	ret

badWord:
	lea dx, wrong_word
	call output
	jmp quit
endp checkWord

countStrings proc
	push ax
	push bx
	push cx
	push dx

	mov dx, offset fileName
	mov ah, 3Dh
	mov cx, 0
	mov al, 00h 
	int 21h 
	jc badFile
	
	mov bx, ax 

lopp: 
	call checkString
	cmp flag1, 0     ;нужного слова в строке нет
	je incCount 
back1: 
	cmp endFlag, 1  
	je endd 
	jmp lopp 

endd: 
	lea dx, result
	call output

	call number_to_string
	lea dx, [di+1]
	call output 

closeFile:
	mov ah, 3Eh 
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax
	ret

incCount:
	add count, 1
	jmp back1

badFile:
	mov dx, offset error
	call output
	jmp closeFile
endp countStrings

output proc
	push ax

	mov ah, 09h
	int 21h
	
	pop ax
	ret
endp output

readSymbol proc
	push ax
	push cx
	push dx

	mov ah, 3Fh
	mov cx, 1
	mov dx, offset buffer
	int 21h

	cmp ax, 0
	je setEOF
comeBack:
	pop dx
	pop cx
	pop ax
	ret

setEOF:
	mov endFlag, 1
	jmp comeBack
endp readSymbol

compareWord proc
	push dx
	push si

	mov flag, 1
	mov si, offset wordd
lop:
	call readSymbol
	mov dl, buffer

	cmp endFlag, 1
	je exit
	cmp dl, ' '
	je checkEnd
	cmp dl, 13
	je setEndOfString

	cmp dl, [si]
	jne resetFlag
back:
	inc si
	jmp lop

exit:
	pop si
	pop dx
	ret

resetFlag:
	mov flag, 0
	jmp back

setEndOfString:
	mov endOfStringFlag, 1
	call readSymbol

checkEnd:
	mov dl, 0
	cmp [si], dl
	je exit
	mov flag, 0
	jmp exit
endp compareWord

checkString proc

	mov endOfStringFlag, 0
	mov flag1, 0 ;нужных слов в строке нет
l1:
	call compareWord
	cmp flag, 1  ;если нужное слово нашлось
	je setFlag

comeBack1:
	cmp endOfStringFlag, 1
	je exitt
	cmp endFlag, 1
	je exitt 
	jmp l1

exitt:
	ret

setFlag:
	mov flag1, 1
	jmp comeBack1
endp checkString

number_to_string proc 
	push ax
	push cx
	push dx
	
	mov ax, count
	std 
	lea di, string_end - 1 

	mov cx,10 
	
repeat: 
	xor dx,dx 	
	idiv cx 	; Делим DX:AX на CX (10), 
			; Получаем в AX частное, в DX остаток 
	xchg ax,dx 	; Меняем их местами (нас интересует остаток) 
	add al,'0' 	; Получаем в AL символ десятичной цифры 
	stosb 		; И записываем ее в строку 
	xchg ax,dx 	; Восстанавливаем AX (частное) 
	or ax,ax	; Сравниваем AX с 0 
	jne repeat 

	pop dx
	pop cx
	pop ax
	ret 
endp number_to_string

end start
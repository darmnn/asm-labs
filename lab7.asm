.model small 
.stack 100h 
.386
.data

blockEPB dw 0
	cmd_offset dw offset cmd, 0
	fcb1 dw 005ch, 0
	fcb2 dw 006ch, 0
 
	cmd db 10,' '
	cmd_text db 125 dup (0), 0dh, '$'
 
EPBlen dw $-blockEPB

path db "lab7.exe", 0
num dw ?
cmdLen db 0
minus dw 0
no_cmd_msg db "you must pass one argument to the command line!", '$'
error_msg db "invalid comand line argument! it must be number from 1 to 255", '$'
realloc_error_msg db "error while realloc occured!", '$'
run_error_msg db "error while running new copy occured!", '$'
badNumFlag dw ?
badCMDflag dw ?
NumBuffer dw 0
string db 7, 7 dup('$')
string_end = $ - 1 
start_msg db "programm started. the number of copy is ", '$'
end_msg db "programm ended. the number of copy is ", '$'
data_segment_size = $ - blockEPB
.code
start:	mov ax, es
	mov bx, (code_segment_size/16+1)+(data_segment_size/16+1)+256/16+256/16

	mov ah, 4Ah
	int 21h
	jc reallocError

	mov ax, @data
	mov es, ax 

	xor ch, ch
	mov cl, ds:[80h] ;получаем длину командной строки

	cmp cl, 1
	jl noCMD

	dec cl           ;первый символ - пробел
	mov cmdLen, cl

	mov si, 81h 
	inc si
	lea di, cmd_text
	rep movsb

	mov ds, ax
	call workWithCMD
	cmp badCMDflag, 1
	je exit

	lea dx, start_msg
	call output
	lea dx, cmd_text
	call output

	dec num 
	cmp num, 0 
	je exit 

	call getNewCMD	

	mov bx,offset blockEPB 
	mov ax,ds 
	mov word ptr[blockEPB+4],ax 
	mov ax,cs 
	mov word ptr[blockEPB+8],ax 
	mov word ptr[blockEPB+12],ax 

	mov ax, 4b00h 
	lea dx, path 
	lea bx, blockEPB 
	int 21h 
	jc runProgError
	
	lea dx, end_msg
	call output
	inc num
	call numberToString
	lea dx, [di+1]
	call output
	call new_line
exit:
	mov ax, 4C00h 
	int 21h

noCMD:
	mov ds, ax
	lea dx, no_cmd_msg
	call output
	jmp exit

reallocError:
	lea dx, realloc_error_msg
	call output
	jmp exit

runProgError:
	lea dx, run_error_msg
	call output
	jmp exit

getNewCMD proc
	push ax
	push si

	lea si, cmd_text

l1:
	mov al, [si]
	cmp al, 0
	je decNumber
	inc si
	jmp l1

decNumber:
	dec si	
	mov al, [si]
	cmp al, '0'
	je prevSym
back:
	sub al, 1
	mov [si], al
	jmp exitGetNewCMD

prevSym:
	mov al, '9'
	mov [si], al
	dec si
	mov al, [si]
	cmp al, '1'
	je nine
	jmp back

nine:
	mov al, '9'
	mov [si], al
	inc si
	mov al, 0
	mov [si], al

exitGetNewCMD:
	pop si
	pop ax
	ret
endp getNewCMD

new_line proc
	mov dl, 10 
	mov ah, 2 
	int 21h
	mov dl, 10 
	mov ah, 2 
	int 21h
	ret
endp new_line

workWithCMD proc
	push dx

	mov badCMDflag, 0
	
	call stringToNumber
	cmp badNumFlag, 1
	je cmdError

	cmp num, 255
	jg cmdError

	cmp num, 1
	jl cmdError

exitWorkWithCMD:
	pop dx
	ret

cmdError:
	mov badCMDflag, 1
	lea dx, error_msg
	call output
	jmp exitWorkWithCMD

endp workWithCMD

output proc
	push ax

	mov ah, 09h
	int 21h
	
	pop ax
	ret
endp output

stringToNumber proc
	push ax
	push bx
	push dx
	push si

	mov badNumFlag, 0

	lea si, cmd_text
	mov num, 0

makeNum:
	xor ax, ax
	mov al, [si]
	cmp al, 0
	je exitStringToNumber

	cmp al, '0'
	jl badNum
	cmp al, '9'
	jg badNum

	sub al, '0'
	mov bx, ax
	mov ax, num
	mov dx, 10
	mul dx
	mov num, ax
	add num, bx

	inc si
	jmp makeNum

exitStringToNumber:
	pop si
	pop dx
	pop bx
	pop ax
	ret 

badNum:
	mov badNumFlag, 1
	jmp exitStringToNumber                        
endp stringToNumber

numberToString proc 
	push ax
	push cx
	push dx
	
	mov ax, num
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
endp numberToString

code_segment_size =$-start
end start
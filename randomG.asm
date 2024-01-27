print macro p1
	mov ah,09
	lea dx,p1
	int 21h
endm print
create macro p2,p3
	mov ah,3ch
	lea dx,p2
	mov cl,02
	int 21h
	mov p3,ax
endm create
openFile macro p4,p5
	mov ah,3dh
	lea dx,p4
	mov al,02
	int 21h
	mov p5,ax
endm openFile
closeFile macro p6
	mov ah,3eh
	lea dx,p6
	int 21h
endm closeFile
read macro p7,p8
	mov ah,3fh
	lea dx,p7
	mov cx,36
	mov bx,p8
	int 21h
endm read
background macro p9,p10,p11,p12,p13,p14
	mov ah,06
	mov al,p9
	mov bh,p10
	mov ch,p11
	mov cl,p12
	mov dh,p13			; max 255 tak 
	mov dl,p14
	int 10h
endm background
.model small
.stack 100h
.data
	filename db 'lastscore.txt',0
	address dw ?
	line db '	|=============================|	$'
	number db 'Enter Your Guess Number Between 0-1 : $'
	last db 'Last Scores is : $'
	back db '		Press any key for menu $'
	choosen db '	Enter Your Choice : $'
	menu db '		Number Guessing Game$'
	newgame db '	Press 1 for New Game$'
	history db '	Press 2 for View Scores$'
	gameexit db '	Press 3 for Exit in Game$'
	invalid db '		Invalid choice$'
	thanks db  '			You Enjoy the game $'
	options db '		Please Enter Right Option$'
	seclastmsg db 'Oops, you incorrect guess number$'
	lastMsg db '	Game Over! $'
	yourScore db 'Game score is : $'
	randomNumber db 0
	yourNum db 'Your input number is : $'
	; guess db 'Guess number is : $'
	correctMsg db 'Congratulation! Your guess is correct$'
	counter db '0$'
	instruction db '		GAME INSTRUCTIONS:-$'
	rule db 'You Must Enter the correct Guess.$'
	halfcondition db 'If your guess is correct then your score will be increase.$'
	fullcondition db 'Again you need to enter the Number.$'
	halfuncondition db 'If you failed to guess the number then your score will be print.$'
	fulluncondition db 'Mainmenu will be show.$'
	endgame db 'Game will be run until your number is wrong.$'
	startgame db '		Game started$'
	
.code
start:
	mov ax,@data
	mov ds,ax
	call clearScreen
	call picture
	call clearScreen
mainmenu proc
	mov counter,'0'
	sub counter,'0'
	call displaymenu
	print choosen
	mov ah,1
	int 21h
	cmp al,'1'
    je StartNewGame
    cmp al,'2'
    je ViewScores
    cmp al,'3'
    je Exit
    jmp InvalidChoice
	ret
mainmenu endp
restart:
	call mainmenu
	
StartNewGame:
	call entrykey
	call continue
	call terminate
	
ViewScores:
	call entrykey
	print last
reopenfile:
	openFile filename,address
	jc creationf
	jmp seen
creationf:
	create filename,address
	jmp reopenfile
seen:
	read counter,address
	print counter
	closeFile address
	call entrykey
try:
	print back
	mov ah,00
	int 16h
	call clearScreen
	jmp restart
	
Exit:
	call entrykey
	call clearScreen
	call entrykey
	call entrykey
	background 0,11111000b,0,0,100,100
	print thanks
    mov ah, 00  
    int 16h     
	call clearScreen
	call terminate
	
InvalidChoice:
	call clearScreen
	call entrykey
	print invalid
	call entrykey
	print options
	call mainmenu

continue proc
	call clearScreen
	call entrykey
	print instruction
	call entrykey
	print rule
	call entrykey
	print halfcondition
	call entrykey
	print fullcondition
	call entrykey
	print halfuncondition
	call entrykey
	print fulluncondition
	call entrykey
	print endgame
	call entrykey
	print back
	mov ah,00
	int 16h
	call clearScreen
	print startgame
	call entrykey
	
gameLoop:
	
	call GenerateRandomNumber
	print number
	
	mov ah,01
	int 21h
	mov bl,al
	cmp bl,randomNumber
	call entrykey
	je correctGuess
	jmp wrong
	
correctGuess:
	
	inc counter
	
	print correctMsg
	call entrykey
	call entrykey
	jmp gameLoop
wrong:
	call clearScreen
	background 0,01001111b,0,0,100,100
	call entrykey
	call entrykey
	print seclastmsg
	call entrykey
	
	; print guess
	
	; mov dl,randomNumber
	; mov ah,02
	; int 21h
    call entrykey
	print yourScore
	add counter, '0'
	mov ah,09
	lea dx,counter
	int 21h
	
reopen:
    openFile filename,address
	jc creation
	jmp addscore
creation:
	create filename,address
	jmp reopen
addscore:
	mov ah,40h
	mov bx,address
	mov cx,10
	lea dx,counter
	int 21h
	closeFile address
	
	call entrykey
	print lastMsg
	call entrykey
	print back
	mov ah,00
	int 16h
	call clearScreen
	jmp restart
	ret
continue endp
GenerateRandomNumber proc
    mov ah, 0           
    int 1ah             
	
    mov ax, dx          
    mov dx, 0
	
    mov bx, 2      
    div bx       
    mov randomNumber, dl
	add randomNumber,48
    
    ret
GenerateRandomNumber endp
displaymenu proc
	call entrykey
	print line
	call entrykey
	print menu
	call entrykey
	print line
	call entrykey
	print newgame
	call entrykey
	print history
	call entrykey
	print gameexit
	call entrykey
	call entrykey
	ret
displaymenu endp
entrykey proc
	mov dx,10
	mov ah,02
	int 21h
	mov dx,13
	mov ah,02
	int 21h
	ret
entrykey endp
clearScreen proc
	mov ah, 00h   ; Set Video Mode
    mov al, 03h   ; 80x25 text mode
    int 10h       ; Call BIOS interrupt
	ret
clearScreen endp
terminate proc
	mov ah,4ch
	int 21h
	ret
terminate endp
picture proc
	mov ah,00h
	mov al,13h
	int 10h
	
;for background colour
	mov ah,6			;scroll up window
	mov al,0			;where to start
	mov bh,00111011b	;attributies
	mov ch,0			;start row
	mov cl,0			;start col
	mov dh,230			;end row			; max 255 tak 
	mov dl,200			;end col
	int 10h				;print graphic
;for question mark line ( Number 01 )
	mov ah,0ch
	mov cx,25
	mov dx,9
	mov al,40
line1:
	int 10h
	inc cx
	cmp cx,55
jle line1
line2:
	int 10h
	inc dx
	cmp dx,18
jle line2

	mov ah,0ch
	mov cx,45
	mov al,40
line3:
	int 10h
	inc cx
	cmp cx,55
jle line3

	mov ah,0ch
	mov cx,45
	mov dx,18
	mov al,40
line4:
	int 10h
	inc dx
	cmp dx,30
jle line4
;for end for question mark box
	mov ah,0ch
	mov cx,40
	mov dx,40
	mov al,50
box1:
	int 10h
	inc cx
	cmp cx,50
jle box1
box2:
	int 10h
	inc dx
	cmp dx,50
jle box2
	mov ah,0ch
	mov cx,40
	mov dx,40
	mov al,50
box3:
	int 10h
	inc dx
	cmp dx,50
jle box3
box4:
	int 10h
	inc cx
	cmp cx,50
jle box4

;for question mark line ( Number 02 )
	mov ah,0ch
	mov cx,25
	mov dx,130
	mov al,40
lin1:
	int 10h
	inc cx
	cmp cx,55
jle lin1
lin2:
	int 10h
	inc dx
	cmp dx,139
jle lin2

	mov ah,0ch
	mov cx,45
	mov al,40
lin3:
	int 10h
	inc cx
	cmp cx,55
jle lin3

	mov ah,0ch
	mov cx,45
	mov dx,139
	mov al,40
lin4:
	int 10h
	inc dx
	cmp dx,151
jle lin4

;for end for question mark box
	mov ah,0ch
	mov cx,40
	mov dx,161
	mov al,50
lbox1:
	int 10h
	inc cx
	cmp cx,50
jle lbox1
lbox2:
	int 10h
	inc dx
	cmp dx,171
jle lbox2

	mov ah,0ch
	mov cx,40
	mov dx,161
	mov al,50
lbox3:
	int 10h
	inc dx
	cmp dx,171
jle lbox3
lbox4:
	int 10h
	inc cx
	cmp cx,50
jle lbox4

;for question mark line ( Number 03 )
	mov ah,0ch
	mov cx,255  		;25
	mov dx,9
	mov al,40
lie1:
	int 10h
	inc cx
	cmp cx,285			;55
jle lie1
lie2:
	int 10h
	inc dx
	cmp dx,18
jle lie2

	mov ah,0ch
	mov cx,275			;45
	mov al,40
lie3:
	int 10h
	inc cx
	cmp cx,285			;55
jle lie3

	mov ah,0ch
	mov cx,275			;45
	mov dx,18
	mov al,40
lie4:
	int 10h
	inc dx
	cmp dx,30
jle lie4
;for end for question mark box
	mov ah,0ch
	mov cx,270					;40
	mov dx,40
	mov al,50					;green colour
bc1:
	int 10h
	inc cx
	cmp cx,280					;50
jle bc1
bc2:
	int 10h
	inc dx
	cmp dx,50
jle bc2
	mov ah,0ch
	mov cx,270					;40
	mov dx,40
	mov al,50
bc3:
	int 10h
	inc dx
	cmp dx,50
jle bc3
bc4:
	int 10h
	inc cx
	cmp cx,280					;50
jle bc4

;for question mark line ( Number 04 )
	mov ah,0ch
	mov cx,255							;25
	mov dx,130
	mov al,40
li1:
	int 10h
	inc cx
	cmp cx,285							;55
jle li1
li2:
	int 10h
	inc dx
	cmp dx,139
jle li2

	mov ah,0ch
	mov cx,275							;45
	mov al,40
li3:
	int 10h
	inc cx
	cmp cx,285							;55
jle li3

	mov ah,0ch
	mov cx,275							;45
	mov dx,139
	mov al,40
li4:
	int 10h
	inc dx
	cmp dx,151
jle li4

;for end for question mark box
	mov ah,0ch
	mov cx,270
	mov dx,161
	mov al,50
lbo1:
	int 10h
	inc cx
	cmp cx,280
jle lbo1
lbo2:
	int 10h
	inc dx
	cmp dx,171
jle lbo2

	mov ah,0ch
	mov cx,270
	mov dx,161
	mov al,50
lbo3:
	int 10h
	inc dx
	cmp dx,171
jle lbo3
lbo4:
	int 10h
	inc cx
	cmp cx,280
jle lbo4
;For Welcome ki oneline
	mov ah,0ch
	mov cx,25
	mov dx,70
	mov al,55
w1:
	int 10h
	inc cx
	cmp cx,70
	inc dx
	cmp dx,110
jle w1
;For Welcome ki secondline
	mov ah,0ch
	mov cx,65
	mov dx,110
	mov al,55
w2:
	int 10h
	dec dx
	cmp dx,70
	inc cx
	cmp cx,85
jle w2
;For Welcome ki thirdline
	mov ah,0ch
	mov cx,80
	mov dx,90
	mov al,55
w3:
	int 10h
	inc cx
	cmp cx,100
	inc dx
	cmp dx,110
jle w3
;For Welcome ki fourthline
	mov ah,0ch
	mov cx,100
	mov dx,110
	mov al,55
w4:
	int 10h
	dec dx
	cmp dx,70
	inc cx
	cmp cx,140
jle w4
;For Welcome ki E ki firstline
	mov ah,0ch
	mov cx,130
	mov dx,110
	mov al,55
e1:
	int 10h
	inc cx
	cmp cx,150
jle e1
;For Welcome ki E ki secondline
	mov ah,0ch
	mov cx,130
	mov dx,90
	mov al,55
e2:
	int 10h
	inc dx
	cmp dx,110
jle e2
;For Welcome ki E ki thirdline
	mov ah,0ch
	mov cx,130
	mov dx,90
	mov al,55
e3:
	int 10h
	inc cx
	cmp cx,150
jle e3
;For Welcome ki E ki thirdline
	mov ah,0ch
	mov cx,130
	mov dx,100
	mov al,55
e4:
	int 10h
	inc cx
	cmp cx,150
jle e4
;For Welcome ki L ki firstline
	mov ah,0ch
	mov cx,160
	mov dx,90
	mov al,55
l1:
	int 10h
	inc dx
	cmp dx,110
jle l1
;For Welcome ki L ki secondline
	mov ah,0ch
	mov cx,160
	mov dx,110
	mov al,55
l2:
	int 10h
	inc cx
	cmp cx,180
jle l2
;For Welcome ki C ki secondline
	mov ah,0ch
	mov cx,190
	mov dx,90
	mov al,55
c1:
	int 10h
	inc cx
	cmp cx,210
jle c1
;For Welcome ki C ki secondline
	mov ah,0ch
	mov cx,190
	mov dx,90
	mov al,55
c2:
	int 10h
	inc dx
	cmp dx,110
jle c2
;For Welcome ki C ki thirdline
	mov ah,0ch
	mov cx,190
	mov dx,110
	mov al,55
c3:
	int 10h
	inc cx
	cmp cx,210
jle c3

;For Welcome ki O ki firstline
	mov ah,0ch
	mov cx,220
	mov dx,90
	mov al,55
o1:
	int 10h
	inc cx
	cmp cx,240
jle o1
o2:				;secondline
	int 10h
	inc dx
	cmp dx,110
jle o2
;For Welcome ki O ki thirdline
	mov ah,0ch
	mov cx,220
	mov dx,90
	mov al,55
o3:
	int 10h
	inc dx
	cmp dx,110
jle o3
o4:				;fourthline
	int 10h
	inc cx
	cmp cx,240
jle o4
;For Welcome ki M ki firstline
	mov ah,0ch
	mov cx,250
	mov dx,90
	mov al,55
m1:
	int 10h
	inc dx
	cmp dx,110
jle m1
;For Welcome ki M ki secondline
	mov ah,0ch
	mov cx,250
	mov dx,90
	mov al,55
m2:
	int 10h
	inc cx
	cmp cx,260
	inc dx
	cmp dx,100
jle m2
;For Welcome ki M ki thirdline
	mov ah,0ch
	mov cx,260
	mov dx,100
	mov al,55
m3:
	int 10h
	dec dx
	cmp dx,90
	inc cx
	cmp cx,270
jle m3
;For Welcome ki M ki fourthline
	mov ah,0ch
	mov cx,270
	mov dx,90
	mov al,55
m4:
	int 10h
	inc dx
	cmp dx,110
jle m4
;For Welcome ki E ki firstline
	mov ah,0ch
	mov cx,280
	mov dx,90
	mov al,55
ae1:
	int 10h
	inc dx
	cmp dx,110
jle ae1
;For Welcome ki E ki secondline
	mov ah,0ch
	mov cx,280
	mov dx,90
	mov al,55
ae2:
	int 10h
	inc cx
	cmp cx,300
jle ae2
;For Welcome ki E ki thirdline
	mov ah,0ch
	mov cx,280
	mov dx,100
	mov al,55
ae3:
	int 10h
	inc cx
	cmp cx,300
jle ae3
;For Welcome ki E ki thirdline
	mov ah,0ch
	mov cx,280
	mov dx,110
	mov al,55
ae4:
	int 10h
	inc cx
	cmp cx,300
jle ae4

	mov ah,00h
	int 16h
	
	mov ah,00h
	mov al,03h
	int 10h
	ret
picture endp
end start
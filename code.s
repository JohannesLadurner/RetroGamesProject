.include "LAMAlib.inc"
.include "LAMAlib-sprites.inc"

MUSIC_BASE=$c000
install_file "assets/music.prg"
install_file "assets/Hamster.prg",$3040
install_file "assets/PinNeedle.prg",$3000
SCREEN_BASE=$400

clrscr ;clear screen

init:
	lda #0
	sta points
	;init player
	setSpriteMultiColor1 13
	setSpriteMultiColor2 5
	setSpriteCostume 1,$3040
	setSpriteXY 1,180,220
	updateSpriteAttributes 1
	showSprite 1
	
	;init needles	
	setSpriteMultiColor1 3
	setSpriteMultiColor2 12

	setSpriteCostume 2,$3000
	setSpriteXY 2,0,0
	updateSpriteAttributes 2
	showSprite 2
	
	setSpriteCostume 3,$3000
	setSpriteXY 3,0,100
	updateSpriteAttributes 3
	showSprite 3

	setSpriteCostume 4,$3000
	setSpriteXY 4,0,200
	updateSpriteAttributes 4
	showSprite 4

	;init music
	lda #$00 ; select first tune
	jsr MUSIC_BASE ; init music
	set_raster_irq 0,isr

	;set interrupt
	sei
	ldax #isr
	stax $314
	cli

mainloop:

	;move needles downwards
	;needle 2
	getSpriteY 2,X       
	txa                  
	clc                  
	adc needle_speed     
	tax                  
	setSpriteY 2,X
	txa
	cmp #250
	if ge ;if y pos is >= 250, reset at random pos
		rand16 300
		setSpriteX 2,AX
		setSpriteY 2,0
		ldx points
		inx
		stx points
		jsr update_speed
	endif
	
	;needle 2
	getSpriteY 3,X      
	txa                
	clc                 
	adc needle_speed    
	tax                 
	setSpriteY 3,X
	txa
	cmp #250
	if ge
		rand16 300
		setSpriteX 3,AX
		setSpriteY 3,0
		ldx points
		inx
		stx points 
		jsr update_speed
	endif

	;needle 3
	getSpriteY 4,X      
	txa             
	clc                  
	adc needle_speed     
	tax                  
	setSpriteY 4,X
	txa
	cmp #250
	if ge
		rand16 300
		setSpriteX 4,AX
		setSpriteY 4,0
		ldx points
		inx
		stx points
		jsr update_speed
	endif
	
	sync_to_rasterline256

	clc
    	ldx #0 ;start at 0,0
    	ldy #0
    	jsr $FFF0   ;call PLOT routine to set cursor position
	println ""
	print "points: "
	lda points
	printa
	print "  lives: "
	lda lives
	printa
	lda lives
	cmp #$0
	beq game_over
	
jmp mainloop


incpoints:
	ldx points
	inx
	stx points 

isr:
	asl $d019 ;to clear the interrupt

	;music
	jsr MUSIC_BASE+3

	read_keys_WASDspace
	and $dc00
	and $dc01
	sta joyvalue
	lsr joyvalue ;Player move up
	if cc
	endif
	lsr joyvalue ;Player move down
	if cc
	endif
	lsr joyvalue ;Player move left
	if cc
		dec $d002 
	endif
	lsr joyvalue ;Player move right
	if cc
		inc $d002 
	endif
	lsr joyvalue ;Space
	if cc
	endif
	

	lda $d01e         ; Read sprite-sprite collision register
	and #%00000010    ; Check if sprite 1 collided with sprite 0 (bit 1 set)

	beq nocollision   ; If not, skip color change

	; COLLISION DETECTED
	lda #$04      ; Reset to original color (light red)
	sta $d028
	;if byte is set, skip taking damage
	lda invincibility
	cmp #$1
	beq skip_reduce

	reduce_lives:
	;set invincibility byte
	ldx #$1
	stx invincibility

	ldx lives
	dex
	stx lives


	skip_reduce:

	jmp $ea31

	nocollision:
	ldx #$0
	stx invincibility
	lda #$02          ; Set new color (example: red)
	sta $d028         ; Sprite 1 color

	jmp $ea31

game_over:
	BRK

update_speed:
	lda points
	cmp #10
	bcc set_speed_1
	cmp #20
	bcc set_speed_2
	cmp #30
	bcc set_speed_3
	jmp set_speed_4
set_speed_2:
	lda #2
	sta needle_speed
	rts

set_speed_3:
	lda #3
	sta needle_speed
	rts

set_speed_4:
	lda #4
	sta needle_speed
	rts

set_speed_1:
	lda #1
	sta needle_speed
	rts


;variables
joyvalue: .byte 00
points: .byte 00
lives: .byte 03
speed: .byte 01
invincibility: .byte 00
needle_speed: .byte 01